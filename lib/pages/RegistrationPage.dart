import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore
import 'package:flutter/material.dart';
import 'StudentDashaboardPage.dart'; // Import Student Dashboard page
import 'TeacherDashboardPage.dart'; // Import Teacher Dashboard page

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String selectedRole = 'Student';

  // Registration function with error handling
  void _register() async {
    String name = nameController.text;
    String email = emailController.text;
    String password = passwordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      _showErrorDialog("All fields are required.");
      return;
    }

    try {
      FirebaseAuth auth = FirebaseAuth.instance;
      UserCredential userCredential = await auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        await firestore.collection('users').doc(userCredential.user?.uid).set({
          'name': name,
          'email': email,
          'userType': selectedRole,
          'createdAt': FieldValue.serverTimestamp(),
        });
        if (selectedRole == 'Student') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => StudentDashboardPage()),
          );
        } else if (selectedRole == 'Teacher') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => TeacherDashboardPage()),
          );
        }
      }
    } catch (e) {
      String errorMessage = "An error occurred during registration.";

      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'weak-password':
            errorMessage = 'The password provided is too weak.';
            break;
          case 'email-already-in-use':
            errorMessage =
                'The email address is already in use by another account.';
            break;
          case 'invalid-email':
            errorMessage = 'The email address is invalid.';
            break;
          default:
            errorMessage = 'An error occurred: ${e.message}';
        }
      }

      _showErrorDialog(errorMessage);
    }
  }

  // Function to display error message in a dialog
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Registration Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
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
        title: Text("Register Here"),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(Icons.person_add, size: 100, color: Colors.grey),
            SizedBox(height: 20),

            // Name input field
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: "Name",
                prefixIcon: Icon(Icons.person),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Email input field
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),

            // Password input field
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

            // Role selection (Dropdown or Radio buttons)
            DropdownButton<String>(
              value: selectedRole,
              onChanged: (String? newValue) {
                setState(() {
                  selectedRole = newValue!;
                });
              },
              items: <String>['Student', 'Teacher']
                  .map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
            ),
            SizedBox(height: 20),

            // Register button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _register, // Call _register function on click
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50), // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                ),
                child: Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 19,
                    color: Color.fromARGB(255, 255, 255, 255),
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
