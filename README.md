# 🕉️ Gita - Wisdom for Life

A modern Android application for learning the Bhagavad Gita with interactive lessons, quizzes, and gamification.

## ✨ Features

- **📚 Interactive Lessons**: Learn Bhagavad Gita teachings through structured chapters and lessons
- **❓ Quiz System**: Test your understanding with multiple-choice questions
- **🎯 Progress Tracking**: Track your learning journey with XP and achievements
- **🔥 Firebase Integration**: Cloud-based authentication, data storage, and real-time sync
- **🎨 Modern UI**: Built with Jetpack Compose & Material 3 design

## 🚀 Tech Stack

- **Language**: Kotlin 2.0.20
- **UI**: Jetpack Compose with Material 3
- **Architecture**: Clean Architecture (MVVM + Repository Pattern)
- **DI**: Hilt
- **Backend**: Firebase (Auth, Firestore, Storage)
- **Navigation**: Compose Navigation
- **Async**: Kotlin Coroutines & Flow

## 📱 Project Structure

```
app/src/main/java/com/schepor/gita/
├── data/              # Data layer (repositories, Firebase)
│   ├── repository/    # Repository implementations
│   └── seed/          # Mock data seeder
├── domain/            # Domain layer (models, use cases)
│   └── model/         # Domain models
├── presentation/      # Presentation layer (UI, ViewModels)
│   ├── admin/         # Admin panel (data seeding)
│   ├── auth/          # Login/Signup screens
│   ├── home/          # Home screen (chapter list)
│   ├── lesson/        # Lesson screen (quiz)
│   ├── navigation/    # Navigation setup
│   └── theme/         # UI theme & design system
├── di/                # Dependency injection modules
└── util/              # Utilities & constants
```

## 🔧 Setup Instructions

### Prerequisites

- Android Studio Ladybug or later
- JDK 17 or later
- Android SDK 26+ (Target: 35)
- Firebase project (see below)

### 1. Clone the Repository

```bash
git clone https://github.com/anshulchahar/gita.git
cd gita
```

### 2. Firebase Setup

1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com)
2. Add an Android app with package name: `com.schepor.gita`
3. Download `google-services.json` and place it in `app/` directory
4. Enable the following in Firebase Console:
   - **Authentication**: Email/Password + Google Sign-In
   - **Firestore Database**: Create in `nam5` region
   - **Storage**: Enable default bucket

### 3. Configure Google Sign-In

1. In Firebase Console → Authentication → Sign-in method → Enable Google
2. Get the Web OAuth client ID from Firebase
3. Add SHA-1 fingerprint to Firebase:

```bash
# Get debug SHA-1
./gradlew signingReport
# Copy SHA-1 and add to Firebase Console → Project Settings → Your apps
```

### 4. Deploy Firestore Rules & Indexes

```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login to Firebase
firebase login

# Deploy security rules and indexes
firebase deploy --only firestore:rules,firestore:indexes
```

### 5. Build & Run

```bash
# Open in Android Studio
# Wait for Gradle sync
# Click Run ▶️

# Or via command line:
./gradlew assembleDebug
```

## 🎮 How to Use

### First Time Setup

1. **Login**: Create account or sign in with Google
2. **Seed Data**: Tap "Wisdom Tree" title 5 times → Access admin panel
3. **Click "Seed Initial Content"**: This will create:
   - 3 Chapters (Arjuna Vishada, Sankhya, Karma Yoga)
   - 7 Lessons with questions
   - 13 Quiz questions with explanations

### Using the App

1. **Home Screen**: Browse available chapters
2. **Select Chapter**: Click to start the first lesson
3. **Answer Questions**: 
   - Read the question
   - Select an answer
   - Click "Submit Answer"
   - Use Previous/Next to navigate
4. **Complete Lesson**: View your score and retry if needed

## 📊 Progress

### Completed Features ✅

- ✅ Firebase Authentication (Email + Google Sign-In)
- ✅ Clean Architecture Setup
- ✅ Firestore Integration
- ✅ Chapter & Lesson Models
- ✅ Home Screen with Chapter List
- ✅ Lesson Screen with Quiz
- ✅ Question Navigation & Scoring
- ✅ Results Screen
- ✅ Admin Panel for Data Seeding
- ✅ Mock Data (3 chapters, 7 lessons, 13 questions)

### In Progress 🔨

- Progress Tracking (Save to Firestore)
- Lock/Unlock Logic (Progressive learning)
- Enhanced Answer Feedback (Explanations, animations)

### Planned 📋

- Daily Streaks
- Achievements System
- Leaderboard
- Wisdom Tree Visualization
- Offline Support

## 🔐 Firebase Security Rules

The app uses secure Firestore rules:

- **Chapters/Lessons/Questions**: Public read, authenticated write
- **User Data**: Users can only access their own data
- **Composite Indexes**: Required for efficient queries

Rules are defined in `firestore.rules` and deployed via Firebase CLI.

## 📚 Mock Data

The app includes comprehensive mock data from the Bhagavad Gita:

- **Chapter 1**: Arjuna Vishada Yoga (3 lessons, 6 questions)
- **Chapter 2**: Sankhya Yoga (2 lessons, 3 questions)  
- **Chapter 3**: Karma Yoga (2 lessons, 4 questions)

Each question includes:
- Authentic Gita teachings
- Modern real-life applications
- Explanations of correct answers

See `MOCK_DATA.md` for full details.

## 🐛 Troubleshooting

### Build Errors

```bash
# Clean and rebuild
./gradlew clean
./gradlew assembleDebug
```

### Google Sign-In Issues

1. Verify SHA-1 fingerprint is added to Firebase
2. Check Web OAuth client ID is correct
3. Ensure `google-services.json` is up to date

### Firestore Index Errors

The app will show an error with a link to create required indexes. Click the link or deploy via:

```bash
firebase deploy --only firestore:indexes
```

## 🤝 Contributing

This is a learning project. Feel free to:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is for educational purposes.

## 👨‍💻 Author

Developed by Anshul Chahar

---

**Last Updated**: October 8, 2025
