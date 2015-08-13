
require(DBI)
require(RSQLite)
require(DBIReporter)

dbh <- dbConnect(RSQLite::SQLite(), ':memory:')

rptr <- DBIReporter$new(dbh, 'test_info')
set_reporter(rptr)

context('testing first example')
get_reporter()$start_file('test_first_simple.R')

#need to create an expectation


expect_that(TRUE, is_false(), "something is wrong",  "Something is so right")
get_reporter()
expect_that(TRUE, is_true(), "something is wrong",  "Something is so right")
get_reporter()

