pipeline {
    agent any
    // environment {
    //     CC = 'clang'
    //     GIT_HUB_CREDENTIALS = credentials('3158cb43-1241-473a-8a86-9e606db3904a')
    // }
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
            environment {
                CC = 'clang'
                GIT_HUB_CREDENTIALS = credentials('3158cb43-1241-473a-8a86-9e606db3904a')
            }
            steps{
                echo 'creds = ${env.GIT_HUB_CREDENTIALS}'
                echo 'username = $GIT_HUB_CREDENTIALS_USR'
                echo 'password = $GIT_HUB_CREDENTIALS_PWS'                
            }
            
        }
    }
}