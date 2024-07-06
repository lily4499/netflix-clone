pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID = credentials('aws-ECR-access-key-id')
        AWS_SECRET_ACCESS_KEY = credentials('aws-ECR-secret-access-key')
        AWS_REGION = 'us-east-1'
        ECR_REPOSITORY_URI = '637423529262.dkr.ecr.us-east-1.amazonaws.com/ecr-netflix'
        IMAGE_TAG = "v2"
    }

    stages {

        stage('Install Dependencies and Build') {
            steps {
                sh '''
                    npm install
                '''
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    sh '''
                        docker build -t react-netflix-clone .
                    '''
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
                    trivy image --format template --template trivy-template.tpl --output trivy_report.html $ECR_REPOSITORY_URI:$IMAGE_TAG
                '''
            }
        }

        stage('Tag Docker Image') {
            steps {
                script {
                    sh '''
                        docker tag react-netflix-clone $ECR_REPOSITORY_URI:$IMAGE_TAG
                    '''
                }
            }
        }

        stage('Login to ECR') {
            steps {
                script {
                    sh '''
                        aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $ECR_REPOSITORY_URI
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
    }
}
