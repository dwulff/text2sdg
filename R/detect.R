#' Detect SDGs
#'
#' Detect SDGs
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

detect_sdg = function(..., system = c("aurora","elsevier","siris"), out = c("features","docs"), verbose = TRUE){

  input = list(...)
  names(input) = paste0("source_",1:length(input))

  # run sdg
  hit_list = list()
  for(i in 1:length(input)){

    # keep track
    if(verbose) cat("\nRunning source ",i,"\n",sep = '')

    # make corpus
    if(class(input[[i]])[1] != "tCorpus"){
      corpus = make_corpus(input[[i]])
      } else {
      corpus = input[[i]]
      }

    #make output list
    hits = list()

    # run sdg
    if("aurora" %in% system){
      if(verbose) cat("\tRunning aurora queries\n",sep = '')
      hits_aurora = detect_aurora(corpus)
      hits[["aurora"]] <- hits_aurora }
    if("elsevier" %in% system){
      if(verbose) cat("\tRunning elsevier queries\n",sep = '')
      hits_elsevier = detect_elsevier(corpus)
      hits[["elsevier"]] <- hits_elsevier}
    if("siris" %in% system) {
      if(verbose) cat("\tRunning siris queries\n",sep = '')
      hits_siris = detect_siris(corpus)
      hits[["siris"]] <- hits_siris}
    if("ontology" %in% system) {
      if(verbose) cat("\tRunning ontology queries\n",sep = '')
      hits_ontology = detect_ontology(corpus)
      hits[["ontology"]] <- hits_ontology}
    if (!any(system %in% c("aurora","elsevier","siris", "ontology"))){
      stop("system must be aurora, elsevier, siris or ontology")
      }

    #combine lists to df
    hits_df <- do.call(rbind, hits)

    # reduce if requested
    if(out[1] == "docs"){
      hits_df = hits_df %>%
        dplyr::group_by(document, sdg, system) %>%
        dplyr::summarize(hits = dplyr::n()) %>%
        dplyr::ungroup()
      } else {
      if(out[1] != "features") stop("out must be features or docs")
      }

    # out
    hit_list[[i]] <- hits_df %>% dplyr::mutate(source = names(input[i]))

  }

  # combine
  hits <- do.call(rbind, hit_list)

  #convert document to factor for downstream functions
  hits <- hits %>%
    dplyr::mutate(document = factor(document, levels = 1:length(unlist(input))))


  # out
  hits %>%
    dplyr::arrange(document, sdg, system)

  }


