#' Detect SDGs in text
#'
#' \code{detect_sdg} identifies SDGs in text using SDG query systems developed by the Aurora Universities Network, SIRIS Academic, and Elsevier.
#'
#' \code{detect_sdg} implements three SDG query systems developed by the Arora Universities Network (see \code{\link{aurora_queries}}), SIRIS Academic (see \code{\link{siris_queries}}), and Elsevier (see \code{\link{elsevier_queries}}), and one keyword-based system by Bautista-Puig and Mauleón labeled Ontology (see \code{\link{ontology_queries}}). `detect_sdg` calls dedicated \code{detect_*} for each of the four system. Search of the Lucene-style Boolean queries and the keywords is implemented using the \code{\link[corpustools]{search_features}} function from the \href{https://cran.r-project.org/package=corpustools}{\code{corpustools}} package.
#'
#' By default, \code{detect_sdg} runs only the three query systems, as they are considerably less liberal than the keyword-based Ontology and therefore likely produce more valid SDG classifications. Users should be aware that systematic validations and comparison between the systems are still largely lacking. Consequently, any results should be interpreted with a high level caution.
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param system \code{character} vector specifying the query systems to be used. Can be one or more of \code{"aurora"}, \code{"siris"}, \code{"elsevier"}, and \code{"ontology"}. By deafult all but \code{"ontology"} are used.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"docs"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the featurs.
#' @param verbose \code{logical} specifying whether messages on the function's progress should be printed.
#'
#' @return The function returns a tibble containing the SDG hits found in the vector of documents. Depending on the value of \code{output} the tibble will contain all or some of the following columns:
#' \describe{
#'  \item{document}{Index of the element in \code{text} where match was found.}
#'  \item{sdg}{Label of the SDG found in document.}
#'  \item{system}{The name of the query system that produced the match.}
#'  \item{query_id}{Index of the query within the query system that produced the match.}
#'  \item{features}{Concatenated list of words that caused the query to match.}
#'  \item{hit}{Index of hit for a given system.}
#' }
#'
#'
#'
#' @export

detect_sdg = function(text, system = c("aurora","siris","elsevier"), output = c("features","docs"), verbose = TRUE){

  # make corpus
  if(class(text) == "character"){
    corpus = make_corpus(text)
    } else if(class(text) == "tCorpus"){
    corpus = input[[i]]
    } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
    }

  #make output list
  hits = list()

  # run sdg
  if (!all(system %in% c("aurora","elsevier","siris", "ontology"))){
    stop("Argument system must be aurora, elsevier, siris or ontology.")
    }
  if("aurora" %in% system){
    if(verbose) cat("Running aurora queries\n",sep = '')
    hits[["aurora"]] = detect_aurora(corpus)}
  if("siris" %in% system) {
    if(verbose) cat("Running siris queries\n",sep = '')
    hits[["siris"]] = detect_siris(corpus)}
  if("elsevier" %in% system){
    if(verbose) cat("Running elsevier queries\n",sep = '')
    hits[["elsevier"]] = detect_elsevier(corpus)}
  if("ontology" %in% system) {
    if(verbose) cat("Running ontology queries\n",sep = '')
    hits[["ontology"]] = detect_ontology(corpus)}

  #combine lists to df
  hits <- do.call(rbind, hits)

  # reduce if requested
  if(output[1] == "docs"){
    v = hits_df %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(hits = dplyr::n()) %>%
      dplyr::ungroup()
    } else {
    if(output[1] != "features") stop('Argument output must be "features" or "docs"')
    }

  #convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(unlist(input))))

  #output
  hits %>%
    dplyr::arrange(document, sdg, system)

  }


