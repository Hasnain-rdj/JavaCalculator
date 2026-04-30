param(
  [Parameter(Mandatory=$true)][string]$TomcatHome,
  [Parameter(Mandatory=$true)][string]$WarPath,
  [Parameter(Mandatory=$true)][string]$AppName
)

$ErrorActionPreference = 'Stop'

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

Write-Host "Stopping Tomcat..."
$shutdown = Join-Path $tomcatBin 'shutdown.bat'
if (Test-Path -LiteralPath $shutdown) {
  & $shutdown | Out-Host
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
& $startup | Out-Host

Write-Host "Waiting for app to come up..."
$deadline = (Get-Date).AddSeconds(60)
while ((Get-Date) -lt $deadline) {
  try {
    $resp = Invoke-WebRequest -UseBasicParsing -Uri ("http://localhost:9090/$AppName/") -TimeoutSec 10
    if ($resp.StatusCode -ge 200 -and $resp.StatusCode -lt 400) {
      Write-Host "Tomcat deployment looks healthy: http://localhost:9090/$AppName/"
      exit 0
    }
  } catch {
    Start-Sleep -Seconds 3
  }
}

throw "App did not become healthy in time: http://localhost:9090/$AppName/"