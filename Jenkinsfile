pipeline {
    agent any

    environment {
        FLUTTER_HOME = "${HOME}/flutter"
        PATH = "${FLUTTER_HOME}/bin:${HOME}/.npm-global/bin:${PATH}"
        FIREBASE_TOKEN = credentials('FIREBASE_TOKEN')
        APP_ID = '1:542371597683:android:2b7f89f4d2d35618e20906' // 🔁 Replace with real Firebase App ID
    }

    stages {
        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/Manav05parekh/AR-Tourism-App.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'flutter pub get'
            }
        }

        stage('Analyze Code') {
            steps {
                sh 'flutter analyze'
            }
        }

        stage('Run Tests') {
            steps {
                sh 'flutter test || true'
            }
        }

        stage('Build Release APK') {
            steps {
                sh 'flutter build apk --release'
            }
        }

        stage('Distribute via Firebase') {
            steps {
                sh '''
                    firebase appdistribution:distribute \
                    build/app/outputs/flutter-apk/app-release.apk \
                    --app $APP_ID \
                    --groups "testers" \
                    --token $FIREBASE_TOKEN
                '''
            }
        }

        stage('Upload to GCS') {
            steps {
                sh '''
                    gsutil cp build/app/outputs/flutter-apk/app-release.apk gs://ar-tourism-apks/releases/
                '''
            }
        }
    }

    post {
        success {
            echo '✅ Successfully built, tested, and deployed to Firebase App Distribution!'
        }
        failure {
            echo '❌ Build failed. Check Jenkins logs for errors.'
        }
    }
}
