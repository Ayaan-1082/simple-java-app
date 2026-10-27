param([string]$RuntimeDirectory = (Join-Path $PSScriptRoot '..\..\work\lab-runtime'))
$ErrorActionPreference = 'Stop'
$runtime = [IO.Path]::GetFullPath($RuntimeDirectory)
New-Item -ItemType Directory -Path $runtime -Force | Out-Null
$kubectl = (Get-Command kubectl -ErrorAction Stop).Source
if (Test-Path -LiteralPath (Join-Path $runtime 'kubeconfig')) { $env:KUBECONFIG = Join-Path $runtime 'kubeconfig' }
$apps = @(
    @{Namespace='k8s-set-05'; Service='web'; Port=30005},
    @{Namespace='k8s-set-11'; Service='github-web'; Port=30011},
    @{Namespace='k8s-set-12'; Service='lab-app'; Port=30012},
    @{Namespace='k8s-set-15'; Service='lab-app'; Port=30015}
)
foreach ($app in $apps) {
    $reachable = $false
    $client = New-Object Net.Sockets.TcpClient
    try { $reachable = $client.ConnectAsync('127.0.0.1', $app.Port).Wait(500) -and $client.Connected } catch {} finally { $client.Dispose() }
    if ($reachable) { Write-Host "Application port $($app.Port) already responds."; continue }
    & $kubectl --context docker-desktop -n $app.Namespace get service $app.Service --request-timeout=5s 1>$null 2>$null
    if ($LASTEXITCODE -ne 0) { Write-Host "Run the job for $($app.Namespace), then run Start-AppAccess.ps1 again."; continue }
    $arguments = @('--context', 'docker-desktop', '-n', $app.Namespace, 'port-forward', "service/$($app.Service)", "$($app.Port):80", '--address=127.0.0.1')
    $process = Start-Process -FilePath $kubectl -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime "port-$($app.Port).out.log") -RedirectStandardError (Join-Path $runtime "port-$($app.Port).err.log")
    $process.Id | Set-Content -LiteralPath (Join-Path $runtime "port-$($app.Port).pid")
    Write-Host "Browser access started: http://localhost:$($app.Port)"
}
