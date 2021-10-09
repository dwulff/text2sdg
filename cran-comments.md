## Resubmission
This is a resubmission. In this version I have:

* made the Maintainer and Author field consistent
* prevented the examples with CPU (user + system) or elapsed time > 10s to be run on CRAN by wrapping them in donttest.

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

* checking CRAN incoming feasibility ... NOTE
  Maintainer: 'Dominik S. Meier <dominikmeier@outlook.com>'

  New submission

  Possibly misspelled words in DESCRIPTION:
    SDGs (6:65, 6:292)
    sdg (6:229)
  
  This is a new submission and the misspelled words are false positives ("SDGs" at (6:65, 6:292) is the abbreaviation of "Sustainable Development Goals" and "sdg" at (6:229) is part of the package name "text2sdg" ((6:224) - (6:232)))
  


## Downstream dependencies
There are currently no downstream dependencies for this package.
