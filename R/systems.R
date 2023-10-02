#' Detect SDGs in text
#'
#' \code{detect_sdg_systems} identifies SDGs in text using multiple SDG query systems.
#'
#' \code{detect_sdg_systems} implements six SDG query systems. Four systems developed by the Aurora Universities Network (see \code{\link{aurora_queries}}),  Elsevier (see \code{\link{elsevier_queries}}), Auckland University (see \code{\link{elsevier_queries}}), and SIRIS Academic (see \code{\link{siris_queries}}) rely on Lucene-style Boolean queries, whereas two systems, namely SDGO (see \code{\link{sdgo_queries}}) and SDSN (see \code{\link{sdsn_queries}}) rely on basic keyword matching. `detect_sdg_systems` calls dedicated \code{detect_*} for each of the five system. Search of the queries is implemented using the \code{\link[corpustools]{search_features}} function from the \href{https://cran.r-project.org/package=corpustools}{\code{corpustools}} package.
#'
#' By default, \code{detect_sdg_systems} runs only the Aurora, Elsevier, Auckland, and Siris query systems, as they are considerably less liberal than the SDSN and SDGO systems and therefore likely produce more valid SDG classifications. Users should be aware that systematic validations and comparison between the systems are largely lacking and that results should be interpreted with caution.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param systems \code{character} vector specifying the query systems to be used. Can be one or more of \code{"Aurora"}, \code{"Elsevier"}, \code{"Auckland"}, \code{"SIRIS"} \code{"SDSN"}, and \code{"SDGO"}. By default all systems except \code{"SDGO"} and \code{"SDSN"} are used.
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the sdgs to identify in \code{text}. Defaults to \code{1:17}.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"documents"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the features.
#' @param verbose \code{logical} specifying whether messages on the function's progress should be printed.

#' @return The function returns a \code{tibble} containing the SDG hits found in the vector of documents. The columns of the \code{tibble} depend on the value of \code{output}. Possible columns are:
#' \describe{
#'  \item{document}{Index of the element in \code{text} where match was found. Formatted as a factor with the number of levels matching the original number of documents.}
#'  \item{sdg}{Label of the SDG found in document.}
#'  \item{system}{The name of the query system that produced the match.}
#'  \item{query_id}{Index of the query within the query system that produced the match.}
#'  \item{features}{Concatenated list of words that caused the query to match.}
#'  \item{hit}{Index of hit for a given system.}
#'  \item{n_hits}{Number of queries that produced a hit for a given system, sdg, and document.}
#' }
#'
#' @examples
#' \donttest{
#' # run sdg detection
#' hits <- detect_sdg_systems(projects)
#'
#' # run sdg detection with Aurora only
#' hits <- detect_sdg_systems(projects, systems = "Aurora")
#'
#' # run sdg detection for sdg 3 only
#' hits <- detect_sdg_systems(projects, sdgs = 3)
#' }
#' @export

detect_sdg_systems <- function(text,
                               systems = c("Aurora", "Elsevier", "Auckland", "SIRIS"),
                               sdgs = 1:17,
                               output = c("features", "documents"),
                               verbose = TRUE) {
  # make corpus
  if (inherits(text, "character")) {
    if (length(text) == 1 && text == "") {
      stop("Argument text must not be an empty string.")
    }
    corpus <- make_corpus(text)
  } else if (inherits(text, "tCorpus")) {
    corpus <- text
  } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
  }

  # make output list
  hits <- list()

  # handle selected SDGs
  if (any(!sdgs %in% 1:17)) stop("sdgs can only take numbers in 1:17.")
  sdgs <- paste0("SDG-", ifelse(sdgs < 10, "0", ""), sdgs) %>% sort()
  if ("OSDG" %in% systems) {
    stop("OSDG has been renamed to SDGO (SDG Ontology).")
  }

  # check systems Argument
  if (!all(systems %in% c("Aurora", "Elsevier", "Auckland", "SIRIS", "SDSN", "SDGO"))) {
    stop("Argument systems must be Aurora, Elsevier, Auckland, SIRIS, SDSN, or SDGO.")
  }

  # check output argument
  if (!output[1] %in% c("features", "documents")) stop('Argument output must be "features" or "documents"')

  # run sdg
  if ("Aurora" %in% systems) {
    if (verbose) cat("Running Aurora", sep = "")
    hits[["Aurora"]] <- detect_aurora(corpus, sdgs)
  }
  if ("Elsevier" %in% systems) {
    if (verbose) cat("\nRunning Elsevier", sep = "")
    hits[["Elsevier"]] <- detect_elsevier(corpus, sdgs)
  }
  if ("Auckland" %in% systems) {
    if (verbose) cat("\nRunning Auckland", sep = "")
    hits[["Auckland"]] <- detect_auckland(corpus, sdgs)
  }
  if ("SIRIS" %in% systems) {
    if (verbose) cat("\nRunning SIRIS", sep = "")
    hits[["SIRIS"]] <- detect_siris(corpus, sdgs)
  }
  if ("SDSN" %in% systems) {
    if (verbose) cat("\nRunning SDSN", sep = "")
    hits[["SDSN"]] <- detect_sdsn(corpus, sdgs)
  }
  if ("SDGO" %in% systems) {
    if (verbose) cat("\nRunning SDGO", sep = "")
    hits[["SDGO"]] <- detect_sdgo(corpus, sdgs)
  }


  # newline
  cat("\n")
  # combine lists to df
  hits <- dplyr::bind_rows(hits)

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

  # reduce if requested
  if (output[1] == "documents") {
    hits <- hits %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(
        n_hit = dplyr::n(),
        features = paste(features, collapse = ", ")
      ) %>%
      dplyr::ungroup()
  }

  # convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(corpus$doc_id_levels)))

  # output
  hits %>%
    dplyr::arrange(document, sdg, system)
}
