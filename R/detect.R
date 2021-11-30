#' Detect SDGs in text
#'
#' \code{detect_sdg} identifies SDGs in text using SDG query systems developed by the Aurora Universities Network, SIRIS Academic, and Elsevier.
#'
#' \code{detect_sdg} implements three SDG query systems developed by the Arora Universities Network (see \code{\link{aurora_queries}}), SIRIS Academic (see \code{\link{siris_queries}}), and Elsevier (see \code{\link{elsevier_queries}}), and one keyword-based system by Bautista-Puig and Mauleón labeled Ontology (see \code{\link{ontology_queries}}). `detect_sdg` calls dedicated \code{detect_*} for each of the four system. Search of the Lucene-style Boolean queries and the keywords is implemented using the \code{\link[corpustools]{search_features}} function from the \href{https://cran.r-project.org/package=corpustools}{\code{corpustools}} package.
#'
#' By default, \code{detect_sdg} runs only the three query systems, as they are considerably less liberal than the keyword-based Ontology and therefore likely produce more valid SDG classifications. Users should be aware that systematic validations and comparison between the systems are still largely lacking. Consequently, any results should be interpreted with a high level caution.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param systems \code{character} vector specifying the query systems to be used. Can be one or more of \code{"aurora"}, \code{"siris"}, \code{"elsevier"}, \code{"sdsn"}, and \code{"ontology"}. By default all but \code{"sdsn"} and \code{"ontology"} are used.
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
#' # run sdg detection with aurora only
#' hits <- detect_sdg(projects, systems = "aurora")
#'
#' # run sdg detection for sdg 3 only
#' hits <- detect_sdg(projects, sdgs = 3)
#' }
#' @export

detect_sdg = function(text, systems = c("aurora","siris","elsevier"), sdgs = 1:17, output = c("features","documents"), verbose = TRUE){

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
  if (!all(systems %in% c("aurora","elsevier","siris", "ontology", "sdsn"))){
    stop("Argument system must be aurora, elsevier, siris or ontology.")
    }
  if("aurora" %in% systems){
    if(verbose) cat("\nRunning aurora queries",sep = '')
    hits[["aurora"]] = detect_aurora(corpus, sdgs)}
  if("siris" %in% systems) {
    if(verbose) cat("\nRunning siris queries",sep = '')
    hits[["siris"]] = detect_siris(corpus, sdgs)}
  if("elsevier" %in% systems){
    if(verbose) cat("\nRunning elsevier queries",sep = '')
    hits[["elsevier"]] = detect_elsevier(corpus, sdgs)}
  if("ontology" %in% systems) {
    if(verbose) cat("\nRunning ontology queries",sep = '')
    hits[["ontology"]] = detect_ontology(corpus, sdgs)}
  if("sdsn" %in% systems) {
    if(verbose) cat("\nRunning sdsn queries",sep = '')
    hits[["sdsn"]] = detect_sdsn(corpus, sdgs)}

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


