param(
    [Parameter(Mandatory)][string]$Namespace,
    [Parameter(Mandatory)][string]$Service,
    [Parameter(Mandatory)][int]$Port,
    [Parameter(Mandatory)][string]$RuntimeDirectory
)
$ErrorActionPreference = 'Continue'
$kubectl = (Get-Command kubectl -ErrorAction Stop).Source
$runtime = [IO.Path]::GetFullPath($RuntimeDirectory)
$env:KUBECONFIG = Join-Path $runtime 'kubeconfig'
while ($true) {
    $arguments = @('--context', 'docker-desktop', '-n', $Namespace, 'port-forward', "service/$Service", "${Port}:80", '--address=127.0.0.1')
    $process = Start-Process -FilePath $kubectl -ArgumentList $arguments -WindowStyle Hidden -PassThru -RedirectStandardOutput (Join-Path $runtime "port-$Port.out.log") -RedirectStandardError (Join-Path $runtime "port-$Port.err.log")
    $process.Id | Set-Content -LiteralPath (Join-Path $runtime "port-$Port.pid")
    $process.WaitForExit()
    Start-Sleep -Seconds 2
}
