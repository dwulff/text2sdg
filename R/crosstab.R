#' Compare query systems and SDGs
#'
#' \code{crosstab_sdg} calculates cross tables (aka contingency tables) of SGSs or systems across hits identified via \link{detect_sdg_systems}.
#'
#' \code{crosstab_sdg} determines correlations between either query systems or SDGs. The respectively other dimension will be ignored. Note that correlations between SDGs may vary between query systems.
#'
#' @param hits \code{data frame} as returned by \code{\link{detect_sdg_systems}}. Must include columns \code{document}, \code{sdg}, \code{system}, and \code{hit}.
#' @param compare \code{character} specifying whether systems or SDGs should be cross tabulated.
#' @param systems \code{character} vector specifying the query systems to be cross tabulated. Values must be available in the \code{system} column of \code{hits}. Defaults to \code{NULL} in which case available values are retrieved from \code{hits}.
#' @param sdgs \code{numeric} vector with integers between 1 and 17 specifying the SDGs to be cross tabluated. Values must be available in the \code{sdg} column of \code{hits}. Defaults to \code{NULL} in which case available values are retrieved from \code{hits}.
#'
#' @return \code{matrix} showing correlation coefficients for all pairs of query systems (if \code{compare = "systems"}) or SDGs (if \code{compare = "SDGs"}).
#'
#' @examples
#' \donttest{
#' # run sdg detection
#' hits <- detect_sdg_systems(projects)
#'
#' # create cross table of systems
#' crosstab_sdg(hits)
#'
#' # create cross table of systems
#' crosstab_sdg(hits, compare = "sdgs")
#' }
#' @export
crosstab_sdg <- function(hits,
                         compare = c("systems", "sdgs"),
                         systems = NULL,
                         sdgs = NULL) {


  # check if columns present
  required_columns <- c("document", "sdg", "system")
  if (any(!required_columns %in% names(hits))) {
    missing <- required_columns[!required_columns %in% names(hits)]
    stop(paste0("Data object must include columns [", paste0(missing, collapse = ", "), "]."))
  }

  # check if any hits are present
  if (nrow(hits) == 0) {
    stop("Hits data frame seems not to contain any hits, cross tabulation thus not possible.")
  }

  # replace NULLs
  if (is.null(systems)) {
    systems <- hits %>%
      dplyr::arrange(system) %>%
      dplyr::pull(system) %>%
      as.character() %>%
      unique()
  }
  if (is.null(sdgs)) sdgs <- unique(stringr::str_extract(hits$sdg, "[:digit:]{2}") %>% as.numeric())

  # check compare
  if (!compare[[1]] %in% c("systems", "sdgs")) {
    stop("compare must be either 'systems' or 'sdgs'.")
  }

  # check sdg and system
  if (any(!sdgs %in% 1:17)) stop("sdgs can only take numbers in 1:17.")
  if (any(!systems %in% hits$system)) {
    stop(paste0("Data only contains systems [", paste0(unique(hits$system), collapse = ", "), "]."))
  }
  if (compare[[1]] == "systems") {
    if (length(unique(systems)) < 2) {
      stop("Argument systems must have, at least, two c values.")
    }
    if (any(!systems %in% hits$system)) {
      stop(paste0("Values [", paste0(system[!systems %in% hits$system], collapse = ", "), "] for argument systems not found in column system of data."))
    }
  } else {
    if (length(unique(sdgs)) < 2) {
      stop("Argument sdgs must have, at least, two distinct values.")
    }
  }

  # handle duplicates
  hits <- hits %>% dplyr::distinct(document, sdg, system)

  # handle selected sdgs
  sdgs <- paste0("SDG-", ifelse(sdgs < 10, "0", ""), sdgs) %>% sort()

  # filter and process systems
  hits <- hits %>%
    dplyr::filter(
      sdg %in% sdgs,
      system %in% systems
    )

  # abort if no hits left
  if (nrow(hits) == 0) {
    stop(paste0("There are no hits matching the combination of sdgs = [", paste0(sdgs, collapse = ", "), "] and systems = [", paste0(systems, collapse = ", ")))
  }

  # do systems
  if (compare[[1]] == "systems") {

    # do something
    phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = systems, sdg = sdgs) %>%
      dplyr::mutate(document = as.factor(document)) %>%
      dplyr::left_join(hits %>%
        dplyr::mutate(hit = 1) %>%
        dplyr::select(document, system, sdg, hit),
      by = c("document", "system", "sdg")
      ) %>%
      dplyr::mutate(hit = dplyr::if_else(is.na(hit), 0, 1)) %>%
      dplyr::distinct() %>%
      dplyr::arrange(document, sdg) %>%
      tidyr::pivot_wider(names_from = system, values_from = hit) %>%
      `[`(, -(1))

    # do something
    correlations <- phi_dat %>%
      dplyr::select(-sdg) %>%
      cor(.) %>%
      suppressWarnings()

    # reorder
    correlations <- correlations[systems, systems]
  } else {

    # do something
    phi_dat <- tidyr::expand_grid(document = 1:length(levels(hits$document)), system = systems, sdg = sdgs) %>%
      dplyr::mutate(document = as.factor(document)) %>%
      dplyr::left_join(hits %>%
        dplyr::mutate(hit = 1),
      dplyr::select(document, system, sdg, hit),
      by = c("document", "system", "sdg")
      ) %>%
      dplyr::mutate(hit = dplyr::if_else(is.na(hit), 0, 1)) %>%
      dplyr::distinct() %>%
      dplyr::arrange(document, sdg) %>%
      tidyr::pivot_wider(names_from = sdg, values_from = hit) %>%
      `[`(, -(1))

    # run correlations
    correlations <- phi_dat %>%
      dplyr::select(-system) %>%
      cor(.) %>%
      suppressWarnings()
  }

  # out
  correlations
}
