# Bachelor Thesis Replication Script
# Gürkay Özkan — Istanbul Technical University, B.Sc. Economics, 2024
#
# Thesis:
# "The Impact of Government Spending on GDP Growth: Cross-Country Comparison"
#
# Run from the repository root:
#   Rscript code/01_panel_analysis.R

required_packages <- c("plm", "lmtest", "sandwich", "car", "stargazer")
missing_packages <- required_packages[
  !vapply(required_packages, requireNamespace, logical(1), quietly = TRUE)
]

if (length(missing_packages) > 0) {
  stop(
    "Missing R packages: ",
    paste(missing_packages, collapse = ", "),
    "\nInstall them with:\ninstall.packages(c(",
    paste(sprintf('"%s"', missing_packages), collapse = ", "),
    "))"
  )
}

library(plm)
library(lmtest)
library(sandwich)
library(car)
library(stargazer)

options(scipen = 999)

data_path <- file.path("data", "analysis", "thesis_panel_2002_2021.csv")
results_dir <- "results"
dir.create(results_dir, showWarnings = FALSE, recursive = TRUE)

# -------------------------------------------------------------------------
# 1. Import and validate the final analysis dataset
# -------------------------------------------------------------------------

thesis_data <- read.csv(data_path, stringsAsFactors = FALSE)
thesis_data$Country <- factor(thesis_data$Country)
thesis_data$Year <- as.integer(thesis_data$Year)

stopifnot(nrow(thesis_data) == 200L)
stopifnot(length(unique(thesis_data$Country)) == 10L)
stopifnot(min(thesis_data$Year) == 2002L)
stopifnot(max(thesis_data$Year) == 2021L)
stopifnot(sum(is.na(thesis_data)) == 0L)

panel_data <- pdata.frame(
  thesis_data,
  index = c("Country", "Year"),
  drop.index = FALSE
)

print(pdim(panel_data))

# -------------------------------------------------------------------------
# 2. Descriptive statistics, correlations, and multicollinearity
# -------------------------------------------------------------------------

analysis_vars <- c("PSS", "GES", "GDPpc", "Educ", "U", "POP", "GCF")

summary_stats <- data.frame(
  Variable = analysis_vars,
  Observations = vapply(thesis_data[analysis_vars], length, integer(1)),
  Mean = vapply(thesis_data[analysis_vars], mean, numeric(1)),
  Std_Dev = vapply(thesis_data[analysis_vars], sd, numeric(1)),
  Min = vapply(thesis_data[analysis_vars], min, numeric(1)),
  Max = vapply(thesis_data[analysis_vars], max, numeric(1))
)

write.csv(
  summary_stats,
  file.path(results_dir, "summary_statistics.csv"),
  row.names = FALSE
)

correlation_matrix <- cor(thesis_data[analysis_vars])
write.csv(
  correlation_matrix,
  file.path(results_dir, "correlation_matrix.csv")
)

full_formula <- (
  log(GDPpc) - lag(log(GDPpc), 1)
) ~ log(PSS) + lag(log(GDPpc), 1) + log(GCF) + log(GES) +
  Educ + U + log(POP)

pooled_full <- plm(
  full_formula,
  data = panel_data,
  model = "pooling"
)

vif_values <- car::vif(pooled_full)
write.csv(
  data.frame(Variable = names(vif_values), VIF = as.numeric(vif_values)),
  file.path(results_dir, "vif.csv"),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# 3. Principal model specifications reported in the thesis
# -------------------------------------------------------------------------

# OLS 1: pooled model with country effects, without additional controls
mod1 <- plm(
  (log(GDPpc) - lag(log(GDPpc), 1)) ~
    log(PSS) + lag(log(GDPpc), 1) + log(GCF) + log(GES) + factor(Country),
  data = panel_data,
  model = "pooling"
)

# FE 1: two-way fixed effects, without additional controls
mod2 <- plm(
  (log(GDPpc) - lag(log(GDPpc), 1)) ~
    log(PSS) + lag(log(GDPpc), 1) + log(GCF) + log(GES),
  data = panel_data,
  model = "within",
  effect = "twoways"
)

# OLS 2: pooled model with country effects and controls
mod3 <- plm(
  (log(GDPpc) - lag(log(GDPpc), 1)) ~
    log(PSS) + lag(log(GDPpc), 1) + log(GCF) + log(GES) +
    factor(Country) + Educ + U + log(POP),
  data = panel_data,
  model = "pooling"
)

# RE: random effects with controls
mod4 <- plm(
  full_formula,
  data = panel_data,
  model = "random"
)

# FE 2: final two-way fixed effects model with controls
mod5 <- plm(
  full_formula,
  data = panel_data,
  model = "within",
  effect = "twoways"
)

stargazer(
  mod1, mod2, mod3, mod4, mod5,
  digits = 3,
  header = FALSE,
  type = "html",
  title = "Panel Models: Government Spending and GDP per Capita Growth",
  model.numbers = FALSE,
  column.labels = c("OLS 1", "FE 1", "OLS 2", "RE", "FE 2"),
  omit = "factor\\(Country\\)",
  out = file.path(results_dir, "model_comparison.html")
)

# -------------------------------------------------------------------------
# 4. Model-selection and diagnostic tests
# -------------------------------------------------------------------------

lm_panel_test <- plmtest(mod3, type = "bp")
hausman_test <- phtest(mod5, mod4)
serial_test <- pbgtest(mod5)
heteroskedasticity_test <- bptest(mod5, studentize = FALSE)

diagnostics <- data.frame(
  Test = c(
    "Breusch-Pagan LM test for panel effects",
    "Hausman FE vs RE specification test",
    "Breusch-Godfrey panel serial-correlation test",
    "Breusch-Pagan heteroskedasticity test"
  ),
  Statistic = c(
    as.numeric(lm_panel_test$statistic),
    as.numeric(hausman_test$statistic),
    as.numeric(serial_test$statistic),
    as.numeric(heteroskedasticity_test$statistic)
  ),
  P_Value = c(
    lm_panel_test$p.value,
    hausman_test$p.value,
    serial_test$p.value,
    heteroskedasticity_test$p.value
  )
)

write.csv(
  diagnostics,
  file.path(results_dir, "diagnostic_tests.csv"),
  row.names = FALSE
)

# -------------------------------------------------------------------------
# 5. Final FE model with Arellano HC0 standard errors clustered by country
# -------------------------------------------------------------------------

arellano_vcov <- vcovHC(
  mod5,
  method = "arellano",
  type = "HC0",
  cluster = "group"
)

robust_results <- coeftest(mod5, vcov. = arellano_vcov)

robust_results_df <- data.frame(
  Term = rownames(robust_results),
  Estimate = robust_results[, 1],
  Robust_Std_Error = robust_results[, 2],
  T_Value = robust_results[, 3],
  P_Value = robust_results[, 4],
  row.names = NULL
)

write.csv(
  robust_results_df,
  file.path(results_dir, "final_fe_arellano_results.csv"),
  row.names = FALSE
)

print(robust_results)

# -------------------------------------------------------------------------
# 6. Record the R environment used when the script is run
# -------------------------------------------------------------------------

capture.output(
  sessionInfo(),
  file = file.path(results_dir, "sessionInfo.txt")
)

message("Replication completed. Outputs written to: ", results_dir)
