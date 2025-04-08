// This is the script for the pipeline which consist of 4 stages pull , build , test , deploy
node{
    stage ('Pull'){
    echo 'This is the pull stage'
    git url: 'https://github.com/rajatpzade/studentapp.ui.git',branch: 'master'
    }

    stage ('Built'){
    echo 'The code is built'
    }

    stage ('Test'){
        echo 'This the test stage'
    }

    stage ('Deploy'){
        echo 'This is the Deploy stage'
    }
}