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
        stage("A"){
            steps{
                echo "CC=${CC}"
                echo "DEBUG_FLAGS=${DEBUG_FLAGS}"
            }
        }
    }
}