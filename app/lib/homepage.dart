// ignore_for_file: unused_import

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:url_launcher/url_launcher_string.dart';
import 'user_api.dart';
import 'reservation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'classes.dart'; 
import 'prices.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final storage = FlutterSecureStorage(); // Secure storage for token
  final String logoUrl = 'assets/logonn.jpeg';
  final String phone = '70777912';
  final String instagramUrl = 'https://instagram.com/jfit.stylee'; 
  // final String locationUrl = 'https://www.google.com/maps/search/?api=1&query=30.19,31.90';
  final String locationUrl = 'https://www.google.com/maps/place/FortyFour+Tower+-+Lebanon/@33.8805401,35.5395921,17z/data=!3m1!4b1!4m6!3m5!1s0x151f164a58a91ec7:0xe6b9b52817b42dc1!8m2!3d33.8805401!4d35.542167!16s%2Fg%2F11c1ngd4_3?entry=ttu&g_ep=EgoyMDI0MTEyNC4xIKXMDSoASAFQAw%3D%3D';

  bool isSignIn = true;
  bool _isSignedIn = false;

  final TextEditingController _signInUsernameController = TextEditingController();
  final TextEditingController _signInPasswordController = TextEditingController();


  final TextEditingController _signUpEmailController = TextEditingController();
  final TextEditingController _signUpUsernameController = TextEditingController();
  final TextEditingController _signUpPasswordController = TextEditingController();
  final TextEditingController _signUpNumberController = TextEditingController();

  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkToken();
    });
    _checkSignInStatus();
  }

  Future<void> _checkToken() async {
    String? token = await storage.read(key: 'userToken');
    if (token != null) {
      setState(() {
        _isSignedIn = true;
      });
    }
  }

  void _goToClasses() async {
    String? token = await storage.read(key: 'userToken');
    String? username = await storage.read(key: 'username');
    String? userId = await storage.read(key: 'user_id');

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Classes(userInfo: {'username': username, 'token': token, 'user_id': userId}),
        ),
      );
  }

  void _goToReservationPage() async{
    
    // sign out
    //   await storage.delete(key: 'userToken');
    //   await storage.delete(key: 'username');
    //   await storage.delete(key: 'user_id');
    //   setState(() {
    //    _isSignedIn = false;  // Default to false if no value is found
    // });
    // _saveSignInState(false);

    String? token = await storage.read(key: 'userToken');
    String? username = await storage.read(key: 'username');
    String? userId = await storage.read(key: 'user_id');
    // print(token);
    
    Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationPage(userInfo: {'username': username, 'token': token, 'user_id': userId}),
        ),
      );
  }

    void _goToPrices() async {
    String? token = await storage.read(key: 'userToken');
    String? username = await storage.read(key: 'username');
    String? userId = await storage.read(key: 'user_id');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Prices(userInfo: {'username': username, 'token': token, 'user_id': userId}),
      ),
    );
  }

  void _signOut() async{
      await storage.delete(key: 'userToken');
      await storage.delete(key: 'username');
      await storage.delete(key: 'user_id');
      setState(() {
       _isSignedIn = false;  // Default to false if no value is found
    });
    _saveSignInState(false);
  }

  void _saveSignInState(bool isSignedIn) {
  // Use SharedPreferences or another persistent storage method to save the user's sign-in state
  SharedPreferences.getInstance().then((prefs) {
    prefs.setBool('isSignedIn', isSignedIn);
  });
}

void _checkSignInStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool? isSignedIn = prefs.getBool('isSignedIn');
  
  setState(() {
    _isSignedIn = isSignedIn ?? false;  // Default to false if no value is found
  });
}

  Future<void> _handleSignIn() async {
  try {
    final response = await UserAPI.signIn(
      username: _signInUsernameController.text,
      password: _signInPasswordController.text,
    );

    if (response['token'] != null) {
      // Store the token, username, and user_id locally
      await storage.write(key: 'userToken', value: response['token']);
      await storage.write(key: 'username', value: _signInUsernameController.text);
      await storage.write(key: 'user_id', value: response['user_id'].toString());

      setState(() {
        _isSignedIn = true;
      });
      _saveSignInState(true);

      // Redirect to ReservationPage with user data

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Welcome ${_signInUsernameController.text}'))),
      );

    _signInUsernameController.clear();
    _signInPasswordController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationPage(userInfo: {
            'username': _signInUsernameController.text,
            'token': response['token'],
            'user_id': response['user_id']
          }),
        ),
      );
    }
  } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to Log in'))),
      );
    print(e);
  }
}

  // Method to handle Sign Up
Future<void> _handleSignUp() async {
  try {

    final response = await UserAPI.signUp(
      email: _signUpEmailController.text,
      username: _signUpUsernameController.text,
      password: _signUpPasswordController.text,
      number: _signUpNumberController.text,
    );

    // Assuming `response` includes a token and username
    if (response['token'] != null) {

      await storage.write(key: 'user_id', value: response['user_id'].toString());
      await storage.write(key: 'userToken', value: response['token']);
      await storage.write(key: 'username', value: _signUpUsernameController.text);

      setState(() {
        _isSignedIn = true;
      });
      _saveSignInState(true);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Welcome ${_signUpUsernameController.text}'))),
      );

    _signUpEmailController.clear();
    _signUpNumberController.clear();
    _signUpUsernameController.clear();
    _signUpPasswordController.clear();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ReservationPage(userInfo: {
            'username': _signUpUsernameController.text,
            'token': response['token'],
            'user_id': response['user_id']
          }),
        ),
      );
    }
  } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Center(child: Text('Failed to register'))),
      );
    print(e);
  }
}

Future<void> _deleteUser() async {
    try {
      String? userId = await storage.read(key: 'user_id');
      if (userId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No user ID found. Please sign in again.')),
        );
        return;
      }

      bool success = await UserAPI.deleteUser(userId);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('User deleted successfully.')),
        );

        // Optionally sign out and navigate back to login page
        _signOut();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error occurred: $e')),
      );
      print(e);
    }
  }

  @override
Widget build(BuildContext context) {
  final double logoSize = MediaQuery.of(context).size.width * 0.3;

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
                  // fontStyle: FontStyle.italic,
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
                    text: 'Sin El Fil, 11th Floor, Bloc A, Jfit studio 1118',
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
            // Conditional Rendering based on Sign-in Status
            if (_isSignedIn)
            Column(children: [
              Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToReservationPage,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'View Classes',
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
            Padding(padding: const EdgeInsets.all(3.0)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToClasses,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'View My Classes',
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
            Padding(padding: const EdgeInsets.all(3.0)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _goToPrices,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'View Prices',
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
            Padding(padding: const EdgeInsets.all(3.0)),
            Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _signOut,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Color.fromARGB(255, 184, 11, 11), Color.fromARGB(255, 255, 81, 0)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Text(
                      'Sign Out',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),
            )
            // ,
            // Padding(padding: const EdgeInsets.all(3.0)),
            // Material(
            //   color: Colors.transparent,
            //   child: InkWell(
            //     onTap: _deleteUser,
            //     child: Container(
            //       padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
            //       decoration: BoxDecoration(
            //         gradient: LinearGradient(
            //           colors: [Color.fromARGB(255, 184, 11, 11), Color.fromARGB(255, 255, 81, 0)],
            //           begin: Alignment.topLeft,
            //           end: Alignment.bottomRight,
            //         ),
            //         borderRadius: BorderRadius.circular(8),
            //       ),
            //       child: Center(
            //         child: Text(
            //           'Delete Account',
            //           style: TextStyle(
            //             color: Colors.white,
            //             fontWeight: FontWeight.bold,
            //             fontSize: 16,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // )
          ]
        )
            else
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.center,
              //   children: [
              //     _buildFormToggleButton("Sign In", true),
              //     // SizedBox(width: 20),
              //     // _buildFormToggleButton("Sign Up", false),
              //   ],
              // ),
            SizedBox(height: 20),
            // Display form based on `isSignIn` state
            // if (!_isSignedIn) (isSignIn ? _buildSignInForm() : _buildSignUpForm()),
            if(!_isSignedIn)
            _buildSignInForm(),
            SizedBox(height: 30),
            Text(
              'Jfit studio',
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
          controller: _signInUsernameController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Username',
            labelStyle: TextStyle(color: Color(0xffad9c00)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffad9c00)),
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _signInPasswordController,
          style: TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Password',
            labelStyle: TextStyle(color: Color(0xffad9c00)),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xffad9c00)),
            ),
          ),
          obscureText: true,
        ),
        SizedBox(height: 20),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _handleSignIn,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
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

  // Sign-Up form with logic
  // Widget _buildSignUpForm() {
  //   return Column(
  //     children: [
  //       TextField(
  //         controller: _signUpUsernameController,
  //         style: TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           labelText: 'Username',
  //           labelStyle: TextStyle(color: Color(0xffad9c00)),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Color(0xffad9c00)),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       TextField(
  //         controller: _signUpEmailController,
  //         style: TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           labelText: 'Email',
  //           labelStyle: TextStyle(color: Color(0xffad9c00)),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Color(0xffad9c00)),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 10),
  //       TextField(
  //         controller: _signUpPasswordController,
  //         style: TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           labelText: 'Password',
  //           labelStyle: TextStyle(color: Color(0xffad9c00)),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Color(0xffad9c00)),
  //           ),
  //         ),
  //         obscureText: true,
  //       ),
  //       SizedBox(height: 10),
  //       TextField(
  //         controller: _signUpNumberController,
  //         style: TextStyle(color: Colors.white),
  //         decoration: InputDecoration(
  //           labelText: 'Phone Number',
  //           labelStyle: TextStyle(color: Color(0xffad9c00)),
  //           enabledBorder: OutlineInputBorder(
  //             borderSide: BorderSide(color: Color(0xffad9c00)),
  //           ),
  //         ),
  //       ),
  //       SizedBox(height: 20),
  //       Material(
  //         color: Colors.transparent,
  //         child: InkWell(
  //           onTap: _handleSignUp,
  //           child: Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  //             decoration: BoxDecoration(
  //               gradient: LinearGradient(
  //                 colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
  //                 begin: Alignment.topLeft,
  //                 end: Alignment.bottomRight,
  //               ),
  //               borderRadius: BorderRadius.circular(8),
  //             ),
  //             child: Center(
  //               child: Text(
  //                 'Sign Up',
  //                 style: TextStyle(
  //                   color: Colors.white,
  //                   fontWeight: FontWeight.bold,
  //                   fontSize: 16,
  //                 ),
  //               ),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

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
    String url = 'tel://$phone'; //: 'tel:$phone';
    final Uri launchUri = Uri(scheme: 'tel', path: url);
    if (!await launchUrl(launchUri)) {
      throw 'Could not launch $phone';
    }
  }
}
