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

        // Checkout stage
        // stage('Checkout') {
        //     steps {
        //         git branch: github_branch, url: github_url
        //     }
        // }

        // Setup stage

        stage('Setup') {
            steps {
                // echo 'Setting up environment..'
                // sh './bin/build_deploy_local.sh 8086'
                sh 'ls'
            }
        }

        // Test stage. Pytest is used to test the unit tests
        // stage('Test') {
        //     agent {
        //         docker {
        //             image 'python:3.8' 
        //         }
        //     }
        //     steps {
        //         echo 'Testing model correctness..'
        //         sh 'pip install -r requirements.txt && pytest'
        //     }
        // }
        // stage('Build') {
        //     steps {
        //         script {
        //             echo 'Building image for deployment..'
        //             dockerImage = docker.build registry + ":$BUILD_NUMBER" 
        //             echo 'Pushing image to dockerhub..'
        //             docker.withRegistry( '', registryCredential ) {
        //                 dockerImage.push()
        //                 dockerImage.push('latest')
        //             }
        //         }
        //     }
        // }
        // stage('Deploy') {
        //     steps {
        //         echo 'Deploying models..'
        //         echo 'Running a script to trigger pull and start a docker container'
        //     }
        // }
    }
}