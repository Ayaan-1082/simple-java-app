param([Parameter(Mandatory)][ValidateRange(1,15)][int]$SetNumber)
$ErrorActionPreference = 'Stop'
if ($env:BUILD_NUMBER -notmatch '^\d+$') { throw 'Run this script from a Jenkins build.' }
$setId = '{0:D2}' -f $SetNumber
$image = "k8s-set-${setId}:build-$env:BUILD_NUMBER"
$labRoot = Split-Path $PSScriptRoot -Parent
$context = Join-Path $labRoot ".set-image-context-$setId-$env:BUILD_NUMBER"
$exercise = Join-Path $context 'exercise'
$evidence = Join-Path $labRoot 'set-image-evidence'
New-Item -ItemType Directory -Path $exercise,$evidence -Force | Out-Null
Get-ChildItem -LiteralPath (Join-Path $labRoot "sets/set-$setId") -File |
    Copy-Item -Destination $exercise -Force
$metadata = [ordered]@{
    set = $SetNumber
    build = [int]$env:BUILD_NUMBER
    image = $image
    createdUtc = [DateTime]::UtcNow.ToString('o')
    namespace = "k8s-set-$setId"
    purpose = 'Additional image-build demonstration accompanying the Kubernetes exercise'
}
$json = $metadata | ConvertTo-Json
[IO.File]::WriteAllText((Join-Path $context 'build.json'),$json,[Text.UTF8Encoding]::new($false))
[IO.File]::WriteAllText((Join-Path $evidence 'build.json'),$json,[Text.UTF8Encoding]::new($false))
& docker build --progress=plain -f (Join-Path $labRoot 'docker/SetImage.Dockerfile') `
    --build-arg "SET_NUMBER=$setId" --build-arg "BUILD_NUMBER=$env:BUILD_NUMBER" `
    --build-arg "CREATED_AT=$($metadata.createdUtc)" -t $image $context
if ($LASTEXITCODE -ne 0) { throw 'The set demonstration image did not build.' }
& docker run --rm $image nginx -t
if ($LASTEXITCODE -ne 0) { throw 'The built nginx image failed its configuration check.' }
$inspection = & docker image inspect $image | ConvertFrom-Json
if ($LASTEXITCODE -ne 0) { throw 'Could not inspect the built image.' }
$inspection | Select-Object Id,RepoTags,Created,@{n='Labels';e={$_.Config.Labels}} |
    ConvertTo-Json -Depth 5 | Set-Content (Join-Path $evidence 'docker-image.json') -Encoding utf8
Write-Output "DOCKER DESKTOP: Images -> k8s-set-$setId -> build-$env:BUILD_NUMBER"
Write-Output "Built and checked image: $image"
