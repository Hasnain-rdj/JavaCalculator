pipeline {
    agent any
    
    environment {
        MAVEN_HOME = tool 'Maven'
        PATH = "${MAVEN_HOME}/bin:${PATH}"
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
                sh 'mvn clean package'
                echo 'Build completed successfully'
            }
        }
        
        stage('Unit Tests') {
            steps {
                echo '========== STAGE: Unit Tests =========='
                sh 'mvn test'
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
                script {
                    // Stop Tomcat
                    echo 'Stopping Tomcat...'
                    bat '''
                        @echo off
                        cd /d %TOMCAT_HOME%\\bin
                        call shutdown.bat
                        timeout /t 5 /nobreak
                    '''
                    
                    // Backup existing WAR and deploy new one
                    echo 'Deploying new WAR file...'
                    bat '''
                        @echo off
                        set TOMCAT_WEBAPPS=%TOMCAT_HOME%\\webapps
                        
                        REM Remove old WAR and extracted folder
                        if exist "%TOMCAT_WEBAPPS%\\%APP_NAME%.war" del "%TOMCAT_WEBAPPS%\\%APP_NAME%.war"
                        if exist "%TOMCAT_WEBAPPS%\\%APP_NAME%" rmdir /s /q "%TOMCAT_WEBAPPS%\\%APP_NAME%"
                        
                        REM Copy new WAR
                        copy "%WAR_FILE%" "%TOMCAT_WEBAPPS%\\%APP_NAME%.war"
                        
                        echo New WAR deployed successfully
                    '''
                    
                    // Start Tomcat
                    echo 'Starting Tomcat...'
                    bat '''
                        @echo off
                        cd /d %TOMCAT_HOME%\\bin
                        call startup.bat
                        timeout /t 10 /nobreak
                    '''
                    
                    echo 'Application deployed to Tomcat'
                }
            }
        }
        
        stage('Smoke Tests') {
            steps {
                echo '========== STAGE: Smoke Tests =========='
                script {
                    retry(3) {
                        sh '''
                            echo "Waiting for application to start..."
                            sleep 5
                            
                            echo "Testing application health..."
                            curl -f http://localhost:9090/${APP_NAME}/ || exit 1
                            
                            echo "Smoke tests passed"
                        '''
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
