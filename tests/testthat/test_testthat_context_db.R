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


dbDisconnect(dbh)
