script_args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("^--file=", "", script_args[grep("^--file=", script_args)])
root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(root, "R", "experiment_analysis.R"))

set.seed(6441)
n <- 2000
platform <- data.frame(
  treated = rbinom(n, 1, 0.5),
  tenure = rexp(n, rate = 1 / 500),
  premium_user = rbinom(n, 1, 0.03),
  num_post_before = rpois(n, 1.6),
  first_timer = rbinom(n, 1, 0.45)
)
probability <- 0.52 + 0.03 * platform$treated +
  0.09 * platform$treated * platform$first_timer
platform$posted <- rbinom(n, 1, pmin(probability, 0.95))
platform_results <- analyze_platform_experiment(platform)

education <- expand.grid(
  student = seq_len(1500),
  test_type = c(0, 1),
  period = c("pre", "post")
)
education$bal <- rbinom(nrow(education), 1, 0.5)
education$pre <- as.integer(education$period == "pre")
education$post <- as.integer(education$period == "post")
education$norm <- rnorm(nrow(education)) +
  education$post * education$bal * ifelse(education$test_type == 0, 0.18, 0.13)
education_results <- analyze_education_program(education)

stopifnot(nrow(platform_results$balance) == 3)
stopifnot(nrow(platform_results$effects) == 3)
stopifnot(platform_results$first_time_treatment_effect > 0)
stopifnot(nrow(education_results$summary) == 2)
stopifnot(all(education_results$summary$post_effect > 0))

bad <- platform
bad$treated[1] <- 2
error_seen <- FALSE
tryCatch(analyze_platform_experiment(bad), error = function(e) error_seen <<- TRUE)
stopifnot(error_seen)

message("All randomized-experiment checks passed.")
