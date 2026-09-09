args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 3) {
  stop(
    "Usage: Rscript R/run_analysis.R <platform.csv> <education.csv> <output_dir>"
  )
}

script_args <- commandArgs(trailingOnly = FALSE)
script_path <- sub("^--file=", "", script_args[grep("^--file=", script_args)])
root <- normalizePath(file.path(dirname(script_path), ".."), mustWork = TRUE)
source(file.path(root, "R", "experiment_analysis.R"))

platform <- read.csv(args[1])
education <- read.csv(args[2])
output_dir <- args[3]
dir.create(output_dir, recursive = TRUE, showWarnings = FALSE)

platform_results <- analyze_platform_experiment(platform)
education_results <- analyze_education_program(education)

write.csv(platform_results$balance, file.path(output_dir, "platform_balance.csv"), row.names = FALSE)
write.csv(platform_results$effects, file.path(output_dir, "platform_effects.csv"), row.names = FALSE)
write.csv(education_results$summary, file.path(output_dir, "education_effects.csv"), row.names = FALSE)

message("Analysis complete. Results written to ", normalizePath(output_dir))
