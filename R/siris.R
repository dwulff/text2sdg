#' Detect Siris SDG
#'
#'Detect Siris SDG
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export
detect_siris = function(corpus, verbose = FALSE){


  # get hits
  simple_hits = search_corpus(corpus, siris_queries_v1.3$query, mode = "unique_hits")
  simple_hits$sdg <- stringr::str_extract(simple_hits$code, "SDG-[0-9]{1,2}")

  #join query_id
  simple_hits <- simple_hits %>%
    dplyr::left_join(siris_queries_v1.3 %>%
                dplyr::mutate(ID_new = stringr::str_extract(siris_queries_v1.3$query, "SDG-[0-9]{1,2}-.*#"),
                       ID_new = substr(ID_new, 1, nchar(ID_new) - 1)) %>%
                dplyr::select(ID_new, query_id), by = c("code" = "ID_new")) %>%
    #drop code, since we now use query_id to match with query data
    dplyr::select(-code)




  # #development
  #simple_hits = search_corpus(make_corpus(test_txt), siris_queries_v1.3$query)


  #out
  simple_hits %>%
    #todo: remove ID from query string?
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  system = "siris") %>%
    dplyr::group_by(doc_id, query_id) %>%
    #paste features together
    dplyr::summarise(number_of_matches = dplyr::n(),
              features = toString(unique(feature)),
              dplyr::across(c(sdg, system), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:dplyr::n())



}



