# Detect sdsn SDG
detect_sdsn = function(corpus, sdgs, verbose = FALSE){

  #filter queries based on selected sdgs
  sdsn_queries <- sdsn_queries %>%
    dplyr::filter(sdg %in% sdgs)


  # get hits
  hits = search_corpus(corpus, sdsn_queries$query, mode = "unique_hits")
  hits$sdg = sdsn_queries$sdg[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))]
  hits$query_id = sdsn_queries$query_id[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))]

  # exit if no hits
  if(nrow(hits) == 0 )  return(NULL)

  #out
  hits %>%
    #todo: remove ID from query string?
    dplyr::select(-sentence) %>%
    dplyr::mutate(document = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  system = "SDSN") %>%
    dplyr::group_by(document, query_id) %>%
    #paste features together
    dplyr::summarise(number_of_matches = dplyr::n(),
                     features = toString(unique(feature)),
                     dplyr::across(c(sdg, system), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:dplyr::n()) %>%
    dplyr::select(document, sdg, system, query_id, features, hit) %>%
    dplyr::arrange(document, sdg, query_id)

}
