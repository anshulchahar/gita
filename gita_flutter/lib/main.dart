import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'firebase_options.dart';
// import 'data/seed/content_seeder.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'app/app.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await dotenv.load(fileName: ".env");

  // Initialize Firebase with options
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    // App Check removed as we are using Google Generative AI with API Key directly.
    /*
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug,
      appleProvider: AppleProvider.debug,
    ); 
    */ 
  } catch (e) {
    // App already initialized or AppCheck failed, ignore
    debugPrint("Firebase initialization error: $e");
  }

  /* 
  // Content Seeder REMOVED - Using server-side seeding via scripts/populate_db.py
  // This prevents overwriting valid data with hardcoded legacy data.
  */

  runApp(
    const ProviderScope(
      child: GitaApp(),
    ),
  );
}
