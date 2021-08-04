




comp_phi <- function(data, hits) {

  phi_dat <- tidyr::expand_grid(document = 1:length(data), system = unique(hits$system), sdg = unique(hits$sdg)) %>%
    dplyr::left_join(hits %>% dplyr::select(document, system, sdg, hit)) %>%
    dplyr::mutate(hit = dplyr::if_else(is.na(hit), FALSE, TRUE)) %>%
    dplyr::distinct() %>%
    dplyr::arrange(document, sdg) %>%
    tidyr::pivot_wider(names_from = system, values_from = hit) %>%
    `[`(,-(1))



  comp_phi_internal <- function(x) {

    x %>%
      split(.$sdg) %>%
      purrr::map(~ select(., -sdg)) %>%
      purrr::map(~ .x %>%  mutate_at(everything(.), function(x) factor(x, levels = c(TRUE, FALSE)))) %>%
      purrr::map(~ table(.)) %>%
      purrr::map(phi) %>%
      dplyr::as_tibble() %>%
      tidyr::pivot_longer(everything())

  }


  phis <- list()
  i <- 1
  for(idx in as.data.frame(utils::combn(ncol(phi_dat) - 1,2))) {

    a <- comp_phi_internal(phi_dat[,c(1,idx + 1)])
    a["comparison"] <- paste(names(phi_dat1[, idx + 1]), collapse = " - ")

    phis[[i]] <- a
    i = i + 1

  }


  return(phis)


}

# comp_phi(test_txt, hits)
