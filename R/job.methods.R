#'@include job.class.R
setMethod(
  "initialize", 
  signature(
    .Object = "job"
  ), definition = function(.Object, type = "normal", fun , argv = list()) {
    .Object@type = type
    .Object@fun = fun
    .Object@argv = argv
    .Object@hash = digest(list(fun = fun, argv = argv, create.time = Sys.time()), algo="md5")
    .Object
  })

#'@include job.class.R
setMethod("[<-",
          signature(x = "job"),
          function (x, i, j, ..., value) 
          {
            slot(x, i) <- value
            x
          }
)

#'@include job.class.R
setMethod("[",
          signature(x = "job"),
          function (x, i, j, ..., drop = TRUE) 
          {
            slot(x,i)
          }
)
