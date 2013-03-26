#'@export
open_subprocess <- function(script.name, ...) {
  ping.stdout <- tempfile()
  system2("Rscript", args = c(system.file(script.name, package="RzmqJobQueue"), unlist(list(...))), wait=FALSE, stdout = ping.stdout)
  while(!file.exists(ping.stdout)) next
  while(file.info(ping.stdout)$size == 0) next
  ping.pid <- as.integer(readLines(ping.stdout))
  stopifnot(length(ping.pid) > 0)
  stopifnot(ping.pid > 0)
  return(ping.pid)
}