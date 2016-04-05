#!groovy

node {
    checkout scm

    dir('docker') {
        stage 'Build Images'
        sh 'sudo /bin/sh ./build.sh'
    }
}
