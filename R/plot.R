#' Plot distributions of SDGs identified in text
#'
#' \code{plot_sdg} creates a (stacked) barplot of the frequency distribution of SDGs identified via \link{detect_sdg}.
#'
#' The function is built using \code{\link[ggplot2]{ggplot}} and can thus be flexibly extended. See examples.
#'
#' @param hits \code{data frame} as returned by \code{\link{detect_sdg}}. Must include columns \code{sdg} and \code{system}.
#' @param systems \code{character} vector specifying the query systems to be visualized. Values must be available in the \code{system} column of \code{hits}. \code{systems} of length greater 1 result, by default, in a stacked barplot. Defaults to \code{NULL} in which case available values are retrieved from \code{hits}.
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the SDGs to be visualized. Values must be available in the \code{sdg} column of \code{hits}. Defaults to \code{NULL} in which case available values are retrieved from \code{hits}.
#' @param normalize \code{character} specifying whether results should be presented as frequencies (\code{normalize = "none"}), the default, or whether the frequencies should be normalized using either the total frequencies of each system (\code{normalize = "systems"}) or the total number of documents (\code{normalize = "documents"}).
#' @param color \code{character} vector used to color the bars according to systems. The default, \code{"unibas"}, uses three colors of University of Basel's corporate design. Alternatively, \code{color} must specified using \link{color} names or color hex values. \code{color} will be interpolated to match the length of \code{systems}.
#' @param sdg_titles \code{logical} specifying whether the titles of the SDG should added to the axis annotation.
#' @param remove_duplicates \code{logical} specifying the handling of multiple hits of the same SDG for a given document and system. Defaults to \code{TRUE} implying that no more than one hit is counted per SDG, system, and document.
#' @param ... arguments passed to \code{\link[ggplot2]{geom_bar}}.
#'
#' @return The function returns a \code{\link[ggplot2]{ggplot}} object that can either be stored in an object or printed to produce the plot.
#'
#' @examples
#' \donttest{
#' # run sdg detection
#' hits <- detect_sdg(projects)
#'
#' # create barplot
#' plot_sdg(hits)
#'
#' # create barplot with facets
#' plot_sdg(hits) + ggplot2::facet_wrap(~system)
#' }
#'
#' @export
plot_sdg = function(hits,
                    systems = NULL,
                    sdgs = NULL,
                    normalize = "none",
                    color = "unibas",
                    sdg_titles = FALSE,
                    remove_duplicates = TRUE,
                    ...){

  # check if columns present
  required_columns = c("sdg","system")
  if(any(!required_columns %in% names(hits))){
    missing = required_columns[!required_columns %in% names(hits)]
    stop(paste0("Data object must include columns [",paste0(missing, collapse=", "),"]."))
  }

  # replace NULLs
  if(is.null(systems)) systems = hits %>% dplyr::arrange(system) %>% dplyr::pull(system) %>% as.character() %>% unique()
  if(is.null(sdgs)) sdgs = unique(stringr::str_extract(hits$sdg,"[:digit:]{2}") %>% as.numeric())

  # check sdg and system
  if(any(!sdgs %in% 1:17)) stop("sdgs can only take numbers in 1:17.")
  if(any(!systems %in% hits$system)){
    stop(paste0("Data object only contains systems [",paste0(unique(hits$system), collapse = ", "),"]."))
    }

  # handle duplicates
  duplicates = hits %>% dplyr::select(document, sdg, system) %>% duplicated()
  if(any(duplicates) & remove_duplicates == TRUE){
    hits = hits %>% dplyr::filter(!duplicates)
    message(paste0(sum(duplicates)," duplicate hits removed. Set remove_duplicates = FALSE to retain duplicates."))
  }

  # extract number of documents
  n_documents = length(levels(hits$document))

  # handle colors
  if(color[1] == "unibas"){
    color = c("#D2EBE9","#A5D7D2","#46505A")
    }
  if(length(color) != length(systems)){
    color = grDevices::colorRampPalette(color)(length(systems))
  }

  # handle sdgs
  sdgs = paste0("SDG-", ifelse(sdgs < 10, "0", ""),sdgs) %>% sort()

  # prepare data
  hits = hits %>%
    dplyr::filter(sdg %in% sdgs,
                  system %in% systems) %>%
    dplyr::mutate(sdg = factor(sdg, levels = sdgs),
                  system = factor(system))

  # change to titles
  if(sdg_titles == TRUE){
    sdg_titles = aurora_queries %>%
      dplyr::mutate(sdg_title = stringr::str_to_title(sdg_title)) %>%
      dplyr::select(sdg, sdg_title) %>%
      unique() %>%
      dplyr::arrange(sdg) %>%
      dplyr::pull(sdg_title, sdg)
    hits = hits %>%
      dplyr::mutate(sdg = factor(sdg_titles[sdg], levels = sdg_titles))
    }

  # get frequencies
  hits = hits %>%
    dplyr::group_by(system, sdg) %>%
    dplyr::summarize(n = dplyr::n()) %>%
    dplyr::ungroup()
  y_label = "Frequency"

  # transform to proportions
  if(normalize[1] != "none"){
    if(normalize[1] == "systems"){
      hits = hits %>%
        dplyr::group_by(system) %>%
        dplyr::mutate(n = n / sum(n)) %>%
        dplyr::ungroup()
    } else if(normalize[1] == "documents"){
      hits = hits %>%
        dplyr::group_by(system) %>%
        dplyr::mutate(n = n / n_documents) %>%
        dplyr::ungroup()
    } else {
      stop('Argument normalize must the "none", "systems", or "documents".')
    }
    y_label = "Proportion"
  }

  # generate plot
  plot = hits %>%
    ggplot2::ggplot(mapping = ggplot2::aes(x = sdg, y = n, fill = system)) +
    ggplot2::geom_bar(..., stat = "identity") +
    ggplot2::scale_x_discrete(drop=FALSE) +
    ggplot2::scale_fill_manual(name="Query\nsystem", values = color) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                   axis.title.x = ggplot2::element_blank()) +
    ggplot2::labs(y = y_label)

  # output plot
  plot
  }



