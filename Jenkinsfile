pipeline {
    agent any
    options{
        // Max number of build logs to keep and days to keep
        buildDiscarder(logRotator(numToKeepStr: '5', daysToKeepStr: '5'))
        // Enable timestamp at each job in the pipeline
        timestamps()
    }
    environment{
        // Set the github credentials
        github_branch = 'master'
        github_url = 'https://github.com/kemmin0510/jojogan-zombie.git'
        // Set the dockerhub credentials
        registry = 'minhnhk/jojogan-zombie'
        registryCredential = 'dockerhub'      
    }
    stages {
        // Setup stage
        stage('Setup') {
            steps {
                echo 'Setting up environment..'
                sh 'chmod +x ./bin/build_deploy_local.sh'
                sh "docker build -t ${registry}:latest ."
            }
        }

        // Test stage. Pytest is used to test the unit tests
        stage('Test') {
            agent {
                docker {
                    image "minhnhk/jojogan-zombie:latest"
                }
            }
            steps {
                echo 'Testing model correctness..'
                sh 'apt-get update'
                sh 'pip install pytest==8.3.4 requests==2.32.3 pytest-cov==6.0.0 locust==2.20.1'
                script {
                    def containerId = sh(script: "docker ps -q --filter ancestor=minhnhk/jojogan-zombie:latest", returnStdout: true).trim()
                    if (containerId) {
                        sh "docker cp ${containerId}:/app/models ./models"
                    } else {
                        error("Not found any container running from image minhnhk/jojogan-zombie:latest")
                    }
                }

                // Unit testing with pytest. The coverage is calculated
                sh 'pytest --cov=app'

                // Load testing with locust
                sh 'locust -f ./tests/locustfile.py --headless -u 10 -r 2 -t 1m --csv=./tests/locust_results --host http://localhost:8000'

                // echo 'Entering test container...'
                // sh 'echo "Container is running. Use docker exec -it $(docker ps -lq) /bin/bash to enter."' 
                // sh 'tail -f /dev/null'
            }
        }
        
        stage('Build') {
            steps {
                script {
                    echo 'Building image for deployment..'
                    dockerImage = docker.build registry + ":$BUILD_NUMBER" 
                    echo 'Pushing image to dockerhub..'
                    docker.withRegistry( '', registryCredential ) {
                        dockerImage.push()
                        dockerImage.push('latest')
                    }
                }
            }
        }
        stage('Deploy') {
            agent {
                kubernetes {
                    containerTemplate {
                        name 'helm' // Name of the container to be used for helm upgrade
                        image 'minhnhk/jenkins:lts-jdk17' // The image containing helm
                        alwaysPullImage true // Always pull image in case of using the same tag
                    }
                }
            }
            steps {
                script {
                    container('helm') {
                        sh """
                            helm upgrade --install jojogan-zombie ./helm/jojogan-zombie \\
                                --namespace model-serving
                            helm repo add prometheus-community \\
                                https://prometheus-community.github.io/helm-charts
                            helm repo update
                            helm upgrade --install node-exporter \\
                                prometheus-community/prometheus-node-exporter \\
                                --namespace kube-metrics \\
                                -f ./bin/node_exporter/node-exporter-values.yaml
                            kubectl apply -f ./helm/cadvisor/cadvisor-daemonset.yaml
                            kubectl apply -f ./helm/cadvisor/cadvisor-service.yaml
                        """
                        }
                    }
                }
            }
        }
    }