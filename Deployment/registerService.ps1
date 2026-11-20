[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [ValidatePattern('^[A-Za-z][A-Za-z0-9_]*$')]
    [string]$ServiceName,

    [string]$OracleSid = $(if ($env:ORACLE_SID) { $env:ORACLE_SID } else { 'oracledba' }),
    [string]$PdbName = 'pdborcldba'
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$env:ORACLE_SID = $OracleSid

$sql = @"
WHENEVER SQLERROR EXIT SQL.SQLCODE
WHENEVER OSERROR EXIT FAILURE
ALTER SESSION SET CONTAINER = $PdbName;
DECLARE
  v_cnt NUMBER;
BEGIN
  SELECT COUNT(*) INTO v_cnt FROM dba_services WHERE LOWER(name) = LOWER('$ServiceName');
  IF v_cnt = 0 THEN
    DBMS_SERVICE.CREATE_SERVICE(service_name => '$ServiceName', network_name => '$ServiceName');
  END IF;

  SELECT COUNT(*) INTO v_cnt FROM v`$active_services WHERE LOWER(name) = LOWER('$ServiceName');
  IF v_cnt = 0 THEN
    DBMS_SERVICE.START_SERVICE(service_name => '$ServiceName');
  END IF;
END;
/
ALTER PLUGGABLE DATABASE $PdbName SAVE STATE;
ALTER SYSTEM REGISTER;
EXIT;
"@

$sql | sqlplus -S / as sysdba
if ($LASTEXITCODE -ne 0) {
    Write-Error "Failed to register service '$ServiceName' (exit code $LASTEXITCODE)."
    exit $LASTEXITCODE
}

Write-Host "Service '$ServiceName' registered in PDB '$PdbName' (SID: '$OracleSid')."