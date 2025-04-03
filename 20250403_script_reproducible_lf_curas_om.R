# Packages----
library("dplyr")
library("phyloseq")
library("mice")

# Load data -----
load("dummy_phyloseq.Robject")

load("dummy_imputed_dataframe_long.Rda")

ps <- dummy_phyloseq

# Set seed
set.seed(123)

# ALPHA DIVERSITY ANALYSIS ----
# This analysis will run linear regression models on the alpha diversity indices, using the imputed metadata.

# Calculate the diversity indices
alpha <- estimate_richness(ps, split = TRUE, measures = c("Chao1", "Shannon"))

# Merge the alpha diversity indices with the imputed data and convert it to a mids object for the final analyses.
alpha$IDC <- rownames(alpha)
alpha$IDC <- sub("^X", "", alpha$IDC)
alpha$IDC <- as.integer(alpha$IDC)
alpha <- alpha[, c("IDC", "Chao1", "Shannon")]

# Combine the long dataframe and the alpha dataframe
long_df_dummy <- left_join(long_df_dummy, alpha, by = "IDC")

# Convert it into a mids object which stores the imputed data
dummy_mids <- as.mids(long_df_dummy, .imp = ".imp", .id = "IDC")

# Run linear regression ----
source("functions.R")

# Define your parameters, your mids object, exposure(s) variables, outcomes and covariates. The "alpha_linear_regression_imputed_data" function will run every combination of the different parameters.
data <- dummy_mids
exps <- c("lf_phenotype")
outs <- c("Chao1", "Shannon")
covs <- c(
  "+ reads_Q + uur_bezoek_Q2",
  "+ reads_Q + uur_bezoek_Q2 + EDUCM5_cat2",
  "+ reads_Q + uur_bezoek_Q2 + EDUCM5_cat2 + smoke_c",
  "+ reads_Q + uur_bezoek_Q2 + EDUCM5_cat2 + smoke_c + ortho_final"
)

output_linear_regression <- alpha_linear_regression_imputed_data(exps, outs, covs, data)

View(output_linear_regression)

# End of script ----
