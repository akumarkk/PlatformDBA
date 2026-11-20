## Troubleshooting Guide

### 1. `Unable to access jarfile ...\bin\internal\lib\liquibase-core.jar` (Windows PowerShell)
- **Cause:** SDKMAN's `bin\liquibase.bat` sets `set LIQUIBASE_HOME="%~dp0"` (`...\bin\`), overwriting `$env:LIQUIBASE_HOME`.
- **Fix:** Use the system install (`C:\Program Files\liquibase\liquibase.bat`, which [deploy-liquibase.ps1](./deploy-liquibase.ps1) prefers via `PATH`), or change line 7 of SDKMAN's `bin\liquibase.bat` to `set LIQUIBASE_HOME="%~dp0.."`.

### 2. `Invalid Community LIQUIBASE_* environment variables: LIQUIBASE_COMMAND_CLASSPATH`
- **Cause:** Liquibase 5.x Community does not accept `LIQUIBASE_COMMAND_CLASSPATH` as an environment variable.
- **Fix:** Set `classpath=...` in [liquibase.properties](./liquibase.properties) or pass `--classpath=<path-to-ojdbc8.jar>` as a CLI argument.

### 3. `ORA-12514: TNS:listener does not currently know of service requested`
- **Cause:** The target service (e.g. `foAppCrossPlt`) is not created/started in `pdborcldba` or not yet registered with the listener.
- **Fix:** Register the service and verify with `lsnrctl status`:
  ```powershell
  .\Deployment\registerService.ps1 -ServiceName 'foAppCrossPlt'
  lsnrctl status
  ```

  ### 4.ORA-00955: name is already used by an existing object 
  Cause: Objects already exist in the schema from an earlier non-Liquibase run.
Fix (Dev/Reset): Drop DATABASECHANGELOG, DATABASECHANGELOGLOCK, and the pre-existing objects, then re-run update:
```
.\LiquiBase\deploy-liquibase.ps1 -Command update -ServiceName 'foAppCrossPlt'

```