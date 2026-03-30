#!/bin/bash
set -e

# Load .env if running standalone
if [ -f .env ]; then
  set -o allexport
  source .env
  set +o allexport
fi

cd dbt/dbt_bigquery_transformation

COMMAND=${1:-"all"}

case $COMMAND in
  all)
    uv run dbt deps
    echo "--- deps done ---"
    uv run dbt seed
    echo "--- seed done ---"
    uv run dbt run
    echo "--- run done ---"
    uv run dbt test
    echo "--- test done ---"
    ;;
  deps|seed|run|test|debug)
    uv run dbt "$COMMAND"
    ;;
  *)
    echo "Unknown command: $COMMAND"
    echo "Usage: bash run_dbt.sh [all|deps|seed|run|test|debug]"
    exit 1
    ;;
esac

echo "dbt $COMMAND completed successfully."