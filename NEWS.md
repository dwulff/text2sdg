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
