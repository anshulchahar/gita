# 🕉️ Gita - Wisdom for Life (Flutter)

A modern cross-platform application for learning the Bhagavad Gita with interactive lessons, quizzes, and gamification, built with Flutter.

## ✨ Features

- **📚 Interactive Lessons**: Learn Bhagavad Gita teachings through structured chapters and lessons
- **❓ Quiz System**: Test your understanding with multiple-choice questions
- **🎯 Progress Tracking**: Track your learning journey with XP, streaks, and gems
- **🕉️ Krishna Mascot**: Interactive AI companion providing feedback and motivation
- **🔥 Firebase Integration**: Cloud-based authentication, data storage, and real-time sync
- **🎨 Modern UI**: Built with Material 3 design for Android and iOS
- **🚀 Guest Mode**: Explore content without signing in immediately

## 📱 Project Structure

```
gita_flutter/lib/
├── app/               # App configuration & routing
├── core/              # Constants, theme, utils
├── data/              # Data layer (repositories, Firebase)
├── domain/            # Domain models
├── presentation/      # UI screens and components
│   ├── admin/         # Admin panel (content seeding)
│   ├── auth/          # Login/Signup
│   ├── home/          # Home screen (progression tree)
│   ├── lesson/        # Lesson quiz interface
│   └── components/    # Shared widgets (Mascot, Nodes)
└── main.dart          # Entry point
```

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK (latest stable)
- Android Studio / Xcode
- Firebase project (`gita-58861`)

### 1. Run the App

```bash
cd gita_flutter
flutter pub get
flutter run
```

### 2. Firebase Configuration

- **Android**: `google-services.json` is already in `android/app/`.
- **iOS**: Add `GoogleService-Info.plist` to `ios/Runner/`.
- **Web**: configured via `firebase_options.dart`.

### 3. Content Seeding (If Database is Empty)

If you see "No chapters available" on the home screen:
1. Tap on the text **"Tap here to refresh"** exactly **5 times**.
2. This opens the **Admin Panel**.
3. Click **"Seed Content"**.
4. Go back to see the populated lessons.

## 📊 Features Status

- ✅ Cross-platform (Android/iOS)
- ✅ Firebase Authentication (Email + Google + Guest)
- ✅ Firestore Integration (Client-side sorting implemented)
- ✅ Duolingo-style Progression
- ✅ Animated Mascot
- ✅ Admin Seeding Tool

## 👨‍💻 Author

Developed by Anshul Chahar
