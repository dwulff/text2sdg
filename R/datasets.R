#' Descriptions of research projects
#'
#' 500 project descriptions of University of Basel research projects that were selecting for funding by the Swiss National Science Foundation. The data is a subset of the public \href{https://p3.snf.ch}{P3 project data base}.
#'
#' @format A \code{character} vector of length 100.
#'
"projects"

#' SDG queries of the Aurora Universities Network
#'
#' A dataset containing the SDG queries version 5.0 of the \href{https://aurora-network.global/activity/sustainability/}{Aurora Universities Network}. See the corresponding \href{https://github.com/Aurora-Network-Global/sdg-queries}{GitHub repository}. For the actual implementation of the queries see \code{aurora_simple}, \code{aurora_and}, \code{aurora_w}, and the queries hard-coded on \code{detect_aurora}.
#'
#' @format A data frame with 378 rows and 5 columns
#' \describe{
#'   \item{sdg}{Label of the SDG}
#'   \item{sdg_title}{Title of the SDG}
#'   \item{sdg_description}{Description of the SDG}
#'   \item{query_id}{Index of the query}
#'   \item{query}{Original SDG query}
#' }
"aurora_queries"

#' SDG queries of SIRIS Academic
#'
#' A dataset containing the SDG queries of \href{http://www.sirislab.com/lab/sdg-research-mapping/}{SIRIS Academic}. The queries are available from\href{https://zenodo.org/record/3567769#.YRY9xdMzY8N}{Zenodo.org}. For the actual implementation of the queries see \code{aurora_simple}, \code{aurora_and}, \code{aurora_w}, and the queries hard-coded on \code{detect_aurora}.
#'
#' @format A data frame with 378 rows and 5 columns
#' \describe{
#'   \item{sdg}{Label of the SDG}
#'   \item{keyword}{Primary SDG query element}
#'   \item{extra}{Secodary SDG query element}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
"siris_queries"

#' SDG queries of Elsevier
#'
#' A dataset containing the SDG queries of \href{https://www.elsevier.com/connect/sdg-report}{Elsevier}. The queries are available from \href{https://data.mendeley.com/datasets/87txkw7khs/1}{data.mendeley.com}.
#'
#' @format A data frame with 378 rows and 5 columns
#' \describe{
#'   \item{sdg}{Label of the SDG}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
"elsevier_queries"

#' SDG keyword ontology of Bautista-Puig and Mauleón
#'
#' A dataset containing the SDG queries based on the keyword ontology of Bautista-Puig and Mauleón. The queries are available from \href{https://figshare.com/articles/dataset/SDG_ontology/11106113/1}{figshare.com}.
#'
#' Bautista-Puig, N.; Mauleón E. (2019). Unveiling the path towards sustainability: is there a research interest on sustainable goals? In the 17th International Conference on Scientometrics & Informetrics (ISSI 2019), Rome (Italy), Volume II, ISBN 978-88-3381-118-5, p.2770-2771.
#'
#' @format A data frame with 378 rows and 5 columns
#' \describe{
#'   \item{sdg}{Label of the SDG}
#'   \item{keyword}{SDG keyword used in query}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
"ontology_queries"

