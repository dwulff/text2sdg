#' Detect SDGs in text
#'
#' `detect_sdg` identifies SDGs in text using the Aurora, Elsevier, and Siris query systems.
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

detect_sdg = function(text, system = c("aurora","elsevier","siris"), out = c("features","docs"), verbose = TRUE){

  if(class())

  # make corpus
  if(class(text) != "tCorpus"){
    corpus = make_corpus(input[[i]])
    } else {
    corpus = input[[i]]
    }

  #make output list
  hits = list()

  # run sdg
  if("aurora" %in% system){
    if(verbose) cat("Running aurora queries\n",sep = '')
    hits_aurora = detect_aurora(corpus)
    hits[["aurora"]] <- hits_aurora }
  if("elsevier" %in% system){
    if(verbose) cat("Running elsevier queries\n",sep = '')
    hits_elsevier = detect_elsevier(corpus)
    hits[["elsevier"]] <- hits_elsevier}
  if("siris" %in% system) {
    if(verbose) cat("Running siris queries\n",sep = '')
    hits_siris = detect_siris(corpus)
    hits[["siris"]] <- hits_siris}
  if("ontology" %in% system) {
    if(verbose) cat("Running ontology queries\n",sep = '')
    hits_ontology = detect_ontology(corpus)
    hits[["ontology"]] <- hits_ontology}
  if (!any(system %in% c("aurora","elsevier","siris", "ontology"))){
    stop("system must be aurora, elsevier, siris or ontology")
    }

  #combine lists to df
  hits <- do.call(rbind, hits)

  # reduce if requested
  if(out[1] == "docs"){
    v = hits_df %>%
      dplyr::group_by(document, sdg, system) %>%
      dplyr::summarize(hits = dplyr::n()) %>%
      dplyr::ungroup()
    } else {
    if(out[1] != "features") stop("out must be features or docs")
    }

  #convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(unlist(input))))


  # out
  hits %>%
    dplyr::arrange(document, sdg, system)

  }


