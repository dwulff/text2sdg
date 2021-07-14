#' Detect Elsevier SDG
#'
#' Detect Elsevier SDG
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

detect_elsevier = function(corpus, verbose = FALSE){

  # get hits
  hits = search_corpus(corpus, elsevier_queries$query)
  hits$sdg = elsevier_queries$sdg[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))]
  hits$query_id = elsevier_queries$query_id[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))]

  # exit if no hits
  if(nrow(hits) == 0 )  return(NULL)

  # prepare out
  hits %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(document = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  system = "elsevier")  %>%
    dplyr::group_by(document, query_id) %>%
    #paste features together
    dplyr::summarise(number_of_matches = dplyr::n(),
                     features = toString(feature),
                     dplyr::across(c(sdg, system), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:nrow(.)) %>%
    dplyr::select(document, sdg, system, query_id, features, hit) %>%
    dplyr::arrange(document, sdg, query_id)


  }
