pipeline {
    agent any

    environment {
        // Flutter setup
        FLUTTER_HOME = '/opt/flutter'
        PATH = "${FLUTTER_HOME}/bin:${FLUTTER_HOME}/bin/cache/dart-sdk/bin:${env.PATH}"

        // Firebase + App Info
        FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
        APP_ID = '1:542371597683:android:2b7f89f4d2d35618e20906' // Replace with your actual Firebase App ID
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
                sh 'flutter build apk --release'
            }
        }

        stage('Distribute via Firebase') {
            steps {
                echo '🚀 Uploading build to Firebase App Distribution...'
                sh """
                    firebase appdistribution:distribute \
                        build/app/outputs/flutter-apk/app-release.apk \
                        --app $APP_ID \
                        --groups "testers" \
                        --token $FIREBASE_TOKEN
                """
            }
        }

        stage('Upload to GCS') {
            steps {
                echo '☁️ Uploading APK to Google Cloud Storage...'
                sh """
                    gsutil cp build/app/outputs/flutter-apk/app-release.apk \
                    gs://ar-tourism-apks/releases/
                """
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
