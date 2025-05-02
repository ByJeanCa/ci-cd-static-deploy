pipeline {
    agent any
    stages {
        stage("Clean work space") {
            steps {
                sh 'rm -rf $WORKSPACE/*'
            }
        }
        stage("Clone repo") {
            steps {
                git url: 'https://github.com/ByJeanCa/ci-cd-static-deploy.git', credentialsId: 'git-token', branch: 'main'
            }
        }
        stage("DEBUG CHECK CLONE REPO ") {
            sh 'ls'
        }

        stage("Checking the required files") {
            steps {
                sh 'chmod +x scripts/validate_files.sh'
                sh 'scripts/validate_files.sh'
            }
        }
        stage("Build and run static-web container") {
            steps {
                sh """
                docker build -t static-web .
                docker run -d -p 8081:80 static-web
                """
            }
        }
        stage("Test static-web container") {
            steps {
                sh 'curl https://localhost:8081'
            }
        }
    }
}