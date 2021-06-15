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
  simple_hits = search_corpus(corpus, zenodo_queries_v1.3$query, mode = "unique_hits")
  simple_hits$sdg <- stringr::str_extract(simple_hits$code, "SDG-[0-9]{1,2}")

  #join query
  simple_hits <- simple_hits %>%
    dplyr::left_join(zenodo_queries_v1.3 %>%
                dplyr::mutate(ID_new = stringr::str_extract(zenodo_queries_v1.3$query, "SDG-[0-9]{1,2}-.*#"),
                       ID_new = substr(ID_new, 1, nchar(ID_new) - 1)) %>%
                dplyr::select(ID_new, query), by = c("code" = "ID_new"))




  # #development
  #simple_hits = search_corpus(make_corpus(test_txt), zenodo_queries_v1.3$query)


  #out
  simple_hits %>%
    #todo: remove ID from query string?
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  method = "siris") %>%
    group_by(doc_id, code) %>%
    #paste features together
    summarise(features = toString(feature),
              across(c(sdg, query, method), unique)) %>%
    ungroup() %>%
    #add hit id
    mutate(hit = 1:nrow(.))


}



