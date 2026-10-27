pipeline {
    agent any
    options { timeout(time: 10, unit: 'MINUTES'); timestamps(); disableConcurrentBuilds() }
    parameters {
        booleanParam(name: 'LOCAL_REHEARSAL', defaultValue: false, description: 'Build the prepared local files; this does not verify the GitHub part of Set 15')
        string(name: 'REPO_URL', defaultValue: 'https://github.com/Ayaan-1082/simple-java-app.git', description: 'GitHub HTTPS URL of your copy of this complete lab repository')
        string(name: 'BRANCH', defaultValue: 'kubernetes-practical', description: 'Git branch')
        string(name: 'GIT_CREDENTIALS_ID', defaultValue: '', description: 'Jenkins Git credential ID; empty for public repositories')
        booleanParam(name: 'PUSH_DOCKERHUB', defaultValue: false, description: 'Push to a public Docker Hub repository before deployment')
        string(name: 'DOCKERHUB_NAMESPACE', defaultValue: '', description: 'Docker Hub username or organization; required when pushing')
    }
    triggers { pollSCM('H/2 * * * *'); githubPush() }
    stages {
        stage('Checkout or identify local rehearsal') {
            steps {
                script {
                    if (params.LOCAL_REHEARSAL) {
                        currentBuild.description = 'LOCAL REHEARSAL: GitHub integration not verified'
                        echo 'Using prepared local files. This run verifies build, tests and deployment; GitHub checkout and triggering are not verified.'
                    } else {
                        if (!(params.REPO_URL.trim() ==~ /^https:\/\/github\.com\/[A-Za-z0-9_.-]+\/[A-Za-z0-9_.-]+(?:\.git)?\/?$/)) {
                            error('Set REPO_URL to your GitHub HTTPS repository URL, or explicitly choose LOCAL_REHEARSAL.')
                        }
                        git branch: params.BRANCH, credentialsId: params.GIT_CREDENTIALS_ID.trim(), url: params.REPO_URL.trim()
                        bat 'git log -1 --format="%%H %%s"'
                    }
                    if (params.PUSH_DOCKERHUB) {
                        if (!(params.DOCKERHUB_NAMESPACE.trim() ==~ /^[a-z0-9][a-z0-9_-]*$/)) {
                            error('A lowercase Docker Hub username or organization is required.')
                        }
                        env.LAB_IMAGE = "${params.DOCKERHUB_NAMESPACE.trim()}/k8s-practical-app:set15-${env.BUILD_NUMBER}"
                    } else {
                        env.LAB_IMAGE = "k8s-practical-app:set15-${env.BUILD_NUMBER}"
                    }
                }
            }
        }
        stage('Build Docker image') {
            steps { bat 'docker build -t %LAB_IMAGE% .' }
        }
        stage('Test built application') {
            steps { bat 'docker run --rm %LAB_IMAGE% npm test' }
        }
        stage('Push to Docker Hub when selected') {
            when { expression { params.PUSH_DOCKERHUB } }
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    powershell '''
                        $ErrorActionPreference = 'Stop'
                        $workspacePath = [IO.Path]::GetFullPath($env:WORKSPACE).TrimEnd('\\')
                        $env:DOCKER_CONFIG = [IO.Path]::GetFullPath((Join-Path $workspacePath '.docker-auth'))
                        if ([IO.Path]::GetDirectoryName($env:DOCKER_CONFIG) -ne $workspacePath) {
                            throw 'The temporary Docker login folder is outside the Jenkins workspace.'
                        }
                        New-Item -ItemType Directory -Force $env:DOCKER_CONFIG | Out-Null
                        try {
                            $env:DOCKER_PASS | & docker login --username $env:DOCKER_USER --password-stdin
                            if ($LASTEXITCODE -ne 0) { throw 'Docker Hub login failed.' }
                            & docker push $env:LAB_IMAGE
                            if ($LASTEXITCODE -ne 0) { throw 'Docker Hub push failed.' }
                        } finally {
                            if ([IO.Path]::GetDirectoryName([IO.Path]::GetFullPath($env:DOCKER_CONFIG)) -ne $workspacePath) {
                                throw 'Refusing to remove a folder outside the Jenkins workspace.'
                            }
                            Remove-Item -LiteralPath $env:DOCKER_CONFIG -Recurse -Force -ErrorAction SilentlyContinue
                        }
                    '''
                }
            }
        }
        stage('Deploy and verify Service') {
            steps { powershell '.\\scripts\\Deploy-App.ps1 -SetNumber 15' }
        }
    }
    post {
        success { echo 'Build, tests, rollout and HTTP check passed. Check the build description to distinguish a local rehearsal from a GitHub run.' }
        failure {
            bat(returnStatus: true, script: 'kubectl --context docker-desktop -n k8s-set-15 get pods -o wide')
            bat(returnStatus: true, script: 'kubectl --context docker-desktop -n k8s-set-15 get events --sort-by=.metadata.creationTimestamp')
        }
    }
}
