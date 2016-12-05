library(packageFormationR)
context("ways to add numbers")

test_that("add two integers make a numeric(), and 1 + 2 is 3", {
  expect_equal(add(1, 2), 3)
  expect_is(add(1, 2), "numeric")
})


test_that("add of missing is missing", {
  expect_equal(add(1, NA), NA_integer_)
})
