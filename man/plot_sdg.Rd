% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot.R
\name{plot_sdg}
\alias{plot_sdg}
\title{Plot distributions of SDGs identified in text}
\usage{
plot_sdg(
  hits,
  systems = c("aurora", "elsevier", "siris"),
  sdgs = 1:17,
  color = "unibas",
  sdg_titles = FALSE,
  remove_duplicates = TRUE
)
}
\arguments{
\item{hits}{\code{data frame} as returned by \code{\link{detect_sdg}}. Must include columns \code{sdg} and \code{system}.}

\item{systems}{\code{character} vector specifying the query systems to be visualized. Values must be available in the \code{system} column of \code{hits}. \code{systems} of length greater 1 result, by default, in a stacked barplot.}

\item{sdgs}{\code{numeric} vector with integers between 1 and 17 specifying the SDGs to be visualized. Values must be available in the \code{sdg} column of \code{hits}.}

\item{color}{\code{character} vector used to color the bars according to systems. The default, \code{"unibas"}, uses three colors of University of Basel's corporate design. Alternatively, \code{color} must specified using \link{color} names or color hex values. \code{color} will be interpolated to match the length of \code{systems}.}

\item{sdg_titles}{\code{logical} specifying whether the titles of the SDG should added to the axis annotation.}

\item{remove_duplicates}{\code{logical} specifying the handling of multiple hits of the same SDG for a given document and system. Defaults to \code{TRUE} impliyng that no more than one hit is counted per SDG, system, and document.}
}
\value{
The function returns a \code{\link[ggplot2]{ggplot}} object that can either be stored in an object or printed to produce the plot.
}
\description{
\code{plot_sdg} creates a (stacked) barplot of the frequency distribution of SDGs identified via \link{detect_sdg}.
}
\details{
The function is built using \code{\link[ggplot2]{ggplot}} and can thus be flexibly extended. See examples.
}
\examples{

# run sdg detection
hits <- detect_sdgs(test_txt)

# create barplot
plot_sdgs(hits)

# create barplot with facets
plot_sdgs(hits) + facet_wrap(~system)

}