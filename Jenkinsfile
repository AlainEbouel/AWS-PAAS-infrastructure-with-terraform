pipeline {
    agent any
    environment {
        CC = 'clang'
    }
    stages {
        stage('Example') {
            environment {
                DEBUG_FLAGS = '-g'
            }
            steps {
                sh 'printenv'
            }
        }
        stage('*************stage number 2 ******************'){
            steps{
                echo 'CC=${CC}'
                echo "DEBUG_FLAGS=${DEBUG_FLAGS}"
            }
        }
    }
}