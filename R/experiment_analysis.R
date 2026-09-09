validate_columns <- function(data, required, label) {
  missing <- setdiff(required, names(data))
  if (length(missing) > 0) {
    stop(label, " is missing required columns: ", paste(missing, collapse = ", "))
  }
  invisible(TRUE)
}

validate_binary <- function(x, name) {
  values <- unique(x[!is.na(x)])
  if (!all(values %in% c(0, 1))) {
    stop(name, " must contain only 0 and 1")
  }
  invisible(TRUE)
}

coefficient_row <- function(model, term, analysis, outcome) {
  table <- summary(model)$coefficients
  if (!term %in% rownames(table)) {
    stop("Model term not found: ", term)
  }
  data.frame(
    analysis = analysis,
    outcome = outcome,
    term = term,
    estimate = unname(table[term, "Estimate"]),
    std_error = unname(table[term, "Std. Error"]),
    p_value = unname(table[term, "Pr(>|t|)"]),
    row.names = NULL
  )
}

analyze_platform_experiment <- function(data) {
  required <- c(
    "treated", "posted", "tenure", "premium_user",
    "num_post_before", "first_timer"
  )
  validate_columns(data, required, "Platform experiment")
  for (field in c("treated", "posted", "premium_user", "first_timer")) {
    validate_binary(data[[field]], field)
  }
  if (anyNA(data[required])) {
    stop("Platform experiment contains missing values in required fields")
  }

  balance_fields <- c("tenure", "premium_user", "num_post_before")
  balance <- do.call(rbind, lapply(balance_fields, function(field) {
    test <- t.test(data[[field]] ~ data$treated)
    data.frame(
      variable = field,
      control_mean = unname(test$estimate[1]),
      treatment_mean = unname(test$estimate[2]),
      p_value = test$p.value,
      row.names = NULL
    )
  }))

  average_model <- lm(posted ~ treated, data = data)
  tenure_model <- lm(posted ~ treated * tenure, data = data)
  first_timer_model <- lm(posted ~ treated * first_timer, data = data)

  effects <- rbind(
    coefficient_row(average_model, "treated", "Platform incentive", "Posted"),
    coefficient_row(
      tenure_model, "treated:tenure", "Platform incentive", "Tenure interaction"
    ),
    coefficient_row(
      first_timer_model,
      "treated:first_timer",
      "Platform incentive",
      "First-time-user interaction"
    )
  )
  first_time_effect <- unname(
    coef(first_timer_model)["treated"] + coef(first_timer_model)["treated:first_timer"]
  )

  list(
    balance = balance,
    effects = effects,
    first_time_treatment_effect = first_time_effect,
    models = list(
      average = average_model,
      tenure = tenure_model,
      first_timer = first_timer_model
    )
  )
}

analyze_education_program <- function(data) {
  required <- c("norm", "bal", "pre", "post", "test_type")
  validate_columns(data, required, "Education program")
  for (field in c("bal", "pre", "post", "test_type")) {
    validate_binary(data[[field]], field)
  }
  if (anyNA(data[required])) {
    stop("Education program contains missing values in required fields")
  }

  labels <- c("Mathematics", "Language")
  rows <- list()
  models <- list()
  for (test_value in c(0, 1)) {
    subject <- labels[test_value + 1]
    pre_data <- data[data$pre == 1 & data$test_type == test_value, ]
    post_data <- data[data$post == 1 & data$test_type == test_value, ]
    if (nrow(pre_data) == 0 || nrow(post_data) == 0) {
      stop("Education data must include pre- and post-period rows for both subjects")
    }

    pre_test <- t.test(norm ~ bal, data = pre_data)
    post_model <- lm(norm ~ bal, data = post_data)
    rows[[length(rows) + 1]] <- data.frame(
      subject = subject,
      pre_balance_p_value = pre_test$p.value,
      post_effect = unname(coef(post_model)["bal"]),
      post_effect_p_value = unname(summary(post_model)$coefficients["bal", "Pr(>|t|)"]),
      row.names = NULL
    )
    models[[tolower(subject)]] <- post_model
  }

  list(summary = do.call(rbind, rows), models = models)
}
