

comp_phi <- function(hits,
                     compare = c("systems", "SDGs"),
                     show_sdg = 1:17,
                     show_system = c("aurora","elsevier","siris", "ontology")) {


  # check if columns present
  required_columns = c("sdg","system", "document", "hit")
  if(any(!required_columns %in% names(hits))){
    missing = required_columns[!required_columns %in% names(hits)]
    stop(paste0("Data object must include columns [",paste0(missing, collapse=", "),"]."))
  }

  # check sdg and system
  if(any(!show_sdg %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  if(any(!show_system %in% hits$system)){
    stop(paste0("Data object only contains systems [",paste0(unique(hits$system), collapse = ", "),"]."))
  }
  if(compare[[1]] == "systems") {
    if(length(show_system) < 2){
      stop("You need to specify at least 2 systems with 'show_system' to compare.")
    }
  }

  # check compare
  if(!compare[[1]] %in% c("systems", "SDGs")){
    stop("compare must be either 'systems' or 'SDGs'.")
  }

  # handle duplicates
  duplicates = hits %>% dplyr::select(document, sdg, system) %>% duplicated()
  hits = hits %>% dplyr::filter(!duplicates)

  #handle selected SDGs
  sdgs = paste0("SDG-", ifelse(show_sdg < 10, "0", ""),show_sdg) %>% sort()
  hits <- hits %>%
    dplyr::filter(sdg %in% sdgs) %>%
    dplyr::filter(system %in% show_system)



  if(compare[[1]] == "systems") {



      phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = show_system, sdg = unique(hits$sdg)) %>%
        dplyr::mutate(document = as.factor(document)) %>%
        dplyr::left_join(hits %>% dplyr::select(document, system, sdg, hit)) %>%
        dplyr::mutate(hit = dplyr::if_else(is.na(hit), FALSE, TRUE)) %>%
        dplyr::distinct() %>%
        dplyr::arrange(document, sdg) %>%
        tidyr::pivot_wider(names_from = system, values_from = hit) %>%
        `[`(,-(1))



      comp_phi_internal <- function(x) {

        x %>%
          split(.$sdg) %>%
          purrr::map(~ dplyr::select(., -sdg)) %>%
          purrr::map(~ .x %>%  dplyr::mutate_at(dplyr::everything(.), function(x) factor(x, levels = c(TRUE, FALSE)))) %>%
          purrr::map(~ table(.)) %>%
          purrr::map(psych::phi) %>%
          dplyr::as_tibble() %>%
          tidyr::pivot_longer(dplyr::everything())

      }


      phis <- list()
      i <- 1
      for(idx in as.data.frame(utils::combn(ncol(phi_dat) - 1,2))) {

        a <- comp_phi_internal(phi_dat[,c(1,idx + 1)])
        a["comparison"] <- paste(names(phi_dat[, idx + 1]), collapse = " - ")
        print(paste(names(phi_dat[, idx + 1]), collapse = " - "))

        phis[[i]] <- a
        i = i + 1

      }

      #output = 1 df
      #change name and value column names.
      #change NaNs to NA
      phis <- do.call(rbind, phis)

      #convert nans to NA
      phis <- phis %>%
        dplyr::mutate(value = dplyr::if_else(is.nan(value), NA_real_, value)) %>%
        dplyr::rename(sdg = name,
                      phi = value)



      return(phis)





  } else {

    if(nrow(hits) == 0) {
      warning("There were no SDG hits in the data, returning empty data frame.")
      return(tibble())
    }
    # sdg_cor <- hits %>%
    #   dplyr::distinct(document, sdg, system) %>%
    #   widyr::pairwise_cor(sdg, document, sort = TRUE) %>%
    #   dplyr::arrange(item1, item2) %>%
    #   tidyr::pivot_wider(names_from = item2, values_from = correlation) %>%
    #   dplyr::relocate(c(item1, `SDG-01`)) %>%
    #   dplyr::rename(SDG = item1)
    #
    #
    #
    # return(sdg_cor)


    comp_phi_internal <- function(x) {

      x %>%
        split(.$system) %>%
        purrr::map(~ dplyr::select(., -system)) %>%
        purrr::map(~ .x %>%  dplyr::mutate_at(dplyr::everything(.), function(x) factor(x, levels = c(TRUE, FALSE)))) %>%
        purrr::map(~ table(.)) %>%
        purrr::map(psych::phi) %>%
        dplyr::as_tibble() %>%
        tidyr::pivot_longer(dplyr::everything())

    }


    phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = show_system, sdg = sdgs) %>%
      dplyr::mutate(document = as.factor(document)) %>%
      dplyr::left_join(hits %>% dplyr::select(document, system, sdg, hit)) %>%
      dplyr::mutate(hit = dplyr::if_else(is.na(hit), FALSE, TRUE)) %>%
      dplyr::distinct() %>%
      dplyr::arrange(document, sdg) %>%
      tidyr::pivot_wider(names_from = sdg, values_from = hit) %>%
      `[`(,-(1))


    phis <- list()
    i <- 1
    for(idx in as.data.frame(utils::combn(ncol(phi_dat) - 1,2))) {
      a <- comp_phi_internal(phi_dat[,c(1,idx + 1)])
      a["comparison"] <- paste(names(phi_dat[, idx + 1]), collapse = " - ")

      phis[[i]] <- a
      i = i + 1

    }

    phis <- do.call(rbind, phis)

    #convert nans to NA
    phis <- phis %>%
      dplyr::mutate(value = dplyr::if_else(is.nan(value), NA_real_, value)) %>%
      dplyr::rename(system = name,
                    phi = value,
                    association = comparison)

    sdg_table <- tidyr::expand_grid(sdg1 = sdgs, sdg2 = sdgs, system = show_system)


    phis_join <- phis %>%
      dplyr::mutate(sdg1 = substr(association, 1, 6),
                    sdg2 = substr(association, 10,15)) %>%
      dplyr::filter(system == "elsevier")


    phis <- sdg_table %>%
      dplyr::left_join(phis_join, by = c("sdg1" = "sdg1", "sdg2" = "sdg2", "system" = "system")) %>%
      dplyr::left_join(phis_join, by = c("sdg1" = "sdg2", "sdg2" = "sdg1", "system" = "system")) %>%
      dplyr::mutate(phi = dplyr::if_else(is.na(phi.x), phi.y, phi.x),
             phi = dplyr::if_else(sdg1 == sdg2, 1, phi)) %>%
      dplyr::select(-c(association.x, association.y, phi.x, phi.y)) %>%
      dplyr::arrange(system, sdg1) %>%
      tidyr::pivot_wider(names_from = sdg2, values_from = phi)


    return(phis)



  }

}



