#!groovy

node {
    checkout scm

    stage 'arch-base'
    dir('arch-base') {
        sh 'sudo ./build.sh'
    }

    stage 'arch-devel'
    dir('arch-devel') {
        sh 'sudo ./build.sh'
    }
}
