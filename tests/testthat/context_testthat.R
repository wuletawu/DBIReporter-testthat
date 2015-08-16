
#Some tests that are wrapped up in a file...
# similiar to context.r in the testthat test cases.
# This is sourced by test_file function.
# but the results are expected to written back to a database via DBIReporter.

context("t.test Example test")

test_that("t.test meets p requirement", {
  
  set.seed(1010)
  n <- 47000
  
  a.mean <- 100
  b.mean <- 100
  
  a.data <- rnorm(n, mean = a.mean)
  b.data <- rnorm(n, mean = b.mean)
  
  # the t.test p value should be greater than p.expect
  # true difference in means is not equal to 0
  p.expect <- 0.95
  
  result.htest <- t.test(a.data,b.data)
  
  expect_more_than(result.htest$p.value, p.expect, label='data has good p')
})

checkData.t.test <- function(n, p.expect = 0.95)
{
  #setting the seed to keep this repeatable
  set.seed(1010)
  
  a.mean <- 100
  b.mean <- 100

  a.data <- rnorm(n, mean = a.mean)
  b.data <- rnorm(n, mean = b.mean)

  result.htest <- t.test(a.data,b.data)

  
  expect_more_than(result.htest$p.value, p.expect, info=n)
}

# checkData.t.test(10000)
# checkData.t.test(30000)
# checkData.t.test(50000)
# checkData.t.test(70000)
# checkData.t.test(100000)

test_that("t.test meets p requirement", {
  # if my math is right, some of these will succeed, but some will also fail.
  # 
  sizes <- (1:10)*10000
  lapply(sizes, checkData.t.test)
})

#' test that we log an error in the database.
test_that("Not expecting a fatal error", {
  stopifnot(FALSE, "this is a failure... Whoopsie")
}
          )

test_that('Skipping this test.', {
  skip("this is not the test you were looking for.")
})

