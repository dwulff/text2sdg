[![cran version](http://www.r-pkg.org/badges/version/text2sdg)](https://CRAN.R-project.org/package=text2sdg)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.5553980.svg)](https://doi.org/10.48550/arXiv.2110.05856)
[![downloads](https://cranlogs.r-pkg.org/badges/grand-total/text2sdg?color=yellow)](https://CRAN.R-project.org/package=text2sdg)

# text2sdg <img src="man/figures/logo.png" align="right" alt="" width="120" />

The United Nations’ Sustainable Development Goals (SDGs) have become an important guideline for higher-education and research institutions to monitor and plan their contributions to social, economic, and environmental transformations.

The `text2sdg` package is the first open-source, multi-system analysis package that identifies SDGs in text, opening up the opportunity to monitor any type of text-based data, including scientific output and corporate publications.


## General Information

The `text2sdg` package is developed by Dirk U. Wulff and Dominik S. Meier, with contributions from Rui Mata and the <a href="https://cds.unibas.ch/">Center for Cognitive and Decision Sciences</a>. It is published under the GNU General Public License.

An overview of the package can be accessed
[online](https://www.text2sdg.io/reference/text2sdg.html) or from within R using `?text2sdg`.

# Installation

The current stable version is available on CRAN and can be installed via `install.packages("text2sdg")`.

The latest development version on GitHub can be installed via `devtools::install_github("dwulff/text2sdg")`. Note that this requires prior installation of the `devtools` package.  

# Usage

To identify SDGs in a series of documents, the user can choose between two approaches, an individual systems approach implementing six individual query systems and an ensemble approach powered by machine learning that integrates these systems. It is recommended to use the more accurate and bias-free ensemble approach (see Wulff, Meier, & Mata, 2024).  

```r
# vector of texts
texts = c("This is text 1", "This is text 2")

# individual systems approach
hits = detect_sdg_systems(texts)

# ensemble approach
hits = detect_sdg(texts)
```

For a complete tutorial on the use of the package, visit
[this page]( https://www.text2sdg.io/articles/text2sdg.html) or call `vignette("text2sdg")` from within R.

## Citation

If you use the `text2sdg` package for published work, we kindly ask that you cite the package as follows:

Meier, D. S., Mata, R., & Wulff, D. U. (2021). text2sdg: An open-source solution to monitoring sustainable development goals from text. arXiv. https://arxiv.org/abs/2110.05856

Depending on the use of the package, also consider referencing the following article:

Wulff, D. U., Meier, D. S., & Mata, R. (2024). Using novel data and ensemble models to improve automated labeling of Sustainable Development Goals. *Sustainability Science*. https://doi.org/10.1007/s11625-024-01516-3
