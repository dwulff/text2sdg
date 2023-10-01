#' Detect SDGs in text with own query system
#'
#' \code{detect_any} identifies SDGs in text using user provided query systems. Works like \code{\link{detect_sdg_systems}} but uses a user specified query system instead of an existing one like \code{\link{detect_sdg_systems}} does.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param system a data frame that must contain the following variables: a \code{character} vector with queries, a \code{integer} vector specifying which SDG each query maps to (values must be between 1 and 17) and a \code{character} with one unique value specifying the name of the used query system (can be anything as long as it is unique).
#' @param queries deprecated.
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the sdgs to identify in \code{text}. Defaults to \code{1:17}.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"documents"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the features.
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
#' \donttest{
#' # create data frame with query system
#' my_queries <- tibble::tibble(
#'   system = "my_system",
#'   query = c(
#'     "theory",
#'     "analysis OR analyses OR analyzed",
#'     "study AND hypothesis"
#'   ),
#'   sdg = c(1, 2, 2)
#' )
#'
#' # run sdg detection with own query system
#' hits <- detect_any(projects, my_queries)
#'
#' # run sdg detection for sdg 2 only
#' hits <- detect_any(projects, my_queries, sdgs = 2)
#' }
#'
#' @export

detect_any <- function(text, system, queries = lifecycle::deprecated(), sdgs = NULL, output = c("features", "documents"), verbose = TRUE) {


  # deprecated warning
  if (lifecycle::is_present(queries)) {
    lifecycle::deprecate_warn("0.1.5", "detect_any(queries)", "detect_any(system)")
    system <- queries
  }


  # make corpus
  if (class(text)[1] == "character") {
    if (length(text) == 1 && text == "") {
      stop("Argument text must not be an empty string.")
    }
    corpus <- make_corpus(text)
  } else if (class(text)[1] == "tCorpus") {
    corpus <- text
  } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
  }

  # replace NULLs
  if (is.null(sdgs)) sdgs <- unique(stringr::str_extract(system$sdg, "[:digit:]+") %>% as.numeric())

  # check that selected subset of sdgs is in queries
  if (all(!sdgs %in% unique(system$sdg))) {
    stop("At least one of the selected SDGs needs to be present in the queries data frame.")
  }

  # check query data
  if (!all(names(system) %in% c("sdg", "query", "system"))) {
    stop(paste0("Variables 'sdg', 'query' and 'system' must be present in quries dataset."))
  }

  # check output argument
  if (!output[1] %in% c("features", "documents")) stop('Argument output must be "features" or "documents"')

  # handle selected SDGs
  if (any(!sdgs %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  sdgs <- paste0("SDG-", ifelse(sdgs < 10, "0", ""), sdgs) %>% sort()



  # filter queries based on selected sdgs
  system <- system %>%
    dplyr::mutate(
      sdg = paste0("SDG-", ifelse(sdg < 10, "0", ""), sdg),
      query_id = 1:dplyr::n()
    ) %>%
    dplyr::filter(sdg %in% sdgs)


  # get hits
  hits <- search_corpus(corpus, system$query)

  # return empty tibble if no SDGs were detected
  if (nrow(hits) == 0) {
    return(tibble::tibble(
      document = factor(),
      sdg = character(),
      system = character(),
      query_id = integer(),
      features = character(),
      hit = integer()
    ))
  }

  # process hits
  hits <- hits %>%
    dplyr::mutate(
      sdg = system$sdg[as.numeric(stringr::str_extract(hits$code, "[:digit:]+"))],
      query_id = as.numeric(stringr::str_extract(hits$code, "[:digit:]+")),
      system = (system %>% dplyr::pull(system, query_id))[query_id]
    ) %>%
    dplyr::rename(document = doc_id) %>%
    dplyr::select(document, sdg, system, query_id, feature) %>%
    dplyr::group_by(document, sdg, system, query_id) %>%
    dplyr::summarize(features = toString(unique(feature %>% stringr::str_to_lower()))) %>%
    dplyr::group_by(system) %>%
    dplyr::mutate(hit = 1:dplyr::n()) %>%
    dplyr::ungroup() %>%
    suppressMessages()

  # reduce if requested
  if (output[1] == "documents") {
    hits <- hits %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(hits = dplyr::n()) %>%
      dplyr::ungroup()
  }

  # convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(corpus$doc_id_levels)))

  # output
  hits %>%
    dplyr::arrange(document, sdg, system)
}
