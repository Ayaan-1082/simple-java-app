pipeline {
    agent any
    environment {
        DOCKER_IMAGE = "robustcoder/java-app:latest"
        // Jenkins runs as LocalSystem: it needs explicit paths to Maven and the kubeconfig
        PATH = "C:\Users\khana\tools\apache-maven-3.9.9\bin;${env.PATH}"
        KUBECONFIG = "C:\Users\khana\.kube\config"
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: 'https://github.com/Ayaan-1082/simple-java-app.git'
            }
        }
        stage('Build with Maven') {
            steps {
                bat 'mvn clean package'
            }
        }
        stage('Build Docker Image') {
            steps {
                bat "docker build -t %DOCKER_IMAGE% ."
            }
        }
        stage('Push to DockerHub') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'dockerhub-creds',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    bat """
                        echo %DOCKER_PASS%| docker login -u %DOCKER_USER% --password-stdin
                        docker push %DOCKER_IMAGE%
                    """
                }
            }
        }
        stage('Deploy to Kubernetes') {
            steps {
                bat 'kubectl apply -f deployment.yaml'
            }
        }
    }
    post {
        success { echo 'CI/CD Pipeline executed successfully!' }
        failure { echo 'Pipeline failed. Please check logs.' }
    }
}
