#' Make Corpus
#'
#' Makes Corpus
#'
#' @param txt character vector
#' @param ... further arguments for corpustools::search_features
#'
#' @export

make_corpus = function(txt, ...) corpustools::create_tcorpus(txt, ...)

#' Search Corpus
#'
#' Search Corpus
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param queries character vector if queries
#' @param ... further arguments for corpustools::search_features
#'
#' @export

search_corpus = function(corpus, queries, ...) corpustools::search_features(corpus, queries, ...)$hit %>% tibble::as_tibble()


#' Get hit code
#'
#' Get hit code
#'
#' @param hist data frame
#'
#' @export

get_code = function(data) {

  # get id
  id = ""
  for(i in 1:ncol(data)) id = paste0(id, '_', data[[i]])

  # out
  data$hit_code = id
  data

  }
