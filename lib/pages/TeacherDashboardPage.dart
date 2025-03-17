import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart'; // Import QR code package
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class TeacherDashboardPage extends StatefulWidget {
  @override
  _TeacherDashboardPageState createState() => _TeacherDashboardPageState();
}

class _TeacherDashboardPageState extends State<TeacherDashboardPage> {
  String qrCodeData = "";
  bool isQRCodeGenerated = false; // Flag to check if QR code is generated

  // Generate and save the QR code
  void generateQRCode() {
    String teacherId = FirebaseAuth.instance.currentUser?.uid ??
        "default"; // Get current user's UID
    setState(() {
      qrCodeData = teacherId; // Using teacher's UID as QR code content
      isQRCodeGenerated = true; // Mark that QR code is generated
    });
  }

  // Fetch attendance data for the teacher
  Stream<QuerySnapshot> fetchAttendanceData() {
    String teacherId = FirebaseAuth.instance.currentUser?.uid ?? "default";
    return FirebaseFirestore.instance
        .collection('attendance')
        .where('teacherId', isEqualTo: teacherId)
        .snapshots();
  }

  // Handle logout and navigate to login page
  Future<void> logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.pop(context); // Navigate back to the Login Page
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Welcome To EduWise",
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 6, 27, 37),
          bottom: TabBar(
            labelColor: const Color.fromARGB(
                255, 142, 164, 184), // Color for selected tab text
            unselectedLabelColor: const Color.fromARGB(255, 248, 248, 248),
            tabs: [
              Tab(text: "My QR Code"),
              Tab(text: "Attendance"),
            ],
          ),
          actions: [
            IconButton(
              icon: Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: () async {
                await FirebaseAuth.instance.signOut();
                logout(context);
              },
            ),
          ],
        ),
        body: TabBarView(
          children: [
            // QR Code Tab
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isQRCodeGenerated)
                      Column(
                        children: [
                          Text('Scan this QR Code to mark attendance:'),
                          SizedBox(height: 20),
                          // Display the QR code using qr_flutter
                          QrImageView(
                            data: qrCodeData, // Data to encode into the QR code
                            version: QrVersions.auto,
                            size: 200.0, // Size of the QR code
                          ),
                        ],
                      )
                    else
                      ElevatedButton(
                        onPressed: generateQRCode,
                        child: Text(
                          "Generate My QR",
                          style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 255, 255, 255)),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF330135),
                          padding: EdgeInsets.symmetric(
                              horizontal: 70, vertical: 30),
                          textStyle: TextStyle(fontSize: 20),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Attendance Tab
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: StreamBuilder<QuerySnapshot>(
                stream: fetchAttendanceData(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError) {
                    return Center(child: Text('Something went wrong!'));
                  }

                  final data = snapshot.data?.docs ?? [];

                  return SingleChildScrollView(
                    child: DataTable(
                      columns: [
                        DataColumn(
                            label: Text('Email')), // Change 'Name' to 'Email'
                        DataColumn(
                            label: Text(
                                'Timestamp')), // Change 'Date' to 'Timestamp'
                      ],
                      rows: data.map((attendance) {
                        final studentEmail = attendance['studentEmail'];
                        final timestamp = attendance['attendanceDate'];

                        return DataRow(cells: [
                          DataCell(Text(studentEmail ?? '')),
                          DataCell(Text(timestamp ?? '')),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
