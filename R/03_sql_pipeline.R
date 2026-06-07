# Running SQL pipeline for data transformation on DuckDB
library(DBI)
library(duckdb)

# DuckDB connection
con <- dbConnect(duckdb::duckdb(), ":memory:")

# Execute SQL scripts in sequence
sql_scripts <- list.files("sql/", pattern = "*.sql", full.names = TRUE)

cat("=== Executing SQL Pipeline ===\n")
for (script in sort(sql_scripts)) {
  cat("Executing:", basename(script), "\n")
  
  # Read SQL script
  sql_content <- readr::read_file(script)
  
  # Split by semicolon for multiple statements
  statements <- strsplit(sql_content, ";")[[1]]
  statements <- statements[nchar(trimws(statements)) > 0]
  
  # Execute each statement
  for (stmt in statements) {
    tryCatch({
      dbExecute(con, stmt)
    }, error = function(e) {
      cat("Warning in", basename(script), ":", e$message, "\n")
    })
  }
}

# Display available tables
cat("\n=== Tables created ===\n")
tables <- dbListTables(con)
print(tables)

# Close connection
dbDisconnect(con)
cat("\nSQL pipeline execution completed.\n")
