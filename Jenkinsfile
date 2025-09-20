@Library('Shared') _
pipeline {
    agent any

    environment {
        SONAR_HOME = tool "Sonar"
        BUILD_TAG = "v1.0.${env.BUILD_NUMBER}"
    }

    parameters {
        string(name: 'FRONTEND_DOCKER_TAG', defaultValue: "", description: 'Docker tag for frontend')
        string(name: 'BACKEND_DOCKER_TAG', defaultValue: "", description: 'Docker tag for backend')
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
                    code_checkout("https://github.com/Shrinidhi972004/Image-and-video-gallery-using-aws-s3-.git", "master")
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
                owasp_dependency("image-video-gallery", "application/backend", "owasp-report")
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

        stage("Docker: Build Images") {
            parallel {
                stage("Backend Build") {
                    steps {
                        dir("application/backend") {
                            script {
                                def backendTag = params.BACKEND_DOCKER_TAG ?: env.BUILD_TAG
                                docker_build("image-video-backend", backendTag, "shrinidhiupadhyaya")
                            }
                        }
                    }
                }
                stage("Frontend Build") {
                    steps {
                        dir("application/frontend") {
                            script {
                                def frontendTag = params.FRONTEND_DOCKER_TAG ?: env.BUILD_TAG
                                docker_build("image-video-frontend", frontendTag, "shrinidhiupadhyaya")
                            }
                        }
                    }
                }
            }
        }

        stage("Docker: Push Images") {
            steps {
                script {
                    def backendTag = params.BACKEND_DOCKER_TAG ?: env.BUILD_TAG
                    def frontendTag = params.FRONTEND_DOCKER_TAG ?: env.BUILD_TAG
                    docker_push("image-video-backend", backendTag, "shrinidhiupadhyaya")
                    docker_push("image-video-frontend", frontendTag, "shrinidhiupadhyaya")
                }
            }
        }
    }

    post {
        success {
            archiveArtifacts artifacts: '**/owasp-report/*.xml', followSymlinks: false
            build job: "ImageVideoGallery-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG ?: env.BUILD_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG ?: env.BUILD_TAG}")
            ]
        }
    }
}
