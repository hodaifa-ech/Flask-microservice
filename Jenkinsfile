pipeline {
  
    agent any

    environment {
        AWS_REGION        = 'us-east-1' 
        TF_STATE_BUCKET   = 'my-devops-terraform-state-unique' 
        TF_LOCK_TABLE     = 'my-devops-terraform-locks'      
        K8S_DIR           = 'k8s'
        APP_DIR           = 'microservices-app'
        CLUSTER_NAME      = 'devops-microservices-eks' 
        AWS_ACCOUNT_ID    = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
        ECR_REGISTRY      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
        AUTH_SERVICE_NAME = 'auth-service'
        VIDEO_SERVICE_NAME= 'video-service'
        AUTH_IMAGE_NAME   = "${ECR_REGISTRY}/${AUTH_SERVICE_NAME}"
        VIDEO_IMAGE_NAME  = "${ECR_REGISTRY}/${VIDEO_SERVICE_NAME}"
        IMAGE_TAG         = "build-${env.BUILD_NUMBER}" 
    }

    options {
        timestamps() 
        buildDiscarder(logRotator(numToKeepStr: '10')) 
        timeout(time: 1, unit: 'HOURS') 
    }

    stages {
        stage('1. Checkout Code') {
            steps {
                echo "Checking out code from ${env.BRANCH_NAME}..."
                checkout scm
            }
        }

        stage('2. Initialize Tools & Login') {
            steps {
                script {
                    echo "Verifying tools..."
                    sh 'aws --version'
                    sh 'kubectl version --client'
                    sh 'docker --version'
                    sh 'terraform version'

                    echo "Configuring kubectl for cluster: ${CLUSTER_NAME}"
                    sh "aws eks update-kubeconfig --region ${AWS_REGION} --name ${CLUSTER_NAME}"
                    sh "kubectl config current-context"
                    sh "kubectl get nodes" 

                    echo "Logging into AWS ECR: ${ECR_REGISTRY}"
                    
                    sh "aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REGISTRY}"
                }
            }
        }

        stage('3. Build Docker Images') {
            steps {
                script {
                    echo "Building ${AUTH_SERVICE_NAME}:${IMAGE_TAG}"
                    
                    docker.build("${AUTH_IMAGE_NAME}:${IMAGE_TAG}", "-f ${APP_DIR}/auth_service/Dockerfile ${APP_DIR}/auth_service")

                    echo "Building ${VIDEO_SERVICE_NAME}:${IMAGE_TAG}"
                    docker.build("${VIDEO_IMAGE_NAME}:${IMAGE_TAG}", "-f ${APP_DIR}/video_service/Dockerfile ${APP_DIR}/video_service")
                }
            }
        }

        

        stage('5. Push Docker Images to ECR') {
            
            steps {
                script {
                    echo "Pushing ${AUTH_IMAGE_NAME}:${IMAGE_TAG}"
                    docker.image("${AUTH_IMAGE_NAME}:${IMAGE_TAG}").push()

                    echo "Pushing ${VIDEO_IMAGE_NAME}:${IMAGE_TAG}"
                    docker.image("${VIDEO_IMAGE_NAME}:${IMAGE_TAG}").push()
                }
            }
        }

        stage('6. Deploy to Kubernetes (EKS)') {
            steps {
                script {
                    echo "Deploying services to EKS cluster ${CLUSTER_NAME} using manifests in ${K8S_DIR}/"

                  
                    echo "Replacing image placeholders in Kubernetes manifests..."
                    sh """
                        sed -i 's|AUTH_IMAGE_PLACEHOLDER|${AUTH_IMAGE_NAME}:${IMAGE_TAG}|g' ${K8S_DIR}/auth-deployment.yaml
                        sed -i 's|VIDEO_IMAGE_PLACEHOLDER|${VIDEO_IMAGE_NAME}:${IMAGE_TAG}|g' ${K8S_DIR}/video-deployment.yaml
                    """
                    echo "Applying manifests..."
                    sh "kubectl apply -f ${K8S_DIR}/" 

                    // Verify rollout
                    echo "Waiting for deployments to complete..."
                    sh "kubectl rollout status deployment/auth-deployment --timeout=2m"
                    sh "kubectl rollout status deployment/video-deployment --timeout=2m"
                }
            }
        }

        
      
    }

    post {
        always {
            echo 'Pipeline finished.'
            cleanWs()
            sh "docker logout ${ECR_REGISTRY} || true"
        }
        success {
            echo 'Pipeline SUCCEEDED!'
        }
        failure {
            echo 'Pipeline FAILED!'
        }
        changed {
             echo 'Pipeline status changed.'
        }
    }
}