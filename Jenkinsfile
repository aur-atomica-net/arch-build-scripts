#!groovy

node {
    // checkout scm

    // dir('docker') {
    //     stage 'Build Images'
    //     sh 'sudo /bin/sh ./build.sh'
    // }

    stage 'Push to docker.artfire.me'
    docker.withRegistry('https://index.docker.io/v1/', 'docker-jasonrm') {
        stage 'Push arch-base'
        def base = docker.image('atomica/arch-base')
        base.push()

        stage 'Push arch-devel'
        def devel = docker.image('atomica/arch-devel')
        devel.push()
    }
}
