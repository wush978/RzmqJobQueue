#'@section Slots: 
#'  \describe{
#'    \item{\code{type}:}{The type of the job. Possible value: \code{normal}, \code{empty}, and \code{terminate}}
#'    \item{\code{fun}:}{The job will be executed by \code{do.call(fun, argv)}}
#'    \item{\code{argv}:}{The job will be executed by \code{do.call(fun, argv)}}
#'    \item{\code{hash}:}{The hash of the job}
#'    \item{\code{worker.id}:}{The id of worker who do the job}
#'    \item{\code{start.processing}:}{When the job is delivered to the worker}
#'    \item{\code{processing.time}:}{How much time to execute the job}
#'  }
#'
#' @name job
#' @title job-class
#' @rdname job-class
#' @aliases job-class
#' @author Wush Wu
#' @exportClass job
setClass(
  "job", 
  representation(
    "type" = "character",
    "fun" = "function",
    "argv" = "list",
    "hash" = "character",
    "worker.id" = "character",
    "start.processing" = "POSIXt",
    "processing.time" = "numeric"
  ), 
  prototype(
    "type" = "normal",
    "fun" = NULL,
    "argv" = list(),
    "hash" = "",
    "worker.id" = "",
    "start.processing" = NULL,
    "processing.time" = NULL
    ))
