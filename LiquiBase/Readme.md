# Fixing Liquibase on Windows with SDKMAN & Git Bash

When installing **Liquibase** via **SDKMAN** inside **Git Bash (`MINGW64`)** on Windows without WSL, running `liquibase` can fail with:

```text
Error: Unable to access jarfile C:/Users/<User>/.sdkman/candidates/liquibase/current/bin/internal/lib/liquibase-core.jar

Path Resolution Mismatch (LIQUIBASE_HOME): In Liquibase 5.x, the liquibase launcher script resides in current/bin/liquibase, while liquibase-core.jar lives in current/internal/lib/liquibase-core.jar. On Windows under Git Bash, SDKMAN's current directory junction/symlink causes the launcher script to miscalculate LIQUIBASE_HOME as .../current/bin instead of .../current.

CLI Flag Syntax: Checking the CLI version requires --version (double dash) rather than version.