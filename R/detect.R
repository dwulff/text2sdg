#' Detect SDGs
#'
#' Detect SDGs
#'
#' @param corpus object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

detect_sdg = function(..., system = c("aurora","elsevier"), out = c("features","docs"), verbose = TRUE){

  input = list(...)
  names(input) = paste0("source_",1:length(input))

  # run sdg
  hit_list = list()
  for(i in 1:length(input)){

    # keep track
    if(verbose) cat("\nRunning source ",i,"\n",sep = '')

    # make corpus
    corpus = make_corpus(input[[i]])

    # run sdg
    if(system[1] == "aurora"){
      if(verbose) cat("\tRunning aurora queries (might take a while..)\n",sep = '')
      hits = detect_aurora(corpus)
      } else if(system[1] == "elsevier"){
      if(verbose) cat("\tRunning elsevier queries (might take a while..)\n",sep = '')
      hits = detect_elsevier(corpus)
      } else {
      stop("system must be aurora or elsevier")
      }

    # reduce if requested
    if(out[1] == "docs"){
      hits = hits %>%
        dplyr::select(-code, -feature, -token_id, -hit_id) %>%
        unique()
      } else {
      if(out[1] != "features") stop("out must be features or docs")
      }

    # out
    hit_list[[i]] = hits %>%
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


