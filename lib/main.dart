import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'pages/login_page.dart'; // Import the LoginPage

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: "AIzaSyAPaYSpRntgVXsx3DAOwtQHRtqYALM4LhY",
        appId: "1:1058070568082:web:24ea3837d9bfda74981a4b",
        messagingSenderId: "1058070568082",
        projectId: "mobileapplication1-9ccfe",
      ),
    );
  }
  await Firebase.initializeApp(); // Initialize Firebase for other platforms
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Attendance',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginPage(), // Set the LoginPage as the home page
    );
  }
}
