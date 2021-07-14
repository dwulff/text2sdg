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
  simple_hits = search_corpus(corpus, elsevier_simple)
  simple_hits$sdg = names(elsevier_simple)[as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))]
  simple_hits$query = elsevier_simple[as.numeric(stringr::str_extract(simple_hits$code, '[:digit:]+'))]

  # out
  if(nrow(simple_hits) > 0 ) {

    simple_hits %>%
      dplyr::select(-sentence) %>%
      dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                    feature = as.character(feature),
                    method = "elsevier")  %>%
      dplyr::group_by(doc_id, code) %>%
      #paste features together
      dplyr::summarise(number_of_matches = dplyr::n(),
                       features = toString(feature),
                       dplyr::across(c(sdg, query, method), unique)) %>%
      dplyr::ungroup() %>%
      #add hit id
      dplyr::mutate(hit = 1:nrow(.)) %>%
      dplyr::select(-query) %>%
      dplyr::rename(system = method,
                    query_id = code)


  } else {
    simple_hits
  }


  }
