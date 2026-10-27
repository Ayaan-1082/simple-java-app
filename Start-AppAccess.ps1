param([string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\work\lab-runtime'))
$ErrorActionPreference = 'Stop'
$runtime = [IO.Path]::GetFullPath($RuntimeDirectory)
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$kubectl = (Get-Command kubectl -ErrorAction Stop).Source
$shell = (Get-Command powershell.exe -ErrorAction Stop).Source
if (Test-Path -LiteralPath (Join-Path $runtime 'kubeconfig')) { $env:KUBECONFIG = Join-Path $runtime 'kubeconfig' }
$apps = @(
    @{Namespace='k8s-set-05'; Service='web'; Port=30005},
    @{Namespace='k8s-set-11'; Service='github-web'; Port=30011},
    @{Namespace='k8s-set-12'; Service='lab-app'; Port=30012},
    @{Namespace='k8s-set-15'; Service='lab-app'; Port=30015}
)
foreach ($app in $apps) {
    $watcherFile = Join-Path $runtime "watch-port-$($app.Port).pid"
    if (Test-Path -LiteralPath $watcherFile) {
        $watcher = Get-Process -Id ([int](Get-Content -LiteralPath $watcherFile)) -ErrorAction SilentlyContinue
        $watcherMatches = $watcher -and $watcher.ProcessName -in @('powershell','pwsh') -and [Math]::Abs(($watcher.StartTime - (Get-Item -LiteralPath $watcherFile).LastWriteTime).TotalSeconds) -lt 10
        if ($watcherMatches) {
            Write-Host "Browser access is maintained at http://localhost:$($app.Port)"
            continue
        }
    }
    $reachable = $false
    $client = New-Object Net.Sockets.TcpClient
    try { $reachable = $client.ConnectAsync('127.0.0.1', $app.Port).Wait(500) -and $client.Connected } catch {} finally { $client.Dispose() }
    if ($reachable) {
        $ownedPidFile = Join-Path $runtime "port-$($app.Port).pid"
        $ownedProcess = $null
        if (Test-Path -LiteralPath $ownedPidFile) { $ownedProcess = Get-Process -Id ([int](Get-Content -LiteralPath $ownedPidFile)) -ErrorAction SilentlyContinue }
        $ownedMatches = $ownedProcess -and $ownedProcess.Path -eq $kubectl -and [Math]::Abs(($ownedProcess.StartTime - (Get-Item -LiteralPath $ownedPidFile).LastWriteTime).TotalSeconds) -lt 10
        if ($ownedMatches) { Stop-Process -Id $ownedProcess.Id }
        else { Write-Host "Application port $($app.Port) already responds."; continue }
    }
    & $kubectl --context docker-desktop -n $app.Namespace get service $app.Service --request-timeout=5s 1>$null 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Run the job for $($app.Namespace), then run Start-AppAccess.ps1 again."; continue }
    $arguments = @('-NoProfile','-ExecutionPolicy','Bypass','-File',('"' + (Join-Path $PSScriptRoot 'setup\Watch-PortForward.ps1') + '"'),'-Namespace',$app.Namespace,'-Service',$app.Service,'-Port',$app.Port,'-RuntimeDirectory',('"' + $runtime + '"'))
    $process = Start-Process -FilePath $shell -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime "watch-port-$($app.Port).out.log") -RedirectStandardError (Join-Path $runtime "watch-port-$($app.Port).err.log")
    $process.Id | Set-Content -LiteralPath $watcherFile
    Write-Host "Browser access started: http://localhost:$($app.Port)"
}
