#' Detect SDGs
#'
#' Detect SDGs
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

detect_sdg = function(..., system = c("aurora","elsevier","siris", "ontology"), out = c("features","docs"), verbose = TRUE){

  input = list(...)
  names(input) = paste0("source_",1:length(input))
  # run sdg
  hit_list = list()
  for(i in 1:length(input)){

    # keep track
    if(verbose) cat("\nRunning source ",i,"\n",sep = '')

    # make corpus
    corpus = make_corpus(input[[i]])

    #make output list
    hits = list()

    # run sdg
    if("aurora" %in% system){
      if(verbose) cat("\tRunning aurora queries (might take a while..)\n",sep = '')
      hits_aurora = detect_aurora(corpus)
      hits[["aurora"]] <- hits_aurora }
    if("elsevier" %in% system){
      if(verbose) cat("\tRunning elsevier queries (might take a while..)\n",sep = '')
      hits_elsevier = detect_elsevier(corpus)
      hits[["elsevier"]] <- hits_elsevier}
    if("siris" %in% system) {
      if(verbose) cat("\tRunning siris queries (might take a while..)\n",sep = '')
      hits_siris = detect_siris(corpus)
      hits[["siris"]] <- hits_siris}
    if("ontology" %in% system) {
      if(verbose) cat("\tRunning ontology queries (might take a while..)\n",sep = '')
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
        dplyr::select(-query_id, -features, -hit) %>%
        #TODO: THIS STILL GETS RID OF SOME DUPLICATES -> SOME QUERIES ARE NOT UNIQUE (E.G., "WOMEN")
        unique()
      } else {
      if(out[1] != "features") stop("out must be features or docs")
      }




    # out
    hit_list[[i]] = hits_df %>%
      dplyr::mutate(hit_code = get_code(.),
             source = names(input[i]))

  }

  # combine
  hits = do.call(rbind, hit_list)

  # check double
  hits %>%
    dplyr::group_by(hit_code) %>%
    dplyr::mutate(source = paste0(source, collapse=',')) %>%
    dplyr::slice(1) %>%
    dplyr::ungroup() %>%
    dplyr::select(-hit_code) %>%
    dplyr::arrange(doc_id)

  }


