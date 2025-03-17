import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edu_wise/pages/TeacherDashboardPage.dart';
import 'package:flutter/material.dart';

class TeacherLoginPage extends StatefulWidget {
  const TeacherLoginPage({super.key});

  @override
  _TeacherLoginPageState createState() => _TeacherLoginPageState();
}

class _TeacherLoginPageState extends State<TeacherLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Login function with Firebase Authentication
  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Check if email and password are empty
    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both email and password.");
      return;
    }

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      // Attempt to sign in the user with the provided email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // If user is signed in, check the role in Firestore
      if (userCredential.user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;

        // Get the user document from Firestore
        DocumentSnapshot userDoc = await firestore
            .collection('users')
            .doc(userCredential.user?.uid)
            .get();

        if (userDoc.exists) {
          // Check if the user is a Teacher
          String userType = userDoc['userType'];
          if (userType == 'Teacher') {
            // Navigate to Teacher Dashboard if the user is a Teacher
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TeacherDashboardPage()),
            );
          } else {
            // If user is not a Teacher, show error
            _showErrorDialog("You are not authorized to access this page.");
          }
        } else {
          _showErrorDialog("User not found.");
        }
      }
    } catch (e) {
      // Handle any other errors (like invalid credentials)
      _showErrorDialog("An error occurred during login: ${e.toString()}");
    }
  }

  // Function to show error messages in a dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Login Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Login Here"),
        backgroundColor: Colors.red, // Red color for the app bar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Icon or Image (You can add an image here if you want)
            // Placeholder for teacher icon
            Icon(Icons.person, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            // Full width button by wrapping in SizedBox
            SizedBox(
              width: double.infinity, // This makes the button full width
              child: ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFFF9800), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
