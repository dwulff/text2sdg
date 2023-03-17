# Test that crosstab_sdg returns a matrix
test_that("crosstab_sdg returns matrix", {
  skip_on_cran()
  result <- detect_sdg_systems(projects[1], system = c("Auckland", "Elsevier"))
  cross <- crosstab_sdg(result)
  expect_equal(is.matrix(cross), TRUE)
})


# Test that crosstab throws an error when required columns are missing
test_that("run crosstab with required columns missing", {
  cross <- tibble::tibble(missing_column = integer())
  expect_error(crosstab_sdg(cross), "Data object must include columns \\[document, sdg, system\\]")
})


# Test that crosstab throws error when called with detect_sdg_systems output with no hits
test_that("run crosstab without detected sdgs", {
  skip_on_cran()
  result <- detect_sdg_systems(text = c("crosstab test"))
  expect_error(crosstab_sdg(result), "Hits data frame seems not to contain any hits, cross tabulation thus not possible.")
})

# Test that crosstab throws error when compare argument is not systems or sdgs
test_that("run crosstab with wrong compare argument", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[1:2])
  expect_error(crosstab_sdg(result, compare = "faulty"), "compare must be either 'systems' or 'sdgs'.")
})


# Test that default crosstab output has expected dimensions
test_that("test crosstab default expected dimensions", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(92, 193)])
  crosstab_result <- crosstab_sdg(result)
  expect_equal(dim(crosstab_result), c(4, 4))
})

# Test that crosstab compare sdgs output has expected dimensions
test_that("test crosstab default expected dimensions", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(14, 24, 42, 50, 75, 99, 83, 126, 190, 343, 399)])
  crosstab_result <- crosstab_sdg(result, compare = "sdgs")
  expect_equal(dim(crosstab_result), c(17, 17))
})


# Test that crosstab compare sdgs filtering SDGs works
test_that("test crosstab compare sdgs filtering SDGs works", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(126, 14, 1)])
  crosstab_result <- crosstab_sdg(result, compare = "sdgs", sdgs = c(1, 2))
  expect_equal(rownames(crosstab_result), c("SDG-01", "SDG-02"))
})


# Test that crosstab throws expected error when only one system is passed
test_that("test crosstab with only one system", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(1)], system = "Elsevier")
  expect_error(crosstab_sdg(result, compare = "systems"), "Argument systems must have, at least, two c values.")
})

# Test that crosstab throws expected error when only one sdg is passed
test_that("test crosstab with only one sdg", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(1)], system = "Elsevier")
  expect_error(crosstab_sdg(result, compare = "sdgs", sdgs = 3), "Argument sdgs must have, at least, two distinct values.")
})


# Test that crosstab compare systems filtering systems works
test_that("test crosstab compare systems filtering SDGs works", {
  skip_on_cran()
  result <- detect_sdg_systems(text = projects[c(1, 49)])
  crosstab_result <- crosstab_sdg(result, compare = "systems", systems = c("Aurora", "Elsevier"))
  expect_equal(rownames(crosstab_result), c("Aurora", "Elsevier"))
})
