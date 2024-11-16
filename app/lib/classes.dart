

import 'package:flutter/material.dart';
import 'classes_api.dart';
import 'dart:typed_data';

class Classes extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  Classes({required this.userInfo});

  @override
  _ClassesState createState() => _ClassesState();
}

class _ClassesState extends State<Classes> {
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchReservedClasses();
  }

  Future<void> fetchReservedClasses() async {
    final String token = widget.userInfo['token'];
    final String userId = widget.userInfo['user_id'];

    try {
      // Fetch user-specific reserved classes
      List<Map<String, dynamic>> fetchedClasses = await ClassesAPI.fetchUserClasses(
        token: token,
        userId: userId,
      );

      setState(() {
        classes = fetchedClasses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load reserved classes: $e';
      });
    }
  }

  Future<void> _confirmReservation(String classId) async {
    final userId = widget.userInfo['user_id'];

    try {
      final response = await ClassesAPI.removeClass(userId, classId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Reservation removed: ${response['message']}'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to remove reservation'))),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Reservation'),
          content: Text('Do you want to remove this reservation?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _confirmReservation(classId);
              },
              child: Text('Confirm'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Classes",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: classes.map((classData) {
                      Uint8List? image = classData['decoded_image'];
                      String classId = classData['_id'];  // Assuming classData contains an 'id' key

                      return GestureDetector(
                        onTap: () => _showConfirmationDialog(context, classId),
                        child: ReservationCard(
                          session: ReservationSession(
                            name: classData['name'],
                            time: classData['time'],
                            hasSpace: classData['available'],
                            image: image,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
    );
  }
}

class ReservationSession {
  final String name;
  final String time;
  final bool hasSpace;
  final Uint8List? image;

  ReservationSession({
    required this.name,
    required this.time,
    required this.hasSpace,
    this.image,
  });
}

class ReservationCard extends StatelessWidget {
  final ReservationSession session;

  ReservationCard({required this.session});

  @override
  Widget build(BuildContext context) {
    Color statusColor = session.hasSpace ? Colors.green : Colors.red;
    String statusText = session.hasSpace ? "Available" : "Full";
    return Container(
      margin: const EdgeInsets.only(bottom: 16.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFFB8860B),
            Color(0xFFFFD700),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Card(
        color: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Column(
          children: [
            session.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Container(
                      width: double.infinity,
                      height: 250,
                      child: Image.memory(
                        session.image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  )
                : Container(),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.name,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          session.time,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
