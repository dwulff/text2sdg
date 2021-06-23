#' Detect ontology SDG
#'
#'Detect ontology SDG
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @return
#' @export
#'
#' @examples
detect_ontology = function(corpus, verbose = FALSE){


  # get hits
  simple_hits = search_corpus(corpus, ontology_queries$query)
  simple_hits$sdg = ontology_queries$sdg[as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))]
  simple_hits$query_id = as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))

  #drop code since we now use query_id
  simple_hits <- simple_hits %>%
    dplyr::select(-code)



  # #development
  #simple_hits = search_corpus(make_corpus(test_txt), ontology_queries$query)
  # out


  simple_hits %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  method = "ontology")  %>%
    dplyr::group_by(doc_id, query_id) %>%
    #paste features together
    dplyr::summarise(number_of_matches = dplyr::n(),
                     features = toString(feature),
              dplyr::across(c(sdg, method), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:nrow(.)) %>%
    dplyr::rename(system = method)


}


