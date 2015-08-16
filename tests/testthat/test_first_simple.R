# Test using non-Report class methods.
# this should verify that it'll work when using testthat framework.
require(testthat)
require(DBI)
require(RSQLite)
require(DBIReporter)
require(dplyr)

dbh <- dbConnect(RSQLite::SQLite(), ':memory:')

rptr <- DBIReporter$new(dbh, 'test_info')

##set the new reporter (but capture the old reporter for future)
old_reporter <- set_reporter(rptr)

context('testing first example')
get_reporter()$start_file('test_first_simple.R')

#need to create an expectation of success .. mostly
expect_that(TRUE, is_false(), "something is wrong",  "Something is so right")
expect_that(TRUE, is_true(), "something is wrong",  "Something is so right")

##revert the reporter
set_reporter(old_reporter)

#SIGH... too fast in testing.  Need to separate the reporters by a second or more
#in order to pickup the difference in start_run_timestamp
Sys.sleep(1)

##Create a second reporter.. this one should have a different run timestamp
rptr <- DBIReporter$new(dbh, 'test_info')
old_reporter <- set_reporter(rptr)

context('testing second example')
get_reporter()$start_file('test_first_simple.R')

#need to create an expectation
expect_that(TRUE, is_false(), "something is wrong",  "Something is so right")
expect_that(TRUE, is_true(), "something is wrong",  "Something is so right")


set_reporter(old_reporter)

##Let's review and discuss amongst ourselves.

#pull the results from the database.
foo <- dbReadTable(dbh, 'test_info')

# Check the number of successes -- of course, this SHOULD be all...
successSum <- foo %>% summarize(passed = sum(passed), count = n())
expect_equal(successSum$passed, 2, 'two successful.')
expect_equal(successSum$count, 4, 'should be four tests')

startRunTimeCount <- foo %>% group_by(start_run_timestamp) %>% summarize(passed = sum(passed), count = n())
expect_equal(nrow(startRunTimeCount),2, 'two distinct start_run_timestamps')

dbDisconnect(dbh)
