#' Detect SDGs in text with own query system
#'
#' \code{detect_any} identifies SDGs in text using user provided query systems. Works like \code{\link{detect_sdg}} but uses a user specified query system instead of an existing one like \code{\link{detect_sdg}} does.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param queries a data frame that must contain the following variables: a \code{character} vector with queries, a \code{integer} vector specifying which SDG each query maps to (values must be between 1 and 17) and a \code{character} with one unique value specifying the name of the used query system (can be anything as long as it is unique).
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the sdgs to identify in \code{text}. Defaults to \code{1:17}.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"docs"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the features.
#' @param verbose \code{logical} specifying whether messages on the function's progress should be printed.
#'
#' @return The function returns a \code{tibble} containing the SDG hits found in the vector of documents. Depending on the value of \code{output} the tibble will contain all or some of the following columns:
#' \describe{
#'  \item{document}{Index of the element in \code{text} where match was found. Formatted as a factor with the number of levels matching the original number of documents.}
#'  \item{sdg}{Label of the SDG found in document.}
#'  \item{systems}{The name of the query system that produced the match.}
#'  \item{query_id}{Index of the query within the query system that produced the match.}
#'  \item{features}{Concatenated list of words that caused the query to match.}
#'  \item{hit}{Index of hit for a given system.}
#' }
#'
#' @examples
#'
#' # create data frame with query system
#' my_queries <- tibble::tibble(system = rep("my_system", 4),
#'                              query = c("theory", "analysis OR analyses OR analyzed", "study AND hypothesis"),
#'                              sdg = c(1,2,2))
#'
#' # run sdg detection with own query system
#' hits <- detect_any(projects, my_queries)
#'
#' # run sdg detection for sdg 3 only
#' hits <- detect_any(projects, my_queries, sdgs = 3)
#'
#'
#' @export

detect_any <- function(text, queries, sdgs = NULL, output = c("features","docs"), verbose = TRUE) {


  # make corpus
  if(class(text)[1] == "character"){
    corpus = make_corpus(text)
  } else if(class(text)[1] == "tCorpus"){
    corpus = text
  } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
  }

  # replace NULLs
  if(is.null(sdgs)) sdgs = unique(stringr::str_extract(queries$sdg,"[:digit:]+") %>% as.numeric())

  #check query data
  if (!all(names(queries) %in% c("sdg", "query", "system"))) {
    stop(paste0("Variables 'sdg', 'query' and 'system' must be present in quries dataset."))
  }

  #handle selected SDGs
  if(any(!sdgs %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  sdgs = paste0("SDG-", ifelse(sdgs < 10, "0", ""),sdgs) %>% sort()

  #filter queries based on selected sdgs
  queries <- queries %>%
    dplyr::mutate(sdg = paste0("SDG-", ifelse(queries$sdg < 10, "0", ""),queries$sdg),
                  query_id = 1:dplyr::n()) %>%
    dplyr::filter(sdg %in% sdgs)


  # get hits
  hits = search_corpus(corpus, queries$query)

  # process hits
  hits = hits %>%
    dplyr::mutate(sdg = queries$sdg[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))],
                  query_id = as.numeric(stringr::str_extract(hits$code, '[:digit:]+')),
                  system = (queries %>% dplyr::pull(system, query_id))[query_id]) %>%
    dplyr::rename(document = doc_id) %>%
    dplyr::select(document, sdg, system, query_id, feature) %>%
    dplyr::group_by(document, sdg, system, query_id) %>%
    dplyr::summarize(features = toString(unique(feature %>% stringr::str_to_lower()))) %>%
    dplyr::group_by(system) %>%
    dplyr::mutate(hit = 1:dplyr::n()) %>%
    dplyr::ungroup() %>%
    suppressMessages()

    # reduce if requested
  if(output[1] == "documents"){
    v = hits %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(hits = dplyr::n()) %>%
      dplyr::ungroup()
  } else {
    if(output[1] != "features") stop('Argument output must be "features" or "docs"')
  }

  #convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(corpus$doc_id_levels)))

  #output
  hits %>%
    dplyr::arrange(document, sdg, system)


}



