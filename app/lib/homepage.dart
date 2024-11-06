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
  final int color = 0xFFD700;
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
              // Logo section with responsive size
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
                baseColor: Color(0xFFAD9C00), // Darker gold
                highlightColor: Color(0xFFFFD700), // Lighter gold
                child: Text(
                  'JFIT STUDIO',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w300, // Lighter weight for elegance
                    fontStyle: FontStyle.italic, // Makes the text italic
                    color: Colors.white, // Use white or transparent for shimmer effect
                    letterSpacing: 1.5, // Slightly increased spacing for a fancier look
                  ),
                ),
              ),
              SizedBox(height: 30),
              // Container for info cards with shiny gold background
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFFD4AF37), // Base gold color
                      Color(0xFFFFD700), // Highlight gold color
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildInfoCard(
                      icon: Icons.location_on,
                      text: 'Google Maps',
                      color: Color(0xffad9c00),
                      onTap: () => _launchURL(locationUrl),
                    ),
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.phone,
                      text: phone,
                      color: Color(0xffad9c00),
                      onTap: () => _launchPhone(phone),
                    ),
                    SizedBox(height: 15),
                    _buildInfoCard(
                      icon: Icons.camera_alt,
                      text: 'Instagram Page',
                      color: Color(0xffad9c00),
                      onTap: () => _launchURL(instagramUrl),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 30),
              // Toggle for Sign-In and Sign-Up forms
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
              // Footer or extra branding
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

  // Reusable link card
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

  // Form toggle button
  Widget _buildFormToggleButton(String text, bool signIn) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSignIn == signIn ? Color(0xffad9c00) : Colors.grey[700],
      ),
      onPressed: () => setState(() => isSignIn = signIn),
      child: Text(text, style: TextStyle(color: Colors.white)),
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
        ElevatedButton(
          onPressed: () {},
          child: Text('Sign In'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffad9c00),
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
        ElevatedButton(
          onPressed: () {},
          child: Text('Sign Up'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xffad9c00),
          ),
        ),
      ],
    );
  }

  // Function to launch URL
  Future<void> _launchURL(String url) async {
    if (!await launchUrlString(url)) {
      throw 'Could not launch $url';
    }
  }

  // Function to launch phone dialer
  Future<void> _launchPhone(String phone) async {
    final Uri launchUri = Uri(scheme: 'tel', path: phone);
    if (!await launchUrl(launchUri)) {
      throw 'Could not launch $phone';
    }
  }
}
