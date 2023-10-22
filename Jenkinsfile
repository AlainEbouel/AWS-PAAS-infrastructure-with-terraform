pipeline {
    agent any
    environment {
        CC = 'clang'
        GIT_HUB_CREDENTIALS = credentials('3158cb43-1241-473a-8a86-9e606db3904a')
    }
    stages {
        // stage('Example') {
        //     environment {
        //         DEBUG_FLAGS = '-g'
        //     }
        //     steps {
        //         sh 'printenv'
        //     }
        // }
        stage('*************stage number 2 ******************'){
            steps{
                echo 'CC=CC'
                echo "CC=$CC"
                echo "DEBUG_FLAGS=${env.DEBUG_FLAGS}"
                echo 'creds = ${env.GIT_HUB_CREDENTIALS}'
                echo 'username = $GIT_HUB_CREDENTIALS_USR'
                echo 'password = $GIT_HUB_CREDENTIALS_PWS'  
                echo '--------------------------------------------------------------------------'
                echo 'password = $CC' 
                echo "CC=$GIT_HUB_CREDENTIALS_PWS"
            }
            
        }
    }
}