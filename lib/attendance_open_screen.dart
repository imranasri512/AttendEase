import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'camera_screen.dart';

class AttendanceOpenScreen extends StatefulWidget {
  @override
  _AttendanceOpenScreenState createState() => _AttendanceOpenScreenState();
}

class _AttendanceOpenScreenState extends State<AttendanceOpenScreen> {
  String? userEmail;
  bool isAttendanceMarked = false;

  @override
  void initState() {
    super.initState();
    getUserEmail();
    checkIfAttendanceMarked();
  }

  /// **Fetch and Set Logged-in User's Email**
  void getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email ?? "Unknown User";
    });
  }

  /// **Check Firestore if attendance is already marked**
  Future<void> checkIfAttendanceMarked() async {
    if (userEmail == null) return;

    final query = await FirebaseFirestore.instance
        .collection('attendance')
        .where('email', isEqualTo: userEmail)
        .where('course', isEqualTo: 'INFO 4335')
        .get();

    setState(() {
      isAttendanceMarked = query.docs.isNotEmpty;
    });
  }

  /// **Mark Attendance After Face Recognition**
  Future<void> markAttendance() async {
    if (isAttendanceMarked) return;

    await FirebaseFirestore.instance.collection('attendance').add({
      'email': userEmail,
      'course': 'INFO 4335',
      'timestamp': FieldValue.serverTimestamp(),
    });

    setState(() {
      isAttendanceMarked = true;
    });

    print("✅ Attendance marked for $userEmail");
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Attendance Marked Successfully!")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // ✅ Use backgroundColor instead of primary
      appBar: AppBar(
        title: Text("Mark Attendance", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "INFO 4335: Mobile Application Development",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            SizedBox(height: 20),

            isAttendanceMarked
                ? Column(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 60),
                      Text(
                        "✅ Attendance Already Marked!",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ],
                  )
                : ElevatedButton(
                    onPressed: () async {
                      bool faceMatched = await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CameraScreen()),
                      );

                      if (faceMatched) {
                        await markAttendance();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    child: Text("Proceed to Face Recognition", style: TextStyle(color: Colors.white, fontSize: 18)),
                  ),

            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey,
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: Text("Back", style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
