// import 'package:flutter/material.dart';
// import 'classes_api.dart'; // Import the new ClassesAPI class

// class ReservationPage extends StatefulWidget {
//   final Map<String, dynamic> userInfo;

//   ReservationPage({required this.userInfo});

//   @override
//   _ReservationPageState createState() => _ReservationPageState();
// }

// class _ReservationPageState extends State<ReservationPage> {
//   List<Map<String, dynamic>> classes = [];
//   bool isLoading = true;
//   String errorMessage = '';

//   @override
//   void initState() {
//     super.initState();
//     fetchClasses();
//   }

//   Future<void> fetchClasses() async {
//     final String token = widget.userInfo['token']; // Assume token is stored in userInfo
//     try {
//       List<Map<String, dynamic>> fetchedClasses = await ClassesAPI.getClasses(token: token);
//       setState(() {
//         classes = fetchedClasses;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//         errorMessage = 'Failed to load classes: $e';
//       });
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.black,
//       appBar: AppBar(
//         title: Text(
//           "Reservation List",
//           style: TextStyle(
//             fontSize: 24,
//             fontWeight: FontWeight.bold,
//             color: Colors.white,
//           ),
//         ),
//         backgroundColor: Colors.black,
//       ),
//       body: isLoading
//           ? Center(child: CircularProgressIndicator())
//           : errorMessage.isNotEmpty
//               ? Center(child: Text(errorMessage, style: TextStyle(color: Colors.red)))
//               : SingleChildScrollView(
//                   padding: const EdgeInsets.symmetric(horizontal: 16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.center,
//                     children: classes.map((classData) {
//                       return ReservationCard(
//                         session: ReservationSession(
//                           name: classData['name'],
//                           time: classData['time'],
//                           hasSpace: classData['available'],
//                         ),
//                       );
//                     }).toList(),
//                   ),
//                 ),
//     );
//   }
// }

// class ReservationSession {
//   final String name;
//   final String time;
//   final bool hasSpace;

//   ReservationSession({
//     required this.name,
//     required this.time,
//     required this.hasSpace,
//   });
// }

// class ReservationCard extends StatelessWidget {
//   final ReservationSession session;

//   ReservationCard({required this.session});

//   @override
//   Widget build(BuildContext context) {
//     Color statusColor = session.hasSpace ? Colors.green : Colors.red;
//     String statusText = session.hasSpace ? "Available" : "Full";

//     return Container(
//       margin: const EdgeInsets.only(bottom: 16.0),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           colors: [
//             Color(0xFFB8860B),
//             Color(0xFFFFD700),
//           ],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.3),
//             blurRadius: 10,
//             spreadRadius: 1,
//           ),
//         ],
//       ),
//       child: Card(
//         color: Colors.black.withOpacity(0.8),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
//         elevation: 3,
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Row(
//             children: [
//               Icon(
//                 Icons.fitness_center,
//                 color: Color(0xffD4AF37), // Gold icon color
//                 size: 28,
//               ),
//               SizedBox(width: 10),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     session.name,
//                     style: TextStyle(
//                       fontSize: 18,
//                       color: Colors.white,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     session.time,
//                     style: TextStyle(
//                       fontSize: 16,
//                       color: Colors.white.withOpacity(0.7),
//                     ),
//                   ),
//                   SizedBox(height: 10),
//                   Row(
//                     children: [
//                       Icon(
//                         Icons.check_circle,
//                         color: statusColor,
//                         size: 20,
//                       ),
//                       SizedBox(width: 5),
//                       Text(
//                         statusText,
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: statusColor,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// ############################################# NEW #########################################################
import 'package:flutter/material.dart';
import 'classes_api.dart'; // Import the new ClassesAPI class
import 'dart:typed_data';  // For handling the decoded image bytes

class ReservationPage extends StatefulWidget {
  final Map<String, dynamic> userInfo;

  ReservationPage({required this.userInfo});

  @override
  _ReservationPageState createState() => _ReservationPageState();
}

class _ReservationPageState extends State<ReservationPage> {
  List<Map<String, dynamic>> classes = [];
  bool isLoading = true;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchClasses();
  }

  Future<void> fetchClasses() async {
    final String token = widget.userInfo['token'];
    try {
      List<Map<String, dynamic>> fetchedClasses = await ClassesAPI.getClasses(token: token);
      fetchedClasses.sort((a, b) {
        int availabilityComparison = (b['available'] ? 1 : 0) - (a['available'] ? 1 : 0);
        return availabilityComparison;
      });

      setState(() {
        classes = fetchedClasses;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Failed to load classes: $e';
      });
    }
  }

  Future<void> _confirmReservation(String classId) async {
    final userId = widget.userInfo['user_id'];

    try {
      final response = await ClassesAPI.reserveClass(userId: userId, classId: classId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Reservation confirmed: ${response['message']}'))),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to reserve class'))),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context, String classId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Reservation'),
          content: Text('Do you want to confirm this reservation?'),
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
