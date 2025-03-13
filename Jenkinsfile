node {
    
    stage('Clone repository') {
        checkout scm
    }

    stage('Semantic Release') {
        withCredentials([usernamePassword(credentialsId: 'github-pat', usernameVariable: 'GITHUB_USERNAME', passwordVariable: 'GITHUB_TOKEN')]) {
            script {
                echo "Running semantic-release"
                sh "npm ci"
                sh "npx semantic-release"
            }
        }    
    }
}