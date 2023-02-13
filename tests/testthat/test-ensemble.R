# Test that detect_sdg returns an error when the input is not a character vector or a tCorpus object
test_that("detect_sdg returns an error when the input is not a character vector or a tCorpus object", {
  test_text <- 1:2
  expect_error(detect_sdg(test_text), "Argument text must be either class character or corpustools::tCorpus.")
})

# Test that detect_sdg returns an error when the synthetic argument is not one of "none", "third", "equal", or "tripple"
test_that("detect_sdg returns an error when the synthetic argument is not one of 'none', 'third', 'equal', or 'tripple'", {
  test_text <- c("Test text for SDG", "Test text for SDGs")
  expect_error(detect_sdg(test_text, synthetic = "invalid"), 'Argument synthetic must be "none","third","equal", or "tripple".')
})

# Test that detect_sdg works when no SDGs are detected and that it returns a tibble with the correct columns
test_that("detect_sdg returns a tibble", {
  test_text <- c("Test text for SDG 1", "Test text for SDG 2")
  expected_result <- tibble::tibble(document = factor(),
                                   sdg = character(),
                                   system = character(),
                                   hit = integer())
  result <- detect_sdg(test_text)

  expect_equal(result, expected_result)

})


#
test_that("names of tibble", {
  test_text <- c("Test text for SDG 1", "Test text for SDG 2")

  result <- detect_sdg(test_text)

  expect_equal(names(result), c("document", "sdg", "system", "hit"))

})



# Test that detect_sdg throws expected error with empty string as input
test_that("run detect_sdg with empty string", {
  test_text <- c("")
  expect_error(detect_sdg(test_text), "Argument text must not be an empty string.")

})


# Test that filtering SDGs works
test_that("filtering SDGs works", {
  test_text <- projects[1:100]

  result <- detect_sdg(test_text, synthetic = "none", sdgs = c(3, 5))

  expect_equal(result %>%
                 dplyr::distinct(sdg) %>%
                 dplyr::pull(sdg), c("SDG-03", "SDG-05"))

})



