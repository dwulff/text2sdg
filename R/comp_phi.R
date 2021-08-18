

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

      if(length(show_system) <= 1) {
        stop("show_system must specify at least 2 systems to compare")
      }



      phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = show_system, sdg = sdgs) %>%
        dplyr::mutate(document = as.factor(document)) %>%
        dplyr::left_join(hits %>% dplyr::select(document, system, sdg, hit)) %>%
        dplyr::mutate(hit = dplyr::if_else(is.na(hit), FALSE, TRUE)) %>%
        dplyr::distinct() %>%
        dplyr::arrange(document, sdg) %>%
        tidyr::pivot_wider(names_from = system, values_from = hit) %>%
        `[`(,-(1))

      # phi_dat %>%
      #   split(.$sdg) %>%
      #   purrr::map(~ .x %>% dplyr::select(-sdg) %>% cor(.))



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

      phis <- do.call(rbind, phis)
      print(phis)

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

    if(length(show_sdg) <= 1) {
      stop("show_sdg must specify at least two SDGs to compare.")
    }



    phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = show_system, sdg = sdgs) %>%
      dplyr::mutate(document = as.factor(document)) %>%
      dplyr::left_join(hits %>% dplyr::select(document, system, sdg, hit)) %>%
      dplyr::mutate(hit = dplyr::if_else(is.na(hit), 0, 1)) %>%
      dplyr::distinct() %>%
      dplyr::arrange(document, sdg) %>%
      tidyr::pivot_wider(names_from = sdg, values_from = hit) %>%
      `[`(,-(1))


    phi_dat <- phi_dat %>%
      split(.$system) %>%
      purrr::map(~ .x %>% dplyr::select(-system) %>% cor(.))





    return(phi_dat)



  }

}



