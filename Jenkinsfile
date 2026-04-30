pipeline {
    agent any
    
    environment {
        MAVEN_HOME = tool 'Maven'
        TOMCAT_HOME = 'C:\\tomcat'  // Change this to your Tomcat location
        WAR_FILE = 'target/calculator.war'
        APP_NAME = 'calculator'
    }
    
    stages {
        stage('Checkout') {
            steps {
                echo '========== STAGE: Checkout =========='
                checkout scm
                echo 'Code checked out successfully'
            }
        }
        
        stage('Build') {
            steps {
                echo '========== STAGE: Build =========='
                bat '"%MAVEN_HOME%\\bin\\mvn.cmd" -V -B clean package'
                echo 'Build completed successfully'
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo '========== STAGE: Unit Tests =========='
                bat '"%MAVEN_HOME%\\bin\\mvn.cmd" -V -B test'
                echo 'Unit tests passed successfully'
            }
        }
        
        stage('SonarQube Analysis') {
            steps {
                echo '========== STAGE: SonarQube Analysis =========='
                echo 'SonarQube analysis (optional - configure if needed)'
                // Uncomment if SonarQube is configured
                // sh 'mvn sonar:sonar -Dsonar.host.url=http://localhost:9000'
            }
        }
        
        stage('Deploy to Tomcat') {
            steps {
                echo '========== STAGE: Deploy to Tomcat =========='
                bat 'powershell -NoProfile -ExecutionPolicy Bypass -File "scripts\\deploy-tomcat.ps1" -TomcatHome "%TOMCAT_HOME%" -WarPath "%WAR_FILE%" -AppName "%APP_NAME%"'
            }
        }
        
        stage('Smoke Tests') {
            steps {
                echo '========== STAGE: Smoke Tests =========='
                script {
                    retry(3) {
                        bat 'powershell -NoProfile -Command "Start-Sleep -Seconds 3; $r = Invoke-WebRequest -UseBasicParsing -Uri http://localhost:9090/%APP_NAME%/ -TimeoutSec 15; if ($r.StatusCode -lt 200 -or $r.StatusCode -ge 400) { exit 1 }"'
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo '========== Pipeline Completed =========='
            cleanWs()
        }
        
        success {
            echo '✓ Pipeline succeeded!'
            echo "Application deployed successfully at http://localhost:9090/calculator"
        }
        
        failure {
            echo '✗ Pipeline failed!'
            echo 'Check the logs above for details'
        }
        
        unstable {
            echo '⚠ Pipeline is unstable'
        }
    }
}
