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
  List<Map<String, dynamic>> filteredClasses = [];
  bool isLoading = true;
  String errorMessage = '';
  String selectedDay = ''; // Selected day filter (e.g., "Monday")

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
        filteredClasses = fetchedClasses;
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

  void filterClassesByDay(String day) {
    setState(() {
      selectedDay = day;
      filteredClasses = day.isEmpty
          ? classes
          : classes.where((classData) => classData['day'].contains(day)).toList();
    });
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
              : Column(
                  children: [
                    _buildWeekdaySelector(),
                    Expanded(child: _buildClassList()),
                  ],
                ),
    );
  }

  Widget _buildWeekdaySelector() {
    const List<String> weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      color: Colors.grey[900],
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: weekdays.map((day) {
            bool isSelected = selectedDay == day;
            return GestureDetector(
              onTap: () => filterClassesByDay(isSelected ? '' : day),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 8.0),
                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.amber : Colors.grey[800],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white, width: 1),
                ),
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  // Widget _buildClassList() {
  //   return SingleChildScrollView(
  //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //     child: Column(
  //       crossAxisAlignment: CrossAxisAlignment.center,
  //       children: filteredClasses.map((classData) {
  //         Uint8List? image = classData['decoded_image'];
  //         String classId = classData['_id'];

  //         return GestureDetector(
  //           onTap: () => _showConfirmationDialog(context, classId),
  //           child: ReservationCard(
  //             session: ReservationSession(
  //               name: classData['name'],
  //               time: classData['time'],
  //               hasSpace: classData['available'],
  //               image: image,
  //             ),
  //           ),
  //         );
  //       }).toList(),
  //     ),
  //   );
  // }
  Widget _buildClassList() {
  return SingleChildScrollView(
    padding: const EdgeInsets.symmetric(horizontal: 16.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: filteredClasses.map((classData) {
        Uint8List? image = classData['decoded_image'];
        String classId = classData['_id'];
        String day = classData['day'][0];

        return ReservationCard(
          session: ReservationSession(
            name: classData['name'],
            time: classData['time'],
            hasSpace: classData['available'],
            image: image,
            day: day
          ),
        );
      }).toList(),
    ),
  );
}

}

class ReservationSession {
  final String name;
  final List<dynamic> time; // Changed to List<dynamic>
  final bool hasSpace;
  final Uint8List? image;
  final String day;

  ReservationSession({
    required this.name,
    required this.time,
    required this.hasSpace,
    this.image,
    required this.day
  });
}

class ReservationCard extends StatelessWidget {
  final ReservationSession session;

  ReservationCard({required this.session});

  @override
  Widget build(BuildContext context) {
    Color statusColor = session.hasSpace ? Colors.green : Colors.red;
    String statusText = session.hasSpace ? "Available" : "Full";

    // Convert List<dynamic> to a user-friendly string representation
    String formattedTime = session.time.map((e) => e.toString()).join(", ");

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
          crossAxisAlignment: CrossAxisAlignment.start, // Align content to the start
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.name,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Wrap(
                          spacing: 8.0, // Space between chips
                          runSpacing: 4.0, // Space between lines
                          children: [
                            _buildChip('Day: ${session.day}', Colors.deepPurple),
                            _buildChip('Time: $formattedTime', Colors.black),
                            _buildChip(statusText, statusColor),
                          ],
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

  Widget _buildChip(String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: TextStyle(color: Colors.white),
      ),
      backgroundColor: color.withOpacity(0.8),
    );
  }
}
