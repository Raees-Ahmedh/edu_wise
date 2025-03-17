import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Import the mobile_scanner package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class StudentDashboardPage extends StatelessWidget {
  const StudentDashboardPage({super.key});

  // Function to navigate to QR scanning page
  void navigateToQRCodeScanner(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            QRCodeScannerPage(), // Navigate to the QR scanner page
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Smart Attendance'),
        backgroundColor: Color(0xFF9C27B0), // AppBar color
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              // Log out and navigate back to the Login Page
              await FirebaseAuth.instance.signOut();
              Navigator.pop(
                  context); // This will pop the current screen and go back to the LoginPage
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // Hello Student Section
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Color(0xFF9C27B0), // Button color for "Hello Student"
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                "Hello Student",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 30), // Spacer between sections

            // Scan QR Code Button
            SizedBox(
              width: double.infinity, // Full width
              child: ElevatedButton(
                onPressed: () {
                  navigateToQRCodeScanner(
                      context); // Navigate to QR Code Scanner screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange, // Button color
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  textStyle: TextStyle(fontSize: 18),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8), // Rounded corners
                  ),
                ),
                child: Text(
                  "Scan QR Code",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QR Code Scanner Page
class QRCodeScannerPage extends StatefulWidget {
  @override
  _QRCodeScannerPageState createState() => _QRCodeScannerPageState();
}

class _QRCodeScannerPageState extends State<QRCodeScannerPage> {
  String scannedQRCode = ""; // To store the scanned QR data
  bool isAttendanceMarked =
      false; // Flag to track if attendance has been marked

  // Callback when QR code is scanned
  void _onQRScanned(Barcode scanData) {
    if (isAttendanceMarked) {
      // If attendance is already marked, do nothing
      return;
    }

    setState(() {
      scannedQRCode = scanData.rawValue ?? ''; // Save the scanned QR data
    });

    // Logic to mark attendance here
    markAttendance(scannedQRCode);
  }

  // Function to mark attendance
  void markAttendance(String teacherId) async {
    User? user = FirebaseAuth.instance.currentUser;
    String studentEmail = user?.email ??
        'student@example.com'; // Get student's email from FirebaseAuth
    String attendanceDate = DateTime.now().toString();

    // Save attendance to Firestore
    FirebaseFirestore.instance.collection('attendance').add({
      'studentEmail': studentEmail,
      'teacherId': teacherId,
      'attendanceDate': attendanceDate,
    }).then((value) {
      setState(() {
        isAttendanceMarked =
            true; // Set flag to true after successful attendance marking
      });

      // Show success message and pop the scanner page
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Attendance marked successfully!')));
      Navigator.pop(context); // Close the QR Code Scanner page
    }).catchError((error) {
      // Handle error if attendance marking fails
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Failed to mark attendance. Please try again.')));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Scan QR Code"),
      ),
      body: Center(
        child: MobileScanner(
          onDetect: (BarcodeCapture barcodeCapture) {
            final barcode = barcodeCapture.barcodes.first;
            if (barcode.rawValue != null) {
              _onQRScanned(barcode); // Handle scanned QR code
            }
          },
        ),
      ),
    );
  }
}
