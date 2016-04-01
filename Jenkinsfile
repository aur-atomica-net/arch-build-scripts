#!groovy

stage 'build arch-base'
node {
    stage 'checkout'
    checkout scm
    sh 'sudo ./build-arch-base.sh'
}
