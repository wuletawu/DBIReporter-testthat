
#' @importClassesFrom testthat Reporter
NULL

#' @importClassesFrom DBI DBIConnection

setOldClass('proc_time')

#' This reporter will gather all test results and insert them into an SQLite 
#' database given as a open handled upoon initialization.
#'
#' @export
#' @export DBIReporter
#' @aliases DBIReporter
#' @keywords debugging
#' @param ... Arguments used to initialise class
DBIReporter <- setRefClass("DBIReporter", contains = "Reporter",
  fields = list(
    tbl_name = 'character', #the name of the table to append data.
    start_test_timestamp = 'POSIXct',  #using YYYY-MM-DD HH:MM:SS for database
    start_test_time = 'proc_time', # The test runtime based on cpu ticks
    test_filename = 'character', #the name of the file that is associated with this test.
    db_handle = 'DBIConnection'  #instance variable holding database handle passed on new.
  ),
  
  methods = list(
    ##must pass database handle that is open and ready for action.
    initialize = function(dbh, table_name, ...) {
      db_handle <<- dbh
      tbl_name <<- table_name
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
      
      el <- as.double(proc.time() - start_test_time)
      fname <- if (length(test_filename)) file else ''
      
      test_info <- data.frame(context = context,
                        filename = fname,
                        test = test,
                        start_test_timestamp = start_test_timestamp,
                        end_test_timestamp = format(Sys.time(), "%Y-%m-%d %H:%M:%S"),
                        user_CPU = el[1],
                        system_CPU = el[2],
                        real_CPU = el[3])

      dbWriteTable(db_handle, tbl_name, test_info)
    },
    
    start_file = function(name) {
      test_filename <<- name
    }
    
      )
)




