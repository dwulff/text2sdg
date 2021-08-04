#' Plot SDGs
#'
#' Plot SDGs
#'
#' @param data object of class \code{tCorpus} containing text.
#' @param verbose logical.
#'
#' @export

plot_sdg = function(data,
                    show_sdg = 1:17,
                    show_system = c("aurora","elsevier","siris"),
                    color = "unibas"){

  # check if columns present
  required_columns = c("sdg","system")
  if(any(!required_columns %in% names(data))){
    missing = required_columns[!required_columns %in% names(data)]
    stop(paste0("Data must include columns [",paste0(missing, collapse=", "),"]."))
  }

  # check sdg and system
  if(any(!show_sdg %in% 1:17)) stop("show_sdg can only take numbers in 1:17.")
  if(any(!show_system %in% data$system)){
    stop(paste0("Data only contains systems [",paste0(unique(data$system), collapse = ", "),"]."))
    }

  # handle colors
  if(color[1] == "unibas"){
    color = c("#D2EBE9","#A5D7D2","#46505A")
    }
  if(length(color) != length(show_system)){
    color = grDevices::colorRampPalette(color)(length(show_system))
  }

  # hadnle sdgs
  sdgs = paste0("SDG-", ifelse(show_sdg < 10, "0", ""),show_sdg) %>% sort()

  # generate plot
  plot = data %>%
    dplyr::filter(sdg %in% sdgs,
                  system %in% show_system) %>%
    dplyr::mutate(sdg = factor(sdg, levels = sdgs),
                  system = factor(stringr::str_to_title(system),
                                  levels = stringr::str_to_title(show_system))) %>%
    ggplot2::ggplot(mapping = ggplot2::aes(x = sdg, fill = system)) +
    ggplot2::geom_bar() +
    ggplot2::scale_x_discrete(drop=FALSE) +
    ggplot2::scale_fill_manual(name="Query\nsystem", values = color) +
    ggplot2::theme_minimal() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1),
                   axis.title.x = ggplot2::element_blank()) +
    ggplot2::labs(y = "Frequency")

  # output plot
  plot
  }



