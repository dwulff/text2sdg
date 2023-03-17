# Test that detect_sdg_systems returns an error when the input is not a character vector or a tCorpus object
test_that("detect_any returns an error when the input is not a character vector or a tCorpus object", {
  test_text <- 1:2
  expect_error(detect_any(test_text), "Argument text must be either class character or corpustools::tCorpus.")
})

# Test that detect_any returns an error when the output argument is not one of "features" or "documents"
test_that('detect_any returns an error when the output argument is not one of "features" or "documents"', {
  my_queries <- tibble::tibble(
    system = "my_system",
    query = c(
      "theory",
      "analysis OR analyses OR analyzed",
      "study AND hypothesis"
    ),
    sdg = c(1, 2, 2)
  )
  test_text <- c("Test text for SDG", "Test text for SDGs")
  expect_error(detect_any(test_text, output = "invalid", system = my_queries), 'Argument output must be "features" or "documents"')
})

# Test that detect_any works when no SDGs are detected and that it returns a tibble with the correct columns
test_that("detect_sdg_systems returns a tibble", {
  test_text <- c("Test text for SDG 1")

  my_queries <- tibble::tibble(
    system = "my_system",
    query = c(
      "theory",
      "analysis OR analyses OR analyzed",
      "study AND hypothesis"
    ),
    sdg = c(1, 2, 2)
  )

  expected_result <- tibble::tibble(
    document = factor(),
    sdg = character(),
    system = character(),
    query_id = integer(),
    features = character(),
    hit = integer()
  )
  result <- detect_any(test_text, system = my_queries)

  expect_equal(result, expected_result)
})


# Test that detect_sdg_systems throws expected error with empty string as input
test_that("run detect_sdg_systems with empty string", {
  test_text <- c("")
  expect_error(detect_sdg_systems(test_text), "Argument text must not be an empty string.")
})


# Test that filtering SDGs works
test_that("filtering SDGs works", {
  skip_on_cran()
  test_text <- c("theory", "analysis", "study hypothesis")

  my_queries <- tibble::tibble(
    system = "my_system",
    query = c(
      "theory",
      "analysis OR analyses OR analyzed",
      "study AND hypothesis"
    ),
    sdg = c(1, 2, 7)
  )

  result <- detect_any(test_text, system = my_queries, sdgs = c(1, 2))


  expect_equal(result %>%
    dplyr::distinct(sdg) %>%
    dplyr::pull(sdg), c("SDG-01", "SDG-02"))
})


# Test that documents output works as expected
test_that("Test documents output", {
  skip_on_cran()
  test_text <- c("theory", "analysis", "study hypothesis")

  my_queries <- tibble::tibble(
    system = "my_system",
    query = c(
      "theory",
      "analysis OR analyses OR analyzed",
      "study AND hypothesis"
    ),
    sdg = c(1, 2, 7)
  )

  result <- detect_any(test_text, system = my_queries, output = "documents")

  expect_equal(names(result), c("document", "sdg", "system", "hits"))
})

# Test detect_sdg_systems throws expected error when the selected subset of sdgs is not present in the queries
test_that("Test documents output", {
  skip_on_cran()
  test_text <- c("theory", "analysis", "study hypothesis")

  my_queries <- tibble::tibble(
    system = "my_system",
    query = c(
      "theory",
      "analysis OR analyses OR analyzed",
      "study AND hypothesis"
    ),
    sdg = c(1, 2, 7)
  )

  expect_error(detect_any(test_text, system = my_queries, output = "documents", sdgs = c(3, 4)), "At least one of the selected SDGs needs to be present in the queries data frame.")
})
