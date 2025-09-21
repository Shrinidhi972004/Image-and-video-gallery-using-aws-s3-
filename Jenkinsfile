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
                    code_checkout(
                        "https://github.com/Shrinidhi972004/Image-and-video-gallery-using-aws-s3-.git",
                        "master"
                    )
                }
            }
        }

        stage("Trivy: Filesystem scan") {
            steps {
                trivy_scan()
            }
        }

        stage("SonarQube: Code Analysis") {
            steps {
                sonarqube_analysis(
                    "Sonar",
                    "image-video-gallery",
                    "image-video-gallery",
                    "./application"
                )
            }
        }

        stage("SonarQube: Quality Gate") {
            steps {
                sonarqube_code_quality()
            }
        }

        stage("Docker: Build Images") {
            steps {
                script {
                    def backendTag = params.BACKEND_DOCKER_TAG ?: "latest"
                    def frontendTag = params.FRONTEND_DOCKER_TAG ?: "latest"

                    dir('application/backend') {
                        docker_build("image-video-backend", backendTag, "shrinidhiupadhyaya")
                    }

                    dir('application/frontend') {
                        docker_build("image-video-frontend", frontendTag, "shrinidhiupadhyaya")
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
            echo "✅ Build successful!"
            build job: "ImageVideoGallery-CD", parameters: [
                string(name: 'FRONTEND_DOCKER_TAG', value: "${params.FRONTEND_DOCKER_TAG ?: env.BUILD_TAG}"),
                string(name: 'BACKEND_DOCKER_TAG', value: "${params.BACKEND_DOCKER_TAG ?: env.BUILD_TAG}")
            ]
            
            emailext(
                subject: "✅ SUCCESS: Jenkins Build #${env.BUILD_NUMBER}",
                body: """<p>Good news 🎉</p>
                        <p>The Jenkins build <b>${env.JOB_NAME} #${env.BUILD_NUMBER}</b> completed successfully.</p>
                        <p>Docker images have been built & pushed:</p>
                        <ul>
                          <li>Backend → shrinidhiupadhyaya/image-video-backend:${params.BACKEND_DOCKER_TAG ?: env.BUILD_TAG}</li>
                          <li>Frontend → shrinidhiupadhyaya/image-video-frontend:${params.FRONTEND_DOCKER_TAG ?: env.BUILD_TAG}</li>
                        </ul>
                        <p>See details: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>""",
                to: "shrinidhiupadhyaya00@gmail.com"
            )
        }
        failure {
            echo "❌ Build failed. Check logs in Jenkins."
            emailext(
                subject: "❌ FAILURE: Jenkins Build #${env.BUILD_NUMBER}",
                body: """<p>Oops ⚠️</p>
                        <p>The Jenkins build <b>${env.JOB_NAME} #${env.BUILD_NUMBER}</b> has failed.</p>
                        <p>Check the logs here: <a href="${env.BUILD_URL}">${env.BUILD_URL}</a></p>""",
                to: "shrinidhiupadhyaya00@gmail.com"
            )
        }
    }
}
