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