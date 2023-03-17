# Test that detect_sdg_systems returns an error when the input is not a character vector or a tCorpus object
test_that("detect_sdg_systems returns an error when the input is not a character vector or a tCorpus object", {
  test_text <- 1:2
  expect_error(detect_sdg_systems(test_text), "Argument text must be either class character or corpustools::tCorpus.")
})

# Test that detect_sdg_systems returns an error when the output argument is not one of "features" or "documents"
test_that('detect_sdg_systems returns an error when the output argument is not one of "features" or "documents"', {
  test_text <- c("Test text for SDG", "Test text for SDGs")
  expect_error(detect_sdg_systems(test_text, output = "invalid"), 'Argument output must be "features" or "documents"')
})

# Test that detect_sdg_systems works when no SDGs are detected and that it returns a tibble with the correct columns
test_that("detect_sdg_systems returns a tibble", {
  test_text <- c("Test text")
  expected_result <- tibble::tibble(
    document = factor(),
    sdg = character(),
    system = character(),
    query_id = integer(),
    features = character(),
    hit = integer()
  )
  result <- detect_sdg_systems(test_text, system = "Elsevier")

  expect_equal(result, expected_result)
})


# Test that detect_sdg throws expected error with empty string as input
test_that("run detect_sdg_systems with empty string", {
  test_text <- c("")
  expect_error(detect_sdg_systems(test_text), "Argument text must not be an empty string.")
})


# Test that filtering SDGs works
test_that("filtering SDGs works", {
  skip_on_cran()
  test_text <- projects[c(c(1, 17, 50))]

  result <- detect_sdg_systems(test_text, sdgs = c(3, 5))

  expect_equal(result %>%
    dplyr::distinct(sdg) %>%
    dplyr::pull(sdg), c("SDG-03", "SDG-05"))
})
