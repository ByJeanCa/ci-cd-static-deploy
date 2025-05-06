pipeline {
    agent any
    environment {
        INVENTORY = 'inventory/hosts'
        PLAYBOOK = 'static-web-deploy.yml'
    }
    stages {
        stage("Checkout") {
            steps {
                checkout scm
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
                    docker run -d --name static-web -p 8083:80 --network jenkins-net static-web 
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
            agent {
                docker {
                    image 'willhallonline/ansible:latest'
                    args '-u 0 --network jenkins-net -v $WORKSPACE:/workspace'

                }
            }
            when {
                branch 'main'
            }
            steps {
                withCredentials([
                    file(credentialsId: 'ansible-ssh-key', variable: 'SSH_PRIVATE_KEY'),
                    string(credentialsId: 'ansible-vault-pass', variable: 'VAULT_PASS')
                    ]) {
                        sh """
                        mkdir -p ~/.ssh

                        cp $SSH_PRIVATE_KEY ~/.ssh/id_rsa
                        chmod 600 ~/.ssh/id_rsa

                        echo "$VAULT_PASS" > vault_pass.txt
                        ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --become --extra-vars "@pass/password.pass" --vault-password-file=vault_pass.txt --limit gren
                        ansible-playbook -i ${INVENTORY} ${PLAYBOOK} --become --extra-vars "@pass/password.pass" --vault-password-file=vault_pass.txt --limit blue
                    
                        rm -rf vault_pass.txt
                        rm -rf ~/.ssh
                        """
                    
                }
            }
        }
    }
}
