@Library('Shared') _

pipeline {
    agent any

    environment {
        SONAR_HOME = tool "Sonar"
    }

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: "v1.0.${env.BUILD_NUMBER}", description: 'Docker tag for frontend')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: "v1.0.${env.BUILD_NUMBER}", description: 'Docker tag for backend')
    }

    stages {
        stage("Workspace cleanup") {
            steps {
                cleanWs()
            }
        }

        stage("Git: Code Checkout") {
            steps {
                script {
                    code_checkout("https://github.com/shrinidhi972004/Image-and-video-gallery-using-aws-s3-.git", "main")
                }
            }
        }

        stage("Trivy: Filesystem scan") {
            steps {
                trivy_scan()
            }
        }

        stage("OWASP: Dependency Check") {
            steps {
                owasp_dependency("image-video-gallery", "./application/backend", "owasp-report")
            }
        }

        stage("SonarQube: Code Analysis") {
            steps {
                sonarqube_analysis("Sonar", "image-video-gallery", "image-video-gallery", "./application")
            }
        }

        stage("SonarQube: Quality Gate") {
            steps {
                sonarqube_code_quality()
            }
        }

        stage("Update Environment Variables") {
            parallel {
                stage("Backend Env") {
                    steps {
                        sh "bash automation/update-backend-env.sh"
                    }
                }
                stage("Frontend Env") {
                    steps {
                        sh "bash automation/update-frontend-env.sh"
                    }
                }
            }
        }

        stage("Docker: Build Images") {
            parallel {
                stage("Backend Build") {
                    steps {
                        dir("application/backend") {
                            docker_build("image-video-backend", "${params.BACKEND_DOCKER_TAG}", "shrinidhiupadhyaya")
                        }
                    }
                }
                stage("Frontend Build") {
                    steps {
                        dir("application/frontend") {
                            docker_build("image-video-frontend", "${params.FRONTEND_DOCKER_TAG}", "shrinidhiupadhyaya")
                        }
                    }
                }
            }
        }

        stage("Docker: Push Images") {
            steps {
                script {
                    docker_push("image-video-backend", "${params.BACKEND_DOCKER_TAG}", "shrinidhiupadhyaya")
                    docker_push("image-video-frontend", "${params.FRONTEND_DOCKER_TAG}", "shrinidhiupadhyaya")
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: '**/owasp-report/*.xml', followSymlinks: false
            build job: "ImageVideoGallery-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG}")
            ]
        }
    }
}
