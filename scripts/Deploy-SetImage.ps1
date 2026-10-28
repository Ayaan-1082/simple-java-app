param([Parameter(Mandatory)][ValidateRange(1,15)][int]$SetNumber)
$ErrorActionPreference = 'Stop'
if ($env:BUILD_NUMBER -notmatch '^\d+$') { throw 'Run this script from a Jenkins build.' }
$setId = '{0:D2}' -f $SetNumber
$namespace = "k8s-set-$setId"
$image = "${namespace}:build-$env:BUILD_NUMBER"
$evidence = Join-Path (Split-Path $PSScriptRoot -Parent) 'set-image-evidence'
$labels = @{app='build-demo';'practical-set'=$setId}
$manifest = @{
    apiVersion='v1'; kind='List'; items=@(
        @{apiVersion='v1';kind='Namespace';metadata=@{name=$namespace}},
        @{apiVersion='apps/v1';kind='Deployment';metadata=@{name='build-demo';namespace=$namespace};spec=@{
            replicas=1;selector=@{matchLabels=$labels};template=@{
                metadata=@{labels=$labels;annotations=@{'practical/build'=$env:BUILD_NUMBER}}
                spec=@{containers=@(@{
                    name='demo';image=$image;imagePullPolicy='IfNotPresent';ports=@(@{containerPort=80})
                    readinessProbe=@{httpGet=@{path='/build.json';port=80};initialDelaySeconds=1;periodSeconds=2}
                    resources=@{requests=@{cpu='10m';memory='16Mi'};limits=@{cpu='100m';memory='64Mi'}}
                })}
            }
        }},
        @{apiVersion='v1';kind='Service';metadata=@{name='build-demo';namespace=$namespace};spec=@{
            selector=$labels;ports=@(@{port=80;targetPort=80})
        }}
    )
}
$manifestFile = Join-Path $evidence 'build-demo.generated.json'
$manifest | ConvertTo-Json -Depth 15 | Set-Content $manifestFile -Encoding utf8
& kubectl --context docker-desktop apply -f $manifestFile
if ($LASTEXITCODE -ne 0) { throw 'Could not deploy the demonstration image.' }
& kubectl --context docker-desktop -n $namespace rollout status deployment/build-demo --timeout=180s
if ($LASTEXITCODE -ne 0) { throw 'The demonstration image did not become ready.' }
$live = & kubectl --context docker-desktop -n $namespace exec deployment/build-demo -- wget -qO- http://127.0.0.1/build.json | ConvertFrom-Json
if ($LASTEXITCODE -ne 0 -or $live.build -ne [int]$env:BUILD_NUMBER -or $live.set -ne $SetNumber) {
    throw 'The running Pod did not return this build number.'
}
$live | ConvertTo-Json | Set-Content (Join-Path $evidence 'running-build.json') -Encoding utf8
& kubectl --context docker-desktop -n $namespace get deployment,pods,service -o wide
if ($LASTEXITCODE -ne 0) { throw 'Could not verify the set resources.' }
Write-Output "DOCKER DESKTOP: Kubernetes -> Namespace $namespace -> Deployment build-demo"
Write-Output "Verified running image $image with build number $($live.build)."
