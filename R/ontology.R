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
  simple_hits$query = ontology_queries$query[as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))]

  # #development
  #simple_hits = search_corpus(make_corpus(test_txt), ontology_queries$query)
  # out


  simple_hits %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  method = "ontology")  %>%
    group_by(doc_id, code) %>%
    #paste features together
    summarise(features = toString(feature),
              across(c(sdg, query, method), unique)) %>%
    ungroup() %>%
    #add hit id
    mutate(hit = 1:nrow(.))


}


