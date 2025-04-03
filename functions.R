alpha_linear_regression_imputed_data <- function(exps, outs, covs, data) {
  
  # Define the alpha_model function inside the main function
  alpha_model <- function(exp, out, cov, data) {
    # Construct the formula as a string
    my_formula <- sprintf("%s ~ %s %s", out, exp, cov)
    # Use the 'with' function to evaluate the formula in the context of 'data'
    fit <- with(data, lm(as.formula(my_formula)))
    return(fit)
  }
  
  # Fit models for each combination of exp, out, and covariate
  fits <- list()
  for (out in outs) {
    for (exp in exps) {
      for (i in seq_along(covs)) {
        cov <- covs[i]
        # Create a unique model name
        model_name <- paste0("model", i, "_", out, "_", exp)
        # Fit model and store it in the fits list
        fits[[model_name]] <- alpha_model(exp, out, cov, data)
      }
    }
  }
  
  # Process the results of the models and extract summaries
  result_dfs <- list()
  for (model_name in names(fits)) {
    cat("Processing model:", model_name, "\n")
    
    model <- fits[[model_name]]
    
    # Get the pooled coefficient summary
    coef_summary <- summary(pool(model), conf.int = TRUE)
    
    if (is.null(coef_summary)) {
      cat("No coefficients found for model:", model_name, "\n")
      next
    }
    
    # Convert summary to a dataframe
    coefficients_df <- as.data.frame(coef_summary)
    
    # Rename columns
    colnames(coefficients_df) <- c("term", "estimate", "std.error", "statistic", "df", "p.value", "2.5%", "97.5%")
    
    # Preserve raw p-values for adjustment
    coefficients_df$raw.p.value <- coefficients_df$p.value
    
    # Round numerical columns
    coefficients_df[, c("estimate", "std.error", "statistic", "p.value", "2.5%", "97.5%")] <- 
      round(coefficients_df[, c("estimate", "std.error", "statistic", "p.value", "2.5%", "97.5%")], 2)
    
    # Create a 'result' column combining estimate and confidence intervals
    coefficients_df$result <- paste0(coefficients_df$estimate, " (", 
                                     coefficients_df$`2.5%`, ";", 
                                     coefficients_df$`97.5%`, ")")
    
    # Clean up unnecessary columns
    coefficients_df <- coefficients_df[, c("term", "estimate", "std.error", "statistic", "df", "p.value", "raw.p.value", "2.5%", "97.5%", "result")]
    
    # Add model name and outcome column
    coefficients_df$Model <- model_name
    coefficients_df$Outcome <- gsub("^model\\d+_", "", model_name) %>%
      sub("_.*$", "", .)  # Extract outcome from model name
    
    # Store the dataframe in result_dfs
    result_dfs[[model_name]] <- coefficients_df
  }
  
  # Combine all the dataframes into one
  combined_df <- do.call(rbind, result_dfs)
  
  # Adjust p-values using Benjamini-Hochberg method
  combined_df <- combined_df %>%
    group_by(Outcome) %>%
    mutate(
      adj.p.value = p.adjust(raw.p.value, method = "BH"),  # Adjust p-values
      adj.p.value = round(adj.p.value, 3),                 # Round adjusted p-values
      p.value = round(raw.p.value, 3),                     # Round raw p-values
      adj_p_value_display = ifelse(adj.p.value == 0, "<0.001", as.character(adj.p.value))  # Handle display of p-values
    ) %>%
    ungroup()
  
  return(combined_df)
}

