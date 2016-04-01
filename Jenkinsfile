#!groovy

stage 'arch-base'
node {
    checkout scm
    dir('arch-base') {
        sh 'sudo ./build.sh'
    }
}

stage 'arch-devel'
node {
    checkout scm
    dir('arch-devel') {
        sh 'sudo ./build.sh'
    }
}
