import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final String logoUrl = 'assets/logonn.jpeg'; // Path to logo
  final String phone = '+80911119'; // Replace with phone number
  final String instagramUrl = 'https://instagram.com/raedfidawi_'; // Instagram URL
  final String locationUrl = 'https://www.google.com/maps/search/?api=1&query=30.19,31.90'; // Location URL
  bool isSignIn = true; // Track whether to show sign-in or sign-up form

  @override
  Widget build(BuildContext context) {
    final double logoSize = MediaQuery.of(context).size.width * 0.3; // 30% of screen width

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 30),
              Container(
                width: logoSize,
                height: logoSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(logoUrl),
                    fit: BoxFit.cover,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Shiny Title
              Shimmer.fromColors(
                baseColor: Color(0xFFC7A00A), // Rich gold base
                highlightColor: Color(0xFFFFE066), // Bright gold highlight
                child: Text(
                  'JFIT STUDIO',
                  style: TextStyle(
                    fontSize: 30,
                    // fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.white,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Gold Gradient Info Card
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFB8860B), // Darker shade of gold
                      Color(0xFFFFD700), // True gold
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.25),
                      blurRadius: 10,
                      offset: Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.location_on,
                      text: 'Google Maps',
                      color: Color(0xffD4AF37), // Gold icon color
                      onTap: () => _launchURL(locationUrl),
                    ),
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.phone,
                      text: phone,
                      color: Color(0xffD4AF37),
                      onTap: () => _launchPhone(phone),
                    ),
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.camera_alt,
                      text: 'Instagram Page',
                      color: Color(0xffD4AF37),
                      onTap: () => _launchURL(instagramUrl),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildFormToggleButton("Sign In", true),
                  SizedBox(width: 20),
                  _buildFormToggleButton("Sign Up", false),
                ],
              ),
              SizedBox(height: 20),
              // Display form based on `isSignIn` state
              isSignIn ? _buildSignInForm() : _buildSignUpForm(),
              SizedBox(height: 30),
              Text(
                'By Harajli',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.6),
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }


Widget _buildFormToggleButton(String text, bool signIn) {
  return Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: () => setState(() => isSignIn = signIn),
      borderRadius: BorderRadius.circular(8),
      splashColor: Colors.white24, // Light splash effect when button is pressed
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFB8860B), // Darker shade of gold
              Color(0xFFFFD700), // True gold
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    ),
  );
}

  // Sign-In form
Widget _buildSignInForm() {
  return Column(
    children: [
      TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Color(0xffad9c00)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00), width: 2),
          ),
        ),
      ),
      SizedBox(height: 10),
      TextField(
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Color(0xffad9c00)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00), width: 2),
          ),
        ),
        obscureText: true,
      ),
      SizedBox(height: 20),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white24, // Light splash effect when button is pressed
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8860B), // Darker shade of gold
                  Color(0xFFFFD700), // True gold
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Sign In',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

// Sign-Up form
Widget _buildSignUpForm() {
  return Column(
    children: [
      TextField(
        decoration: InputDecoration(
          labelText: 'Name',
          labelStyle: TextStyle(color: Color(0xffad9c00)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00), width: 2),
          ),
        ),
      ),
      SizedBox(height: 10),
      TextField(
        decoration: InputDecoration(
          labelText: 'Email',
          labelStyle: TextStyle(color: Color(0xffad9c00)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00), width: 2),
          ),
        ),
      ),
      SizedBox(height: 10),
      TextField(
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Color(0xffad9c00)),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Color(0xffad9c00), width: 2),
          ),
        ),
        obscureText: true,
      ),
      SizedBox(height: 20),
      Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {},
          borderRadius: BorderRadius.circular(8),
          splashColor: Colors.white24, // Light splash effect when button is pressed
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Color(0xFFB8860B), // Darker shade of gold
                  Color(0xFFFFD700), // True gold
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

  Widget _buildInfoCard({required IconData icon, required String text, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.black.withOpacity(0.8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18.0, horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: color, size: 28),
              SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (!await launchUrlString(url)) {
      throw 'Could not launch $url';
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(launchUri)) {
      throw 'Could not launch $phone';
    }
  }
}
