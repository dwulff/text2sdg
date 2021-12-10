#' Detect SDGs in text
#'
#' \code{detect_sdg} identifies SDGs in text using SDG query systems developed by the Aurora Universities Network, SIRIS Academic, and Elsevier.
#'
#' \code{detect_sdg} implements five SDG query systems. Three systems developed by the Aurora Universities Network (see \code{\link{aurora_queries}}), SIRIS Academic (see \code{\link{siris_queries}}), and Elsevier (see \code{\link{elsevier_queries}}) rely on Lucene-style Boolean queries, whereas two query systems developed by OSDG (see \code{\link{osdg_queries}}) and SDSN (see \code{\link{sdsn_queries}}) rely on basic keyword matching. `detect_sdg` calls dedicated \code{detect_*} for each of the five system. Search of the queries is implemented using the \code{\link[corpustools]{search_features}} function from the \href{https://cran.r-project.org/package=corpustools}{\code{corpustools}} package.
#'
#' By default, \code{detect_sdg} runs only the Aurora, SIRIS, and Elsevier query systems, as they are considerably less liberal than the SDSN and OSDG systems and therefore likely produce more valid SDG classifications. Users should be aware that systematic validations and comparison between the systems are largely lacking and that results should be interpreted with caution.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param systems \code{character} vector specifying the query systems to be used. Can be one or more of \code{"Aurora"}, \code{"SIRIS"}, \code{"Elsevier"}, \code{"SDSN"}, and \code{"OSDG"}. By default all systems except \code{"OSDG"} and \code{"SDSN"} are used.
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the sdgs to identify in \code{text}. Defaults to \code{1:17}.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"documents"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the features.
#' @param verbose \code{logical} specifying whether messages on the function's progress should be printed.
#'
#' @return The function returns a tibble containing the SDG hits found in the vector of documents. Depending on the value of \code{output} the tibble will contain all or some of the following columns:
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
#' # run sdg detection
#' hits <- detect_sdg(projects)
#'
#' # run sdg detection with Aurora only
#' hits <- detect_sdg(projects, systems = "Aurora")
#'
#' # run sdg detection for sdg 3 only
#' hits <- detect_sdg(projects, sdgs = 3)
#' }
#' @export

detect_sdg = function(text,
                      systems = c("Aurora", "Elsevier", "SIRIS"),
                      sdgs = 1:17,
                      output = c("features","documents"),
                      verbose = TRUE){

  # make corpus
  if(class(text)[1] == "character"){
    corpus = make_corpus(text)
    } else if(class(text)[1] == "tCorpus"){
    corpus = text
    } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
    }

  #make output list
  hits = list()

  #handle selected SDGs
  if(any(!sdgs %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  sdgs = paste0("SDG-", ifelse(sdgs < 10, "0", ""),sdgs) %>% sort()

  # run sdg
  if (!all(systems %in% c("Aurora", "Elsevier", "SIRIS", "SDSN", "OSDG"))){
    stop("Argument systems must be Aurora, Elsevier, SIRIS, SDSN, or OSDG.")
    }
  if("Aurora" %in% systems){
    if(verbose) cat("\nRunning Aurora",sep = '')
    hits[["Aurora"]] = detect_aurora(corpus, sdgs)}
  if("SIRIS" %in% systems) {
    if(verbose) cat("\nRunning SIRIS",sep = '')
    hits[["SIRIS"]] = detect_siris(corpus, sdgs)}
  if("Elsevier" %in% systems){
    if(verbose) cat("\nRunning Elsevier",sep = '')
    hits[["Elsevier"]] = detect_elsevier(corpus, sdgs)}
  if("SDSN" %in% systems) {
    if(verbose) cat("\nRunning SDSN",sep = '')
    hits[["SDSN"]] = detect_sdsn(corpus, sdgs)}
  if("OSDG" %in% systems) {
    if(verbose) cat("\nRunning OSDG",sep = '')
    hits[["OSDG"]] = detect_osdg(corpus, sdgs)}

  #combine lists to df
  hits <- do.call(rbind, hits)

  #return empty tibble if no SDGs were detected
  if(is.null(hits)) return(tibble::tibble())



  # reduce if requested
  if(output[1] == "documents"){
    hits = hits %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(hits = dplyr::n()) %>%
      dplyr::ungroup()
    } else {
    if(output[1] != "features") stop('Argument output must be "features" or "documents"')
    }

  #convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(corpus$doc_id_levels)))

  #output
  hits %>%
    dplyr::arrange(document, sdg, system)

  }


