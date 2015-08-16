#' @title Class record testthat tests into a database.
#' 
#' @description
#' This is an extension to testthat Reporter class.
#' 
#' This reporter will gather all test results and insert them into a DBI 
#' database given as a open handled on new.
#'
#' @param dbh the database handle
#' @examples
#' dbh <- dbConnect(RSQLite::SQLite(), ':memory:')
#' myReporter <- DBIReporter$new(dbh, 'test_results')
#' 
#' @export
#' @export DBIReporter
#' @aliases DBIReporter
#' @keywords debugging
#' @param ... Arguments used to initialise class
DBIReporter <- setRefClass("DBIReporter", contains = "Reporter",
  fields = list(
    tbl_name = 'character', #the name of the table to append data.
    start_run_timestamp = 'POSIXct', # capturing the start of this run -- may encompass many test files...  this timestamp will be constant for all tests that were initiated by this run.
    start_test_timestamp = 'POSIXct',  #using YYYY-MM-DD HH:MM:SS for database but want to keep the true rep here.
    start_test_time = 'proc_time', # The test runtime based on cpu ticks
    test_filename = 'character', #the name of the file that is associated with this test.
    db_handle = 'DBIConnection'  #instance variable holding database handle passed on new.
  ),
  
  methods = list(
    ##must pass database handle that is open and ready for action.
    initialize = function(dbh, table_name = 'test_info', ...) {
      stopifnot(dbIsValid(dbh))
      db_handle <<- dbh
      tbl_name <<- table_name
      start_run_timestamp <<-Sys.time()
      callSuper(...)
    },
    
    ### overriden methods from Reporter
    start_reporter = function(...) {
      callSuper(...)
    },
    
    start_test = function(desc) {
      callSuper(desc)
      start_test_timestamp <<- Sys.time() #, "%Y-%m-%d %H:%M:%S")
      start_test_time <<- proc.time()
    },
    
    end_test = function() {
      callSuper() # at the end because it resets the test name
    },
    
    add_result = function(result) {
      callSuper(result)
      #result is an expectation instance.

      #if the filename is blank, then use an empty string?
      fname <- if (length(test_filename)) test_filename else ''
      
      # Calculations for delta time 
      el <- as.double(proc.time() - start_test_time)
      
      test_info <- data.frame(context = context,
                        filename = fname,
                        start_run_timestamp = format(start_run_timestamp, "%Y-%m-%d %H:%M:%S"),
                        passed = result$passed,
                        error = result$error,
                        skipped = result$skipped,
                        failure_msg = result$failure_msg,
                        success_msg = result$success_msg,
                        start_test_timestamp = format(start_test_timestamp, "%Y-%m-%d %H:%M:%S"),
                        end_test_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                        user_CPU = el[1],
                        system_CPU = el[2],
                        real_CPU = el[3])

      dbWriteTable(db_handle, tbl_name, test_info, append=TRUE)
    },
    
    start_file = function(name) {
      test_filename <<- name
    }
    
      )
)


#' @importClassesFrom testthat Reporter
NULL

#' @importClassesFrom DBI DBIConnection
NULL



