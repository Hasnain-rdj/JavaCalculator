param(
  [Parameter(Mandatory=$true)][string]$TomcatHome,
  [Parameter(Mandatory=$true)][string]$WarPath,
  [Parameter(Mandatory=$true)][string]$AppName
)

$ErrorActionPreference = 'Stop'
$ProgressPreference = 'SilentlyContinue'

function Assert-Path([string]$Path, [string]$Label) {
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "$Label not found: $Path"
  }
}

$tomcatBin = Join-Path $TomcatHome 'bin'
$tomcatWebapps = Join-Path $TomcatHome 'webapps'

Assert-Path $tomcatBin 'Tomcat bin folder'
Assert-Path $tomcatWebapps 'Tomcat webapps folder'
Assert-Path $WarPath 'WAR file'

# Tomcat's startup/shutdown scripts rely on these environment variables.
# Jenkins often runs under a service account with a different environment.
$env:CATALINA_HOME = $TomcatHome
$env:CATALINA_BASE = $TomcatHome

Write-Host "Stopping Tomcat..."
$shutdown = Join-Path $tomcatBin 'shutdown.bat'
if (Test-Path -LiteralPath $shutdown) {
  Push-Location $tomcatBin
  try {
    & $shutdown | Out-Host
  } finally {
    Pop-Location
  }
} else {
  Write-Host "shutdown.bat not found, continuing..."
}
Start-Sleep -Seconds 5

$destWar = Join-Path $tomcatWebapps ("$AppName.war")
$destDir = Join-Path $tomcatWebapps $AppName

Write-Host "Removing previous deployment (if any)..."
if (Test-Path -LiteralPath $destWar) { Remove-Item -LiteralPath $destWar -Force }
if (Test-Path -LiteralPath $destDir) { Remove-Item -LiteralPath $destDir -Recurse -Force }

Write-Host "Copying new WAR to Tomcat webapps..."
Copy-Item -LiteralPath $WarPath -Destination $destWar -Force

Write-Host "Starting Tomcat..."
$startup = Join-Path $tomcatBin 'startup.bat'
Assert-Path $startup 'startup.bat'
Push-Location $tomcatBin
try {
  & $startup | Out-Host
} finally {
  Pop-Location
}

Write-Host "Waiting for app to come up..."
$appUrl = "http://localhost:9090/$AppName/"
$serverUrl = 'http://localhost:9090/'
$deadline = (Get-Date).AddSeconds(120)
$attempt = 0

while ((Get-Date) -lt $deadline) {
  $attempt++
  try {
    # First check Tomcat is responding at all.
    $serverResp = Invoke-WebRequest -UseBasicParsing -Uri $serverUrl -TimeoutSec 5
    Write-Host "[$attempt] Tomcat responded: HTTP $($serverResp.StatusCode)"
  } catch {
    Write-Host "[$attempt] Tomcat not responding yet..."
    Start-Sleep -Seconds 3
    continue
  }

  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri $appUrl -TimeoutSec 10
    Write-Host "[$attempt] App responded: HTTP $($resp.StatusCode)"
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400) {
      Write-Host "Tomcat deployment looks healthy: $appUrl"
      exit 0
    }
  } catch {
    Write-Host "[$attempt] App not ready yet..."
  }

  Start-Sleep -Seconds 3
}

Write-Host "Timed out waiting for: $appUrl"
try {
  $logDir = Join-Path $TomcatHome 'logs'
  if (Test-Path -LiteralPath $logDir) {
    $latestLog = Get-ChildItem -LiteralPath $logDir -Filter 'catalina*.log' | Sort-Object LastWriteTime -Descending | Select-Object -First 1
    if ($latestLog) {
      Write-Host "Last 30 lines of $($latestLog.Name):"
      Get-Content -LiteralPath $latestLog.FullName -Tail 30 | ForEach-Object { Write-Host $_ }
    }
  }
} catch {
  # Best-effort; ignore log read failures.
}

throw "App did not become healthy in time: $appUrl"