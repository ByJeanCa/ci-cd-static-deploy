pipeline {
    agent any
    environment {
        INVENTORY = 'inventory/hosts'
        PLAYBOOK = 'static-web-deploy.yml'
    }
    stages {
        stage("Clean work space") {
            steps {
                sh 'rm -rf $WORKSPACE/*'
            }
        }
        stage("Checkout") {
            steps {
                checkout scm
            }
        }
        stage("DEBUG CHECK CLONE REPO") {
            steps {
                sh 'ls'
            }
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
                    docker run -d --name static-web -p 8081:80 --network jenkins-net static-web 
                """
            }
        }
        stage("Test static-web container") {
            steps {
                sh 'curl http://static-web:80'
                sh 'docker stop static-web'
                sh 'docker rm static-web'
            }
        }
        stage("Deploy") { 
            when {
                branch 'main'
            }
            steps {
                withCredentials([string(variable: 'VAULT_PASS', credentialsId: 'ansible-vault-pass')]) {
                    sh """
                    echo "$VAULT_PASS" > vault_pass.txt
                    ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --become --extra-vars "@pass/password.pass" --vault-password-file=vault_pass.txt --limit blue
                    ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --become --extra-vars "@pass/password.pass" --vault-password-file=vault_pass.txt --limit green
                    rm -rf vault_pass.txt

                }
            }
        }
    }
}
