#'@export
register_worker <- function(worker_id) {
  rredis::redisHSet("worker_table", worker_id, TRUE)
}

#'@export
remove_worker <- function(worker_id) {
  rredis::redisHDel("worker_table", worker_id)
}

#'@export
get_worker_table <- function() {
  rredis::redisHGetAll("worker_Table")
}