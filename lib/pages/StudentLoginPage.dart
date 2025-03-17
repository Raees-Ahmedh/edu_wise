import 'package:edu_wise/pages/StudentDashaboardPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';

class StudentLoginPage extends StatefulWidget {
  const StudentLoginPage({super.key});

  @override
  _StudentLoginPageState createState() => _StudentLoginPageState();
}

class _StudentLoginPageState extends State<StudentLoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  // Login function
  void _login() async {
    String email = emailController.text;
    String password = passwordController.text;

    // Firebase Authentication instance
    FirebaseAuth auth = FirebaseAuth.instance;

    try {
      // Authenticate the user using email and password
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is authenticated and get their UID
      if (userCredential.user != null) {
        String uid = userCredential.user!.uid;

        // Get the user data from Firestore
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentSnapshot userDoc =
            await firestore.collection('users').doc(uid).get();

        if (userDoc.exists) {
          // Check if the role is 'Student'
          String userRole = userDoc['userType'];

          if (userRole == 'Student') {
            // Navigate to the Student Dashboard if the role is 'Student'
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => StudentDashboardPage()),
            );
          } else {
            // Show an error message if the role is not 'Student'
            _showErrorDialog('You are not registered as a Student.');
          }
        } else {
          // If the user document does not exist in Firestore, show an error
          _showErrorDialog('No user found in Firestore.');
        }
      }
    } catch (e) {
      // Handle authentication errors (e.g., invalid email or password)
      String errorMessage = "An error occurred during login.";
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'user-not-found':
            errorMessage = 'No user found for that email.';
            break;
          case 'wrong-password':
            errorMessage = 'Incorrect password.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
      }
      // Show error message in a dialog
      _showErrorDialog(errorMessage);
    }
  }

  // Function to display error message in a dialog
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
            // Placeholder for student icon
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
                  backgroundColor: Color(0xFF9C27B0), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  "Login",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
