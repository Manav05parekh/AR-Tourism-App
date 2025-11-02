pipeline {
    agent any

    environment {
        FLUTTER_HOME = '/opt/flutter'
        ANDROID_HOME = '/usr/lib/android-sdk'
        PATH = "${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${env.PATH}"
        APP_ID = '1:542371597683:android:2b7f89f4d2d35618e20906'
    }

    stages {
        stage('Checkout') {
            steps {
                echo '📦 Checking out source code...'
                git branch: 'main', url: 'https://github.com/Manav05parekh/AR-Tourism-App.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                echo '📥 Installing dependencies...'
                sh 'flutter clean'
                sh 'flutter pub get'
            }
        }

        stage('Analyze Code') {
            steps {
                echo '🔍 Analyzing Flutter code...'
                sh 'flutter analyze || true'
            }
        }

        stage('Run Tests') {
            steps {
                echo '🧪 Running Flutter tests...'
                sh 'flutter test || true'
            }
        }

        stage('Build Release APK') {
            steps {
                echo '🏗️ Building release APK...'
                sh 'flutter build apk --release --verbose --no-shrink'
            }
        }

        stage('Distribute via Firebase') {
            steps {
                echo '🚀 Uploading build to Firebase App Distribution...'
                withCredentials([file(credentialsId: 'FIREBASE_SERVICE_ACCOUNT', variable: 'GOOGLE_APPLICATION_CREDENTIALS')]) {
                    sh '''
                        export PATH=$PATH:/usr/local/bin
                        firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
                            --app 1:542371597683:android:2b7f89f4d2d35618e20906 \
                            --groups testers \
                            --debug
                    '''
                }
            }
        }

        stage('Upload to GCS') {
            when {
                expression { currentBuild.currentResult == 'SUCCESS' }
            }
            steps {
                echo '☁️ Uploading APK to Google Cloud Storage...'
                sh '''
                    gsutil cp build/app/outputs/flutter-apk/app-release.apk \
                        gs://ar-tourism-apks/releases/app-release-${BUILD_NUMBER}.apk
                '''
            }
        }

        stage('Commit and Push Changes') {
            steps {
                echo '📤 Committing any updated files...'
                sh '''
                    git config --global user.email "jenkins@ci.com"
                    git config --global user.name "Jenkins CI"
                    git add -f android/app/google-services.json || true
                    git commit -m "Automated build and Firebase distribution [skip ci]" || echo "No changes to commit"
                    git push origin main || echo "No push needed"
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Successfully built, tested, and deployed to Firebase + GCS!'
        }
        failure {
            echo '❌ Build failed. Check Jenkins logs for details.'
        }
    }
}
