#'@exportClass
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

#'@exportMethod
setMethod(
  "initialize", 
  signature(
    .Object = "job"
  ), definition = function(.Object, type = "normal", fun , argv = list()) {
    .Object@type = type
    .Object@fun = fun
    .Object@argv = argv
    .Object@hash = digest(list(fun = fun, argv = argv), algo="md5")
    .Object
  })

