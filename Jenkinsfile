#!groovy

node {
    checkout scm

    dir('docker') {
        stage 'Prepare'
        sh 'sudo /bin/sh ./00-prepare.sh'

        stage 'Build arch-base'
        sh 'sudo /bin/sh ./10-build-arch-base.sh'

        stage 'Build arch-devel'
        sh 'sudo /bin/sh ./20-build-arch-devel.sh'
    }
}
