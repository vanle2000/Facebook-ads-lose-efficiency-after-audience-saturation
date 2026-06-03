.PHONY: install clean run-pipeline run-dashboard help all

# Default target
help:
	@echo "Available targets:"
	@echo "  install          - Install dependencies using renv"
	@echo "  run-pipeline     - Execute the full SQL + R pipeline"
	@echo "  run-dashboard    - Launch the Shiny dashboard"
	@echo "  clean            - Clean processed data and outputs"
	@echo "  all              - Install dependencies and run full pipeline"

# Install R dependencies
install:
	Rscript -e "renv::restore()"

# Run the full pipeline
run-pipeline:
	Rscript R/03_sql_pipeline.R && \
	Rscript R/01_clean_data.R && \
	Rscript R/02_feature_engineering.R && \
	Rscript R/04_eda.R && \
	Rscript R/05_inference_tests.R && \
	Rscript R/06_train_models.R && \
	Rscript R/07_evaluate_models.R && \
	Rscript R/09_budget_simulator.R

# Run the Shiny dashboard
run-dashboard:
	Rscript -e "shiny::runApp('dashboard/app.R')"

# Clean outputs
clean:
	rm -f data/processed/*.csv
	rm -f visuals/*.png
	rm -rf models/

# Full workflow
all: install run-pipeline
