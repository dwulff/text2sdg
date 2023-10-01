#' Detecting UN Sustainable Development Goals in Text
#'
#' The text2sdg package provides functions for detecting SDGs in text, as well
#' as for analyzing and visualization the hits found in text. The following
#' provides a brief overview of the contents of the package.
#'
#' @section Detect functions:
#'
#'   \code{\link{detect_sdg}} detects SDGs in text using up to five different
#'   query systems: Aurora, Elsevier, SIRIS, SDSN, and OSDG
#'
#'   \code{\link{detect_any}} detects SDGs in text using self-specified queries
#'   utilizing the lucene-style syntax of the
#'   \href{https://cran.r-project.org/package=corpustools}{\code{corpustools}}
#'   package.
#'
#' @section Analysis functions:
#'
#'   \code{\link{plot_sdg}} visualizes the relative frequency of SDG hits across
#'   query systems.
#'
#'   \code{\link{crosstab_sdg}} calculates cross tables of correlations between
#'   either the query systems or the different SDGs.
#'
#' @section Datasets:
#'
#'   \code{\link{projects}} contain random selection of research project
#'   descriptions from the P3 database of the Swiss National Science Foundation.
#'
#'   \code{\link{aurora_queries}}, \code{\link{elsevier_queries}},
#'   \code{\link{siris_queries}}, \code{\link{sdsn_queries}}, \code{\link{auckland_queries}} and
#'   \code{\link{sdgo_queries}} contain a mapping of SDGs and search queries
#'   as they are employed in the respective systems.
#'
#' @examples
#' \donttest{
#' # detect SDGs using default systems
#' hits <- detect_sdg_systems(projects)
#'
#' #' # detect SDGs using all five systems
#' hits <- detect_sdg_systems(projects,
#'   system = c("Aurora", "Elsevier", "SIRIS", "SDSN", "SDGO")
#' )
#'
#' # visualize SDG frequencies
#' plot_sdg(hits)
#'
#' # correlations between systems
#' crosstab_sdg(hits)
#'
#' # correlations between SDGs
#' crosstab_sdg(hits, compare = "sdgs")
#' }
#'
#' @docType package
#' @name text2sdg
NULL
#> NULL
