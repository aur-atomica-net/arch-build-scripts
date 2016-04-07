#!groovy

node {
    checkout scm

    dir('docker') {
        stage 'Build Images'
        sh 'sudo /bin/sh ./build.sh'
    }

    stage 'Push to docker.artfire.me'
    docker.withRegistry('https://docker.artfire.me/', 'docker-artfire') {
        stage 'Push arch-base'
        def base = docker.image('arch-base')
        base.push()

        stage 'Push arch-devel'
        def devel = docker.image('arch-devel')
        devel.push()
    }
}
