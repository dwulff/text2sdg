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
  simple_hits %>%
    dplyr::select(-sentence) %>%
    dplyr::mutate(doc_id = as.numeric(as.character(doc_id)),
                  feature = as.character(feature))

  }
