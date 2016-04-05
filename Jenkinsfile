#!groovy

node {
    checkout scm

    stage 'Build Docker Images'
    dir('docker') {
        sh 'sudo /bin/sh ./build.sh'
    }
}
