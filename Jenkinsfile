pipeline {
  agent any
  tools {
    nodejs 'node'
  }
  environment {
    GITHUB_CREDENTIALS = credentials('GITHUB_CREDENTIALS') 
  }
  stages {
    
    stage('Clone repository') {
      steps {
        cleanWs()
        checkout scm
      }
    }
    stage('Validate Conventional Commits') {
      steps {
        sh '''
        echo "Validate commit messages"

        npm i -D @semantic-release/commit-analyzer 
        npx semantic-release --dry-run
        '''
      }
    }
    stage('Validate Terraform') {
      when {
        not {
          branch 'main'
        }
      }
      steps {
        script {
          sh 'terraform --version'
          sh 'terraform init'
          // Check Terraform formatting
          def fmtResult = sh(script: 'terraform fmt -check -diff', returnStatus: true)
          if (fmtResult != 0) {
            error "Terraform files are not formatted correctly"
          }
          sh 'terraform validate'
        }
      }
    }
  }
  post {
    always {
      cleanWs()
    }
    success {
      echo 'Pipeline completed successfully!'
    }
    failure {
      echo 'Pipeline failed!'
    }
  }
}
