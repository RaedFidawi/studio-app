import 'package:flutter/material.dart';

class ReservationPage extends StatelessWidget {

  final Map<String, dynamic> userInfo;
  ReservationPage({required this.userInfo});
  
  final List<ReservationSession> sessions = [
    ReservationSession(name: "Yoga", time: "9:00 AM", hasSpace: true),
    ReservationSession(name: "Pilates", time: "10:30 AM", hasSpace: false),
    ReservationSession(name: "Zumba", time: "12:00 PM", hasSpace: true),
    ReservationSession(name: "Boxing", time: "2:00 PM", hasSpace: false),
    ReservationSession(name: "Boxing", time: "2:00 PM", hasSpace: false),
    ReservationSession(name: "Boxing", time: "2:00 PM", hasSpace: false),
    ReservationSession(name: "Boxing", time: "2:00 PM", hasSpace: false),
    ReservationSession(name: "Boxing", time: "2:00 PM", hasSpace: false),
  ];

  @override
  Widget build(BuildContext context) {
    print(userInfo['username']);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          "Reservation List",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: sessions.map((session) {
            return ReservationCard(session: session);
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

  ReservationSession({
    required this.name,
    required this.time,
    required this.hasSpace,
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(
                Icons.fitness_center,
                color: Color(0xffD4AF37), // Gold icon color
                size: 28,
              ),
              SizedBox(width: 10),
              Column(
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
                  SizedBox(height: 5),
                  Text(
                    session.time,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: statusColor,
                        size: 20,
                      ),
                      SizedBox(width: 5),
                      Text(
                        statusText,
                        style: TextStyle(
                          fontSize: 16,
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
