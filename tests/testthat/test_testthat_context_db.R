# Testing with testthat function test_file and database handle
# 
require(DBI)
require(RSQLite)
require(testthat)
require(DBIReporter)

#used for test result validation
require(dplyr)

#using a transient in memory database -- second parameter.  See documentation for dbConnect.
dbh <- dbConnect(RSQLite::SQLite(), ':memory:')

#Creating the reporter instance using the database handle and the name of the resulting table.
#
rptr <- DBIReporter$new(dbh, 'test_info')

#using testthat function to fun a file that would test a bunch of things.
#passing the reporter to log information into the database.
test_file("context_testthat.R", rptr)

#after tests are completed, lets review the contents of the database to see what was recored.
foo <- dbReadTable(dbh, 'test_info')

# Check the number of successes -- of course, this SHOULD be all...
successSum <- foo %>% summarize(passed = sum(passed))

#Should be three passed test.
expect_equal(successSum$passed, 3)

# Check to the number of fail tests ...  I've specifically added one in the context_testthat.R script.  
errorSum <- foo %>% summarize(error = sum(error))
expect_equal(errorSum$error, 1)

# Check the number of skipped tests.
skippedSum <- foo %>% summarize(skipped = sum(skipped))
expect_equal(skippedSum$skipped, 1)

dbDisconnect(dbh)
