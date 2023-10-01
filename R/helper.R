#' Make Corpus
#'
#' Makes Corpus
#'
#' @param txt character vector
#' @param logical If TRUE, report progress. Only if x is large enough to require multiple sequential batches
#' @param ... further arguments for corpustools::search_features
#' @noRd


make_corpus <- function(txt, ...) corpustools::create_tcorpus(txt, verbose = FALSE, ...)

#' Search Corpus
#'
#' Search Corpus
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param queries character vector if queries
#' @param ... further arguments for corpustools::search_features
#' @noRd


search_corpus <- function(corpus, queries, ...) corpustools::search_features(corpus, queries, ...)$hit %>% tibble::as_tibble()


#' Get hit code
#'
#' Get hit code
#'
#' @param data data frame
#' @noRd


get_code <- function(data) {

  # get id
  id <- as.character(data[[1]])
  for (i in 2:ncol(data)) id <- paste0(id, "_", data[[i]])

  # out
  id
}

w_n <- function(x, y, n = 3) {
  pairs <- expand.grid(x, y)
  min(abs(pairs[, 1] - pairs[, 2])) <= n
}
