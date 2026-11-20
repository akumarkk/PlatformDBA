##### run
```
# Should show 3 pending changesets (1 new + 2 modified runOnChange) and skip the rest
.\LiquiBase\deploy-liquibase.ps1 -Command status -ServiceName 'foAppCrossPlt'

# Apply only those 3 changes
.\LiquiBase\deploy-liquibase.ps1 -Command update -ServiceName 'foAppCrossPlt'

# Verify the new column & data
"SELECT * FROM v_app_users;`nEXIT;" | sqlplus -S username/pass@localhost:1521/foAppCrossPlt

```