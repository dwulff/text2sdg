# Detect SDGO SDG
detect_sdgo <- function(corpus, sdgs, verbose = FALSE) {

  # filter queries based on selected sdgs
  sdgo_queries <- sdgo_queries %>%
    dplyr::filter(sdg %in% sdgs)

  # get hits
  hits <- search_corpus(corpus, sdgo_queries$query)
  hits$sdg <- sdgo_queries$sdg[as.numeric(stringr::str_extract(hits$code, "[:digit:]+"))]
  hits$query_id <- as.numeric(stringr::str_extract(hits$code, "[:digit:]+"))

  # exit if no hits
  if (nrow(hits) == 0) {
    return(NULL)
  }

  # out
  hits %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(
      document = as.numeric(as.character(doc_id)),
      feature = as.character(feature),
      system = "SDGO"
    ) %>%
    dplyr::group_by(document, query_id) %>%
    # paste features together
    dplyr::summarise(
      matches = dplyr::n(),
      features = toString(feature),
      dplyr::across(c(sdg, system), unique)
    ) %>%
    dplyr::ungroup() %>%
    # add hit id
    dplyr::mutate(hit = 1:nrow(.)) %>%
    dplyr::select(document, sdg, system, query_id, features, hit) %>%
    dplyr::arrange(document, sdg, query_id)
}
