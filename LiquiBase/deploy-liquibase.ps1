[CmdletBinding()]
param(
    [ValidateSet('update', 'status', 'validate', 'update-sql', 'history', 'rollback-count')]
    [string]$Command = 'update',
    [string]$Server = $(if ($env:DB_HOST) { $env:DB_HOST } else { 'localhost' }),
    [int]$Port = $(if ($env:DB_PORT) { [int]$env:DB_PORT } else { 1521 }),
    [string]$ServiceName = $(if ($env:DB_SERVICE) { $env:DB_SERVICE } else { 'foApp' }),
    [string]$Username = $(if ($env:DB_USER) { $env:DB_USER } else { 'app_user' }),
    [string]$Password = $(if ($env:DB_PASSWORD) { $env:DB_PASSWORD } else { $env:LIQUIBASE_COMMAND_PASSWORD }),
    [string]$JdbcJar = 'D:\app\anikris_dba\product\12.2.0\dbhome_1\jdbc\lib\ojdbc8.jar',
    [int]$RollbackCount = 1
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

if (-not $Password) {
    throw 'Database password is required. Pass -Password or set $env:DB_PASSWORD / $env:LIQUIBASE_COMMAND_PASSWORD.'
}

if (-not (Test-Path $JdbcJar)) {
    throw "Oracle JDBC driver not found: $JdbcJar"
}

$cmd = Get-Command 'liquibase' -ErrorAction SilentlyContinue | Select-Object -First 1
if ($cmd) {
    $liquibaseExe = $cmd.Source
}
elseif (Test-Path 'C:\Program Files\liquibase\liquibase.bat') {
    $liquibaseExe = 'C:\Program Files\liquibase\liquibase.bat'
}
else {
    throw 'Liquibase CLI not found on PATH or in C:\Program Files\liquibase\liquibase.bat.'
}

$jdbcUrl = "jdbc:oracle:thin:@//$Server`:$Port/$ServiceName"
$env:LIQUIBASE_COMMAND_URL = $jdbcUrl
$env:LIQUIBASE_COMMAND_USERNAME = $Username
$env:LIQUIBASE_COMMAND_PASSWORD = $Password
$env:LIQUIBASE_COMMAND_CLASSPATH = $JdbcJar

$lbArgs = @($Command)
if ($Command -eq 'status') {
    $lbArgs += '--verbose'
}
elseif ($Command -eq 'rollback-count') {
    $lbArgs += "--count=$RollbackCount"
}

Write-Host "Running: liquibase $($lbArgs -join ' ') against $Username@$Server`:$Port/$ServiceName"

Push-Location $PSScriptRoot
try {
    & $liquibaseExe @lbArgs
    $exitCode = $LASTEXITCODE
}
finally {
    Pop-Location
}

if ($exitCode -ne 0) {
    Write-Error "Liquibase '$Command' failed with exit code $exitCode."
    exit $exitCode
}

Write-Host "Liquibase '$Command' completed successfully."
exit 0
