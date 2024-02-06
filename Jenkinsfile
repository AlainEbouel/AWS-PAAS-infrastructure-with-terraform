pipeline {
    agent {label 'agent'}
    parameters {
        string(name: 'APP_NAME')
        string(name: 'PACKAGE')
    }

    stages {
        stage('build maven package'){

        when { expression { package params.PACKAGE } }

            steps{
              sh 'cd code/${params.APP_NAME}'
              sh 'mvn clean verify -f code/${params.APP_NAME}/pom.xml'             
            }            
        }

        stage('build docker image'){
            steps{
              script {                  
                dockerImage = docker.build("244586165116.dkr.ecr.ca-central-1.amazonaws.com/${params.APP_NAME}:${env.BUILD_ID}", "code/${params.APP_NAME}")
                docker.withRegistry('https://244586165116.dkr.ecr.ca-central-1.amazonaws.com', 'ecr:ca-central-1:aws-credentials-gigi-admin'){
                    dockerImage.push()
                }
              }
            }            
        }
    }
}