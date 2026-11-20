#!/usr/bin/env bash
set -euo pipefail

LIQUIBASE_HOME_DIR="$HOME/.sdkman/candidates/liquibase/current"
JAR_PATH="$LIQUIBASE_HOME_DIR/internal/lib/liquibase-core.jar"
EXPORT_LINE='export LIQUIBASE_HOME="$HOME/.sdkman/candidates/liquibase/current"'

# Verify Liquibase JAR exists
if [[ ! -f "$JAR_PATH" ]]; then
  echo "Missing JAR: $JAR_PATH (run: sdk install liquibase)" >&2
  exit 1
fi

# Persist LIQUIBASE_HOME in ~/.bashrc once
grep -Fq 'candidates/liquibase/current' "$HOME/.bashrc" 2>/dev/null || echo "$EXPORT_LINE" >> "$HOME/.bashrc"

export LIQUIBASE_HOME="$LIQUIBASE_HOME_DIR"
liquibase --version