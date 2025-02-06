import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AttendanceHistoryScreen extends StatefulWidget {
  @override
  _AttendanceHistoryScreenState createState() => _AttendanceHistoryScreenState();
}

class _AttendanceHistoryScreenState extends State<AttendanceHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Attendance History")),
      body: FutureBuilder<QuerySnapshot>(
        future: FirebaseFirestore.instance.collection('attendance').orderBy('timestamp', descending: true).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No attendance records found."));
          }

          var attendanceData = snapshot.data!.docs;

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columns: [
                DataColumn(label: Text("Email")),
                DataColumn(label: Text("Course")),
                DataColumn(label: Text("Date & Time")),
              ],
              rows: attendanceData.map((doc) {
                var data = doc.data() as Map<String, dynamic>;
                return DataRow(cells: [
                  DataCell(Text(data['email'] ?? 'N/A')),
                  DataCell(Text(data['course'] ?? 'N/A')),
                  DataCell(Text(data['timestamp'] != null
                      ? (data['timestamp'] as Timestamp).toDate().toString()
                      : 'N/A')),
                ]);
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
