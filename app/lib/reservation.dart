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

  // Future<void> fetchClasses() async {
  //   final String token = widget.userInfo['token']; // Assume token is stored in userInfo
  //   try {
  //     List<Map<String, dynamic>> fetchedClasses = await ClassesAPI.getClasses(token: token);
  //     setState(() {
  //       classes = fetchedClasses;
  //       isLoading = false;
  //     });
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //       errorMessage = 'Failed to load classes: $e';
  //     });
  //   }
  // }
  Future<void> fetchClasses() async {
    final String token = widget.userInfo['token']; // Assume token is stored in userInfo
    try {
      List<Map<String, dynamic>> fetchedClasses = await ClassesAPI.getClasses(token: token);

      // Sort classes: available classes first, and within available or unavailable, sort by time
      fetchedClasses.sort((a, b) {
        // First, sort by availability (true should come before false)
        int availabilityComparison = b['available'] ? 1 : 0 - (a['available'] ? 1 : 0);

        // If availability is the same, sort by time
        if (availabilityComparison == 0) {
          // Parsing time as DateTime for accurate comparison
          DateTime timeA = DateTime.parse('1970-01-01 ${a['time']}'); // Assuming time is in 'HH:mm' format
          DateTime timeB = DateTime.parse('1970-01-01 ${b['time']}'); // Assuming time is in 'HH:mm' format
          return timeA.compareTo(timeB);
        }

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
                      // Extract the image and other data
                      Uint8List? image = classData['decoded_image'];

                      return ReservationCard(
                        session: ReservationSession(
                          name: classData['name'],
                          time: classData['time'],
                          hasSpace: classData['available'],
                          image: image, // Pass image data to the card
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
    this.image, // Optional image data
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
            // Background Image
            session.image != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15), // Apply the border radius to the image as well
                    child: Container(
                      width: double.infinity,
                      height: 250, // Set a specific height for the image
                      child: Image.memory(
                        session.image!,
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover, // Ensure the image covers the card
                      ),
                    ),
                  )
                : Container(), // Placeholder for missing image

            // Text content under the image
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  // Row for the tags (name, time, availability)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      // Tag for the name
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
                      // Tag for the time
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
                      // Tag for availability
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
