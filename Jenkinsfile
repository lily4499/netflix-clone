pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-secret-access-key')
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY_URI = '637423529262.dkr.ecr.us-east-1.amazonaws.com/ecr-jenkins'
        IMAGE_TAG = "v2"
    }

    stages {
        stage('Login to ECR') {
            steps {
                script {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI
                    '''
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        docker build -t ecr-jenkins:$IMAGE_TAG .
                    '''
                }
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    sh '''
                        docker tag ecr-jenkins:$IMAGE_TAG $ECR_REPOSITORY_URI:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Push Docker Image to ECR') {
            steps {
                script {
                    sh '''
                        docker push $ECR_REPOSITORY_URI:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Install Trivy') {
            steps {
                script {
                    def trivyInstalled = sh(script: 'which trivy', returnStatus: true) == 0
                    if (!trivyInstalled) {
                        sh '''
                            curl -sfL https://raw.githubusercontent.com/aquasecurity/trivy/main/contrib/install.sh | sudo sh -s -- -b /usr/local/bin
                        '''
                    }
                }
            }
        }

        stage('Update Trivy DB') {
            steps {
                sh 'trivy image --download-db-only'
            }
        }

        stage('Run Trivy Scan') {
            steps {
                sh '''
                    echo '{{- range . }}\n{{ .Target }}\n{{ range .Vulnerabilities }}\n{{ .VulnerabilityID }} {{ .PkgName }} {{ .InstalledVersion }} {{ .FixedVersion }} {{ .Severity }} {{ .Title }}\n{{ end }}\n{{ end }}' > trivy-template.tpl
                   // trivy image --template trivy-template.tpl --output trivy_report.html $ECR_REPOSITORY_URI:$IMAGE_TAG
                    trivy image --format template --template trivy-template.tpl --output trivy_report.html $ECR_REPOSITORY_URI:$IMAGE_TAG
                '''
                '''
            }
        }

        stage('Install Dependencies and Build') {
            steps {
                sh '''
                    npm install
                    npm run build
                '''
            }
        }
    }
}
