# text2sdg 1.1.1
* outsourced trained ensemble model to 'text2sdgData' package
* added internal seed to 'detect_sdg' to make ensemble model predictions deterministic
* added 'testthat::skip_on_cran' to most tests to stay below max CRAN check time

# text2sdg 1.1.0
* added testing
* fixed some bugs discovered by the tests
* run `styler::style_pkg()`

# text2sdg 1.0.1
Some small updates for pkgdown and typo fixes in the vignette.

# text2sdg 1.0.0
* added the Auckland query system
* renamed the "detect_sdg" function to "detect_sdg_systems"
* the "detect_sdg" function now implements an ensemble model, see Wulff, Meier and Mata (2023) for more information

# text2sdg 0.2.0
* changed hits to n_hits


# text2sdg 0.1.6
* Fixed bug in detect_any function (did not work as expected with argument output = "documents")


# text2sdg 0.1.5
* In the SIRIS queries, replaced "niño" with "nino" to resolve encoding error on CRAN r-devel-linux-x86_64-debian-clang flavor. This affects the queries with the query_id 2635 and 2650.
* Renamed the "queries" argument of the detect_any function to "system". 
* Added arXiv preprint to Description field. 


# text2sdg 0.1.4

* In the SDSN queries, replaced "\"World\x92s hungry\"" with "\"World's hungry\"", to comply with the new CRAN checks



# text2sdg 0.1.3

* rename ontology to OSDG


# text2sdg 0.1.2

* fix debian-clang-devel encoding issue
* fix no SDGs detected bug



# text2sdg 0.1.1

* fix utf-8 bug on Linux



# text2sdg 0.1.0

* First CRAN release.
