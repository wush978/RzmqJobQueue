#'@export
monitor <- function() {
  stopifnot(require(shiny))
  runApp(system.file("shiny", package="RzmqJobQueue"))
}

#'@export
gen_job_set <- function(fun = NULL, argv.enumerate = list(), argv.template = list()) {
  stopifnot(length(unique(sapply(argv.enumerate, length))) == 1)
  stopifnot(is.function(fun))
  stopifnot(is.list(argv.enumerate))
  stopifnot(is.list(argv.template))
  n <- length(argv.enumerate[[1]])
  retval <- vector("list", length=n)
  for(i in 1:n) {
    argv <- argv.template
    for(name in names(argv.enumerate)) {
      argv[[name]] <- argv.enumerate[[name]][[i]]
    }
    retval[[i]] <- new("job", fun = fun, argv = argv)
  }
  return(retval)
}

#'@export
commit_job <- function(job.list) {
  stopifnot(is.list(job.list))
  stopifnot(all(sapply(job.list, class) == "job"))
  for(job in job.list) {
    push_job_queue(job)
  }
}