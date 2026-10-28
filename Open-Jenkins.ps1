param([switch]$NoBrowser)
$ErrorActionPreference = 'Stop'
$baseUrl = 'http://localhost:8081'
$runtime = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot '../../work/lab-runtime'))
$pidFile = Join-Path $runtime 'jenkins.pid'
$serverResponds = $false
try { $serverResponds = (Invoke-WebRequest "$baseUrl/login" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 } catch {}
if (!$serverResponds -and (Test-Path -LiteralPath $pidFile)) {
    $savedPid = 0
    if ([int]::TryParse(([IO.File]::ReadAllText($pidFile).Trim()), [ref]$savedPid)) {
        $process = Get-Process -Id $savedPid -ErrorAction SilentlyContinue
        $isStarting = $process -and $process.ProcessName -eq 'java' -and
            [Math]::Abs(($process.StartTime - (Get-Item -LiteralPath $pidFile).LastWriteTime).TotalSeconds) -lt 10
    }
}
if (!$isStarting) { & (Join-Path $PSScriptRoot 'Start-Lab.ps1') }
$deadline = [DateTime]::UtcNow.AddMinutes(2)
do {
    $ready = $false
    try { $ready = (Invoke-WebRequest "$baseUrl/login" -UseBasicParsing -TimeoutSec 3).StatusCode -eq 200 } catch {}
    if (!$ready) { Start-Sleep -Seconds 2 }
} until ($ready -or [DateTime]::UtcNow -ge $deadline)
if (!$ready) { throw 'Jenkins has not finished starting. Check the private runtime jenkins.err.log, then try again.' }
$savedPair = 'labadmin:' + [IO.File]::ReadAllText((Join-Path $runtime 'lab-password.txt')).Trim()
$headers = @{Authorization='Basic '+[Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($savedPair))}
$identity = Invoke-RestMethod "$baseUrl/whoAmI/api/json" -Headers $headers -TimeoutSec 8
if (!$identity.authenticated -or $identity.name -ne 'labadmin') { throw 'This server does not recognize the saved practice account.' }
Write-Host "Practice Jenkins is ready: $baseUrl"
Write-Host 'Username: labadmin. Password: Lab-Login.txt in the parent outputs folder.'
if (!$NoBrowser) { Start-Process $baseUrl }
