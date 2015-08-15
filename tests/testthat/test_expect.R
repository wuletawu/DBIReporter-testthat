require(DBI)
require(RSQLite)
require(testthat)
require(DBIReporter)

dbh <- dbConnect(RSQLite::SQLite(), ':memory:')

rptr <- DBIReporter$new(dbh, 'test_info')
set_reporter(rptr)

##start the context
rptr$start_context('testing first example')

# set the filename
rptr$start_file("starting a file")

# start the test
rptr$start_test("describe the test")
rptr
debugonce(rptr$print.DBIReporter)
rptr$print.DBIReporter()

# add the result
#build the expectation .. either a successful or failed test.
exp.1 <- expectation(FALSE, 'This is failure', 'this is success')
debug(get_reporter()$add_result)
rptr$add_result(exp.1)

# end the test
rptr$end_test()

rptr$end_context()

dbReadTable(dbh, 'test_info')
