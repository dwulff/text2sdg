## Resubmission
This is a resubmission. I unfortunately didn't see the email from CRAN because it went to the spam folder. I made sure that this won't happen again. As last time the misspelled words are false positives ("SDGs" at (6:65, 6:292) is the abbreaviation of "Sustainable Development Goals". In this version I tried to replace the invalid UTF-8 byte sequence that was detected in the 'text2sdg.Rmd' vignette on the Linux machine using LANG=en_US.iso88591.

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE:

* N  checking CRAN incoming feasibility ... NOTE
   
   New submission
   Package was archived on CRAN
   
   Possibly misspelled words in DESCRIPTION:
     SDGs (6:65, 6:294)
   
   
   CRAN repository db overrides:
     X-CRAN-Comment: Archived on 2021-11-02 as check problems were not
   Maintainer: 'Dominik S. Meier <dominikmeier@outlook.com>'
       corrected in time.


  


## Downstream dependencies
There are currently no downstream dependencies for this package.
