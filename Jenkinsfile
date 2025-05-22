pipeline {
    agent any
    tools {
        jdk 'jdk17'
        nodejs 'node16'
    }
    environment {
        SCANNER_HOME = tool 'sonar-scanner'
    }
    stages {
        stage('Clean Workspace') {
            steps {
                cleanWs()
            }
        }
        stage('Checkout from Git') {
            steps {
                git branch: 'main', url: 'https://github.com/Tajalsir-Merghani/Netflix-clone.git'
            }
        }
        stage('SonarQube Analysis') {
            steps {
                withSonarQubeEnv('sonar-server') {
                    sh """
                        ${SCANNER_HOME}/bin/sonar-scanner \
                        -Dsonar.projectKey=Netflix \
                        -Dsonar.projectName=Netflix \
                        -Dsonar.sources=. \
                        -Dsonar.login=${env.SONAR_AUTH_TOKEN}
                    """
                }
            }
        }
        stage('Quality Gate') {
            steps {
                script {
                    waitForQualityGate abortPipeline: false, credentialsId: 'sonar-server'
                }
            }
        }
        stage('Install Dependencies') {
            steps {
                sh "npm install"
            }
        }
        stage('OWASP FS SCAN') {
            steps {
                dependencyCheck additionalArguments: '--scan ./ --disableYarnAudit --disableNodeAudit', odcInstallation: 'DP-Check'
                dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
            }
        }
        stage('TRIVY FS SCAN') {
            steps {
                sh "trivy fs . > trivyfs.txt"
            }
        }
        stage("Docker Build & Push") {
            steps {
                script {
                    docker.withRegistry('https://index.docker.io/v1/', 'dochubcred') {
                        def app = docker.build("tajooj/netflix:latest", "--build-arg TMDB_V3_API_KEY=1292640d8ce7df23d535e4f355ea5d7e .")
                        app.push("latest")
                    }
                }
            }
        }
        stage("TRIVY Image Scan") {
            steps {
                sh "trivy image tajooj/netflix:latest > trivyimage.txt"
            }
        }
        stage('Deploy to Container') {
            steps {
                sh 'docker run -d --name netflix -p 8081:80 tajooj/netflix:latest'
            }
        }
    }
    post {
        always {
            emailext attachLog: true,
                subject: "'${currentBuild.result}'",
                body: "Project: ${env.JOB_NAME}<br/>" +
                      "Build Number: ${env.BUILD_NUMBER}<br/>" +
                      "URL: ${env.BUILD_URL}<br/>",
                to: 'tajooj45@gmail.com',
                attachmentsPattern: 'trivyfs.txt'
        }
    }
}
