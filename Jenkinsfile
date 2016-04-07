#!groovy

node {
    // checkout scm

    // dir('docker') {
    //     stage 'Build Images'
    //     sh 'sudo /bin/sh ./build.sh'
    // }

    // stage 'Push to hub.docker.com'
    // docker.withRegistry('https://index.docker.io/v1/', 'docker-jasonrm') {
    //     stage 'Push arch-base'
    //     def base = docker.image('atomica/arch-base')
    //     base.push()

    //     stage 'Push arch-devel'
    //     def devel = docker.image('atomica/arch-devel')
    //     devel.push()
    // }

    docker.withRegistry('https://docker.artfire.me/', 'docker-artfire') {
        stage 'Push docker.artfire.me/atomica/arch-base'
        def base = docker.image('atomica/arch-base')
        base.push()

        stage 'Push docker.artfire.me/atomica/arch-devel'
        def devel = docker.image('atomica/arch-devel')
        devel.push()
    }
}
