param(
    [Parameter(Mandatory)][ValidateSet(12,15)][int]$SetNumber
)
$ErrorActionPreference = 'Stop'
if (-not $env:LAB_IMAGE -or $env:LAB_IMAGE -notmatch '^[a-z0-9][a-z0-9./:_-]+$') {
    throw 'LAB_IMAGE must contain a valid lowercase image reference.'
}
$setId = '{0:D2}' -f $SetNumber
$namespace = "k8s-set-$setId"
$template = Get-Content -LiteralPath "sets/set-$setId/deployment.yaml" -Raw
$generated = "set-$setId.generated.yaml"
$template.Replace('__IMAGE__', $env:LAB_IMAGE) | Set-Content -LiteralPath $generated -Encoding utf8
& kubectl --context docker-desktop apply -f $generated
if ($LASTEXITCODE -ne 0) { throw 'Kubernetes apply failed.' }
& kubectl --context docker-desktop -n $namespace rollout status deployment/lab-app --timeout=180s
if ($LASTEXITCODE -ne 0) { throw 'The application did not become ready.' }
& kubectl --context docker-desktop -n $namespace exec deployment/lab-app -- node -e "fetch('http://lab-app:80/health').then(async r=>{if(!r.ok)process.exit(1);console.log(await r.text())}).catch(e=>{console.error(e);process.exit(1)})"
if ($LASTEXITCODE -ne 0) { throw 'The HTTP health check through the Kubernetes Service failed.' }
& kubectl --context docker-desktop -n $namespace get deployment,pods,service -o wide
if ($LASTEXITCODE -ne 0) { throw 'Could not collect deployment evidence.' }
