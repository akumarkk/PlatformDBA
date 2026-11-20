##### SQL Server vs Oracle (your setup)

| SQL Server | Oracle (your setup) | Role |
|---|---|---|
| **Instance** (e.g. `MSSQLSERVER`) | **CDB / Instance** (`oracledba`) | The running server processes, memory, and shared system catalog (`CDB$ROOT`). |
| **Database** (e.g. `MyAppDB`) | **PDB** (`pdborcldba`) | The isolated database where your application data lives. You connect to it by **Service Name** (`pdborcldba`). |
| **Schema** (e.g. `dbo`, `sales`) | **User / Schema** (`app_user`) | In Oracle, a user and a schema are 1-to-1 (`app_user` owns the `APP_USER` schema). |

####### cmds

```

SELECT instance_name, status FROM v$instance;
SHOW PDBS;
EXIT;
```

```
$env:ORACLE_SID = 'oracledba';
sqlplus -S / as sysdba

$env:ORACLE_SID = 'oracledba'
sqlplus / as sysdba
```

##### Create user
```


ALTER SESSION SET CONTAINER = pdborcldba;
SHOW CON_NAME;

CREATE USER app_user IDENTIFIED BY nbv_12345
  DEFAULT TABLESPACE users
  TEMPORARY TABLESPACE temp
  QUOTA UNLIMITED ON users;

GRANT CREATE SESSION, CREATE TABLE, CREATE VIEW, CREATE SEQUENCE, CREATE PROCEDURE TO app_user;
```

##### Start service
```
ALTER SESSION SET CONTAINER = pdborcldba;

BEGIN
  DBMS_SERVICE.CREATE_SERVICE(
    service_name => 'my_service',
    network_name => 'my_service'
  );
  DBMS_SERVICE.START_SERVICE(
    service_name => 'my_service'
  );
END;
/

-- Persist the service state across restarts
ALTER PLUGGABLE DATABASE pdborcldba SAVE STATE;
EXIT;
```


##### listener
```

$env:ORACLE_SID = 'oracledba'
sqlplus / as sysdba
lsnrctl start

$env:ORACLE_SID = 'oracledba'
"ALTER SYSTEM REGISTER;`nEXIT;" | sqlplus -S / as sysdba
```

