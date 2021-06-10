#' Detect Siris SDG
#'
#'Detect Siris SDG
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @return
#' @export
#'
#' @examples
detect_siris = function(corpus, verbose = FALSE){


  # get hits
  simple_hits = search_corpus(corpus, zenodo_queries_v1.3$query)
  simple_hits$sdg <- stringr::str_extract(simple_hits$code, "SDG-[0-9]{1,2}")


  # #development
  #simple_hits = search_corpus(make_corpus(test_txt), zenodo_queries_v1.3$query)


  #out
  simple_hits %>%
    #todo: remove ID from query string?
    dplyr::left_join(zenodo_queries_v1.3 %>% dplyr::select(ID, query), by = c("code" = "ID")) %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature))


}





