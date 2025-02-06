import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'attendance_open_screen.dart';
import 'register_face_screen.dart';
import 'attendance_history_screen.dart'; // ✅ Import the new screen

class DashboardScreen extends StatefulWidget {
  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  String? userEmail;

  @override
  void initState() {
    super.initState();
    getUserEmail();
  }

  void getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email ?? "Unknown User";
    });
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Dashboard"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Logged in as: $userEmail",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey),
            ),
            SizedBox(height: 20),

            Text("Courses", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RegisterFaceScreen())),
              child: Text("Register Face"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceOpenScreen())),
              child: Text("INFO 4335: Mobile Application Development"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AttendanceHistoryScreen())),
              child: Text("View Attendance History"),
            ),
          ],
        ),
      ),
    );
  }
}
