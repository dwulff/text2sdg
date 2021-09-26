#' Detect SDGs in text with own query system
#'
#' \code{detect_any} identifies SDGs in text using user provided query systems. Works like \code{\link{detect_sdg}} but uses a user specified query system instead of an existing one like \code{\link{detect_sdg}} does.
#'
#'
#'
#' @param text \code{character} vector or object of class \code{tCorpus} containing text in which SDGs shall be detected.
#' @param queries a data frame that must contain the following variables: a \code{character} vector with queries, a \code{integer} vector specifying which SDG each query maps to (values must be between 1 and 17) and a \code{character} with one unique value specifying the name of the used query system (can be anything as long as it is unique).
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the sdgs to identify in \code{text}. Defaults to \code{1:17}.
#' @param output \code{character} specifying the level of detail in the output. The default \code{"features"} returns a \code{tibble} with one row per matched query, include a variable containing the features of the query that were matched in the text. By contrast, \code{"docs"} returns an aggregated \code{tibble} with one row per matched sdg, without information on the features.
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
#'
#' # create data frame with query system
#' own_query_system_df <- tibble::tibble(sdg = c(1,2,3,3), query = c("Past analyses", "Results", "clarity ", "higher"), system = rep("own_sytem", 4))
#'
#' # run sdg detection with own query system
#' hits <- detect_any(abstracts, own_query_system_df)
#'
#' # run sdg detection for sdg 3 only
#' hits <- detect_any(abstracts, own_query_system_df, sdgs = 3)
#'
#'
#' @export

detect_any <- function(text, queries, sdgs = 1:17, output = c("features","docs"), verbose = TRUE) {


  # make corpus
  if(class(text)[1] == "character"){
    corpus = make_corpus(text)
  } else if(class(text)[1] == "tCorpus"){
    corpus = text
  } else {
    stop("Argument text must be either class character or corpustools::tCorpus.")
  }

  #check query data
  if (!names(queries) %in% c("sdg", "query", "system")) {

    stop(paste0("Variables 'sdg', 'query' and 'system' must be present in quries dataset."))

  }

  if (length(unique(queries$system)) != 1) stop("'system' variable in queries dataset must be unique (i.e., only one system per dataset).")



  #system name
  system_name <- unique(queries$system)

  #handle selected SDGs
  if(any(!sdgs %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  sdgs = paste0("SDG-", ifelse(sdgs < 10, "0", ""),sdgs) %>% sort()


  queries$sdg = paste0("SDG-", ifelse(queries$sdg < 10, "0", ""),queries$sdg)

  #filter queries based on selected sdgs
  queries <- queries %>%
    dplyr::filter(sdg %in% sdgs)




  # get hits
  hits = search_corpus(corpus, queries$query)
  hits$sdg = queries$sdg[as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))]
  hits$query_id = as.numeric(stringr::str_extract(hits$code, '[:digit:]+'))


  #out
  hits <- hits %>%
    #todo: remove ID from query string?
    dplyr::select(-sentence) %>%
    dplyr::mutate(document = as.numeric(as.character(doc_id)),
                  feature = as.character(feature),
                  system = system_name) %>%
    dplyr::group_by(document, query_id) %>%
    #paste features together
    dplyr::summarise(number_of_matches = dplyr::n(),
                     features = toString(unique(feature)),
                     dplyr::across(c(sdg, system), unique)) %>%
    dplyr::ungroup() %>%
    #add hit id
    dplyr::mutate(hit = 1:dplyr::n()) %>%
    dplyr::select(document, sdg, system, query_id, features, hit) %>%
    dplyr::arrange(document, sdg, query_id)





    # reduce if requested
  if(output[1] == "docs"){
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

#own_queries
queries <- tibble::tibble(sdg = c(1,2,3,3), query = c("Past analyses", "Results", "clarity ", "higher"), system = rep("own_sytem", 4))


# detect_any(test_txt, own_queries)
# #
# # class(test_txt[1])
# text = test_txt
# queries = own_queries



