#' Testing with testthat function test_file and database handle
#' 
require(DBI)
require(RSQLite)
require(testthat)
require(DBIReporter)

#used for test result validation
require(dplyr)

dbh <- dbConnect(RSQLite::SQLite(), ':memory:')
rptr <- DBIReporter$new(dbh, 'test_info')

test_file("context_testthat.R", rptr)

foo <- dbReadTable(dbh, 'test_info')

successSum <- foo %>% summarize(passed = sum(passed))

#Should be three passed test.
expect_equal(successSum$passed, 3)

# need to test a fail... where the test throws an error.
errorSum <- foo %>% summarize(error = sum(error))
expect_equal(errorSum$error, 1)

skippedSum <- foo %>% summarize(skipped = sum(skipped))
expect_equal(skippedSum$skipped, 1)

dbDisconnect(dbh)
