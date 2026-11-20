[CmdletBinding()]
param(
    [string]$Server = $(if ($env:DB_HOST) { $env:DB_HOST } else { 'localhost' }),
    [int]$Port = $(if ($env:DB_PORT) { [int]$env:DB_PORT } else { 1521 }),
    [string]$ServiceName = $(if ($env:DB_SERVICE) { $env:DB_SERVICE } else { 'foApp' }),
    [string]$Username = $(if ($env:DB_USER) { $env:DB_USER } else { 'app_user' }),
    [string]$Password = $env:DB_PASSWORD,
    [string]$ScriptsDir = (Join-Path $PSScriptRoot '..\DbScripts'),
    [string]$ManifestFile = 'deploy.sql',
    [string]$OracleSid = $(if ($env:ORACLE_SID) { $env:ORACLE_SID } else { 'oracledba' }),
    [string]$PdbName = 'pdborcldba',
    [switch]$EnsureService
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Invoke-SqlPlus {
    param(
        [Parameter(Mandatory)][string]$ConnectString,
        [Parameter(Mandatory)][string]$Sql
    )

    $tempFile = Join-Path ([System.IO.Path]::GetTempPath()) ("deploy_" + [guid]::NewGuid().ToString('N') + '.sql')
    try {
        Set-Content -Path $tempFile -Value $Sql -Encoding ASCII
        $output = & sqlplus -S -L $ConnectString "@$tempFile" 2>&1
        $exitCode = $LASTEXITCODE
        return [pscustomobject]@{
            ExitCode = $exitCode
            Output   = ($output | Out-String).Trim()
        }
    }
    finally {
        Remove-Item -Path $tempFile -ErrorAction SilentlyContinue
    }
}

if ($EnsureService) {
    Write-Host "Ensuring service '$ServiceName' exists and is running in PDB '$PdbName'..."
    $env:ORACLE_SID = $OracleSid
    $ensureSql = @"
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
    $res = Invoke-SqlPlus -ConnectString '/ as sysdba' -Sql $ensureSql
    if ($res.ExitCode -ne 0) {
        Write-Error "Failed to ensure service '$ServiceName':`n$($res.Output)"
        exit $res.ExitCode
    }
    Start-Sleep -Seconds 2
    Write-Host "Service '$ServiceName' is ready."
}

if (-not $Password) {
    throw 'Database password is required. Pass -Password or set $env:DB_PASSWORD.'
}

$resolvedScriptsDir = (Resolve-Path -Path $ScriptsDir).Path
$manifestPath = Join-Path $resolvedScriptsDir $ManifestFile
if (-not (Test-Path $manifestPath)) {
    throw "Manifest file not found: $manifestPath"
}

$connect = "$Username/$Password@$Server`:$Port/$ServiceName"
Write-Host "Deploying '$ManifestFile' to $Username@$Server`:$Port/$ServiceName..."

Push-Location $resolvedScriptsDir
try {
    # Run from ScriptsDir so @@ relative paths in deploy.sql resolve cleanly
    & sqlplus -S -L $connect "@$ManifestFile"
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Error "Deployment failed with SQL*Plus exit code $exitCode."
    exit $exitCode
}

Write-Host 'Deployment completed successfully.'
exit 0