param(
    [string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\work\lab-runtime'),
    [string]$JenkinsWar = 'C:\Program Files\Jenkins\jenkins.war',
    [string]$PluginDirectory = 'C:\ProgramData\Jenkins\.jenkins\plugins',
    [ValidateRange(1024,65535)][int]$HttpPort = 8081
)
$ErrorActionPreference = 'Stop'
$labRoot = $PSScriptRoot
$runtime = [IO.Path]::GetFullPath($RuntimeDirectory)
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$java = (Get-Command java -ErrorAction Stop).Source
$docker = (Get-Command docker -ErrorAction Stop).Source
$kubectl = (Get-Command kubectl -ErrorAction Stop).Source
$mavenBin = Join-Path $env:USERPROFILE 'tools\apache-maven-3.9.9\bin'
$baseUrl = "http://localhost:$HttpPort"
if (!(Test-Path -LiteralPath $JenkinsWar)) { throw "Jenkins WAR not found: $JenkinsWar" }
& $kubectl --context docker-desktop get nodes --request-timeout=15s
if ($LASTEXITCODE -ne 0) { throw 'Start Docker Desktop and enable Kubernetes, then run Start-Lab.ps1 again.' }
$existing = $null
try { $existing = Invoke-WebRequest "$baseUrl/login" -TimeoutSec 3 -UseBasicParsing } catch {}
if ($existing) {
    if (!$existing.Headers['X-Jenkins']) { throw "Port $HttpPort is being used by another application. Choose another -HttpPort." }
    $savedPasswordFile = Join-Path $runtime 'lab-password.txt'
    if (!(Test-Path -LiteralPath $savedPasswordFile)) { throw "A different Jenkins is already using port $HttpPort. Choose another -HttpPort." }
    $savedPair = 'labadmin:' + [IO.File]::ReadAllText($savedPasswordFile).Trim()
    $savedHeaders = @{Authorization = 'Basic ' + [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes($savedPair))}
    try {
        $identity = Invoke-RestMethod "$baseUrl/whoAmI/api/json" -Headers $savedHeaders -TimeoutSec 5
        if (!$identity.authenticated -or $identity.name -ne 'labadmin') { throw 'The saved practice account was not recognized.' }
    } catch {
        throw "A different Jenkins is using port $HttpPort, or the saved practice password has changed. Your existing Jenkins was left running."
    }
    Write-Host "Port $HttpPort already responds. Existing lab left running; open $baseUrl."
    & (Join-Path $labRoot 'Start-AppAccess.ps1') -RuntimeDirectory $runtime
    return
}
$pidFile = Join-Path $runtime 'jenkins.pid'
if (Test-Path -LiteralPath $pidFile) {
    $previousPid = 0
    if ([int]::TryParse(([IO.File]::ReadAllText($pidFile).Trim()), [ref]$previousPid)) {
        $previousProcess = Get-Process -Id $previousPid -ErrorAction SilentlyContinue
        if ($previousProcess -and $previousProcess.ProcessName -eq 'java' -and
            [Math]::Abs(($previousProcess.StartTime - (Get-Item -LiteralPath $pidFile).LastWriteTime).TotalSeconds) -lt 10) {
            throw 'This lab Jenkins is already starting or running on another port. Use the address in Lab-Login.txt before starting another copy.'
        }
    }
}
$plugins = Join-Path $runtime 'plugins'
$init = Join-Path $runtime 'init.groovy.d'
New-Item -ItemType Directory -Path $plugins,$init -Force | Out-Null
Get-ChildItem -LiteralPath $PluginDirectory -File | Where-Object { $_.Extension -in '.jpi','.hpi' } | ForEach-Object {
    $destination = Join-Path $plugins $_.Name
    if (!(Test-Path -LiteralPath $destination)) { Copy-Item -LiteralPath $_.FullName -Destination $destination }
}
if (!(Test-Path -LiteralPath (Join-Path $plugins 'workflow-job.jpi'))) { throw 'Install the Jenkins Pipeline plugins in the existing Jenkins installation first.' }
Copy-Item -LiteralPath (Join-Path $labRoot 'setup\init-lab.groovy') -Destination (Join-Path $init 'init-lab.groovy') -Force
$kubeconfig = & $kubectl --context docker-desktop config view --minify --flatten --raw
if ($LASTEXITCODE -ne 0) { throw 'Cannot export the Docker Desktop kubeconfig.' }
[IO.File]::WriteAllText((Join-Path $runtime 'kubeconfig'), ($kubeconfig -join "`n"), [Text.UTF8Encoding]::new($false))
$passwordPath = Join-Path $runtime 'lab-password.txt'
if (!(Test-Path -LiteralPath $passwordPath)) {
    $bytes = New-Object byte[] 24
    $rng = [Security.Cryptography.RandomNumberGenerator]::Create()
    $rng.GetBytes($bytes)
    $rng.Dispose()
    [IO.File]::WriteAllText($passwordPath, [Convert]::ToBase64String($bytes))
}
$password = [IO.File]::ReadAllText($passwordPath).Trim()
$env:JENKINS_HOME = $runtime
$env:LAB_ROOT = $labRoot
$env:LAB_HTTP_PORT = [string]$HttpPort
$env:PATH = "$mavenBin;$(Split-Path $docker);$(Split-Path $kubectl);$env:PATH"
$arguments = @('-Xms128m', '-Xmx768m', '-Djenkins.install.runSetupWizard=false', '-jar', ('"' + $JenkinsWar + '"'), "--httpPort=$HttpPort", '--httpListenAddress=127.0.0.1', ('--webroot="' + (Join-Path $runtime 'war') + '"'))
$process = Start-Process -FilePath $java -ArgumentList $arguments -WorkingDirectory $labRoot -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime 'jenkins.out.log') -RedirectStandardError (Join-Path $runtime 'jenkins.err.log')
$process.Id | Set-Content -LiteralPath (Join-Path $runtime 'jenkins.pid')
$access = "LOCAL PRACTICE JENKINS`r`nURL: $baseUrl`r`nUsername: labadmin`r`nPassword: $password`r`n`r`nKeep this file private. Do not upload it to GitHub.`r`nRuntime: $runtime`r`n"
[IO.File]::WriteAllText((Join-Path $labRoot '..\Lab-Login.txt'), $access)
Write-Host "Jenkins is starting at $baseUrl. It may take one or two minutes."
Write-Host 'Your local login is in the Lab-Login.txt file beside the kubernetes-practical folder.'
& (Join-Path $labRoot 'Start-AppAccess.ps1') -RuntimeDirectory $runtime
