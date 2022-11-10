#' Descriptions of research projects
#'
#' 500 project descriptions of University of Basel research projects that were funded by the Swiss National Science Foundation. The project descriptions were drawn randomly from University of Basel projects listed in the the public \href{https://p3.snf.ch}{P3 project data base}.
#'
#' @format A \code{character} vector of length 500.
#' @source \url{https://p3.snf.ch/Pages/DataAndDocumentation.aspx}
"projects"

#' SDG queries of the Aurora Universities Network
#'
#' A dataset containing the SDG queries version 5.0 of the \href{https://aurora-universities.eu/}{Aurora Universities Network}. See the corresponding \href{https://github.com/Aurora-Network-Global/sdg-queries}{GitHub repository}. For the actual implementation of the queries see \code{aurora_simple}, \code{aurora_and}, \code{aurora_w}, and the queries hard-coded in \code{detect_aurora}. There are multiple queries per SDG (one per row). In comparison to previous versions, this version of the queries Aurora added more keywords related to academic terminology to be able to detect more research papers related to the SDGs. The current version also drew inspiration from the SIRIS query system (\code{siris_queries}). The Aurora queries were designed to be precise rather than sensitive. To achieve this the queries make use complex keyword-combinations using several different logical search operators. All SDGs (1-17) are covered.
#'
#' @format A data frame with 378 rows and 5 columns
#' \describe{
#'   \item{system}{Name of system}
#'   \item{sdg}{Label of the SDG}
#'   \item{sdg_title}{Title of the SDG}
#'   \item{sdg_description}{Description of the SDG}
#'   \item{query_id}{Index of the query}
#'   \item{query}{Original SDG query}
#' }
#' @source \url{https://github.com/Aurora-Network-Global/sdg-queries/releases/tag/v5.0}
"aurora_queries"

#' SDG queries of SIRIS Academic
#'
#' A dataset containing the SDG queries of \href{http://www.sirislab.com/lab/sdg-research-mapping/}{SIRIS Academic}. The queries are available from\href{https://zenodo.org/record/3567769#.YRY9xdMzY8N}{Zenodo.org}. The SIRIS queries were developed by extracting key terms from the UN official list of goals, targets and indicators as well from relevant literature around SDGs. The query system has subsequently been expanded with a pre-trained word2vec model and an algorithm that selects related words from Wikipedia. There are multiple queries per SDG (one per row). There are no queries for SDG-17.
#'
#' @format A data frame with 3,445 rows and 6 columns
#' \describe{
#'   \item{system}{Name of system}
#'   \item{sdg}{Label of the SDG}
#'   \item{keyword}{Primary SDG query element}
#'   \item{extra}{Secodary SDG query element}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
#' @source \url{https://zenodo.org/record/3567769#.YVMhH9gzYUG}
"siris_queries"

#' SDG queries of Elsevier
#'
#' A dataset containing the SDG queries of \href{https://www.elsevier.com/connect/sdg-report}{Elsevier} (version 1). The queries are available from \href{https://data.mendeley.com/datasets/87txkw7khs/1}{data.mendeley.com}. The Elsevier queries were developed to maximize SDG hits on the Scopus database. A detailed description of how each SDG query was developed can be found \href{https://elsevier.digitalcommonsdata.com/datasets/87txkw7khs/1}{here}. There is one query per SDG. There are no queries for SDG-17.
#'
#' @format A data frame with 16 rows and 4 columns
#' \describe{
#'   \item{system}{Name of system}
#'   \item{sdg}{Label of the SDG}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
#' @source \url{https://data.mendeley.com/datasets/87txkw7khs/1}
"elsevier_queries"

#' SDG keyword ontology by OSDG
#'
#' A dataset containing the SDG queries based on the keyword ontology by OSDG. The queries are available from \href{https://figshare.com/articles/dataset/SDG_ontology/11106113/1}{figshare.com}.
#'
#' Bautista-Puig, N.; Mauleón E. (2019). Unveiling the path towards sustainability: is there a research interest on sustainable goals? In the 17th International Conference on Scientometrics & Informetrics (ISSI 2019), Rome (Italy), Volume II, ISBN 978-88-3381-118-5, p.2770-2771. The authors of these queries first created an ontology from central keywords in the SDG UN description and expanded these keywords with keywords they identified in SDG related research output. There are multiple queries per SDG. All SDGs (1-17) are covered.
#'
#'
#' @format A data frame with 4,122 rows and 5 columns
#' \describe{
#'   \item{system}{Name of system}
#'   \item{sdg}{Label of the SDG}
#'   \item{keyword}{SDG keyword used in query}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
#' @source \url{https://figshare.com/articles/dataset/SDG_ontology/11106113/1}
"osdg_queries"

#' SDG keywords by SDSN
#'
#' A dataset containing SDG-specific keywords compiled from several universities from the Sustainable Development Solutions Network (SDSN) Australia, New Zealand & Pacific Network. The authors used UN documents, Google searches and personal communications as sources for the keywords. All SDGs (1-17) are covered.
#'
#'
#' @format A data frame with 847 rows and 5 columns
#' \describe{
#'   \item{system}{Name of system}
#'   \item{sdg}{Label of the SDG}
#'   \item{keyword}{SDG keyword used in query}
#'   \item{query_id}{Index of the query}
#'   \item{query}{SDG query}
#' }
#' @source \url{https://ap-unsdsn.org/regional-initiatives/universities-sdgs/}
"sdsn_queries"

