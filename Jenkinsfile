pipeline {
  agent none
  stages {
    stage('Validation') {
      steps {
        powershell 'r'
      }
    }
    stage('ServiceNow') {
      steps {
        build '5'
      }
    }
  }
}