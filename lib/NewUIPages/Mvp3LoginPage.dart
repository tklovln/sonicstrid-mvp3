import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import './MoodSelectPage.dart';
import '../utils.dart';
import '../endpoint/backend_api.dart' as backend_api;
import '../theme.dart';


import '../main.dart';
class Mvp3LoginPage extends StatefulWidget {
  Mvp3LoginPage({super.key});
  final ThemeData theme = MyThemes.customTheme; // Custom theme for the app

  @override
  State<Mvp3LoginPage> createState() => _Mvp3LoginPageState();
}

class _Mvp3LoginPageState extends State<Mvp3LoginPage> {
  // Text editing controllers for the email and password fields
  final TextEditingController tfEmailController = TextEditingController();
  final TextEditingController tfPasswordController = TextEditingController();
  late Counter counter; // Counter object from Provider

  // Function to handle user account access
  Future<int> accessAccount(String email) async {
    var userUUID = await backend_api.searchUserDetail(email);
    
    // If the user does not exist, create a new user
    if (userUUID == null) {
      await backend_api.createUser(email);
      userUUID = await backend_api.searchUserDetail(email) ?? 1;
    }
    counter.setUserId(userUUID); // Update the user ID in the counter

    return userUUID;
  }

  // Function to handle the login process
  Future<void> login() async {
    int userId = await accessAccount(tfEmailController.text);
    debugPrint('User id: $userId');

    // save username to global variable
    USERNAME = tfPasswordController.text;
  }

  @override
  void dispose() {
    // Dispose of the controllers when the widget is removed from the widget tree
    tfEmailController.dispose();
    tfPasswordController.dispose();
    super.dispose();
  }

  bool isCheck = false; // State for the checkbox
  final FocusNode textfocus1 = FocusNode(); // Focus node for the email field
  final FocusNode textfocus2 = FocusNode(); // Focus node for the password field

  @override
  Widget build(BuildContext context) {
    // Obtain the Counter object from the Provider
    counter = Provider.of<Counter>(context);

    // Apply the custom theme to the entire page
    return Theme(
      data: widget.theme,
      child: CoverScaffoldWidget(childrens: _buildPage(context)),
    );
  }

  // Function to build the page content
  Widget _buildPage(BuildContext context) {
    return SingleChildScrollView(
      child: ClipRect(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildHeader(),
            _buildTextField('Your email address', tfEmailController, textfocus1),
            _buildTextField('Your name', tfPasswordController, textfocus2),
            //_buildTermsAndConditions(),
            _buildSignUpButton(context),
          ],
        ),
      ),
    );
  }

  // Function to build the header section
  Widget _buildHeader() {
    Size screenSize = MediaQuery.of(context).size;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Create Account", style: widget.theme.textTheme.headlineLarge),
          Center(
            child: SizedBox(
              width: screenSize.width / 2,
              child: Text(
                "Go ahead and sign up, let us know how awesome you are!",
                textAlign: TextAlign.center,
                style: widget.theme.textTheme.headlineSmall,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build text fields for email and password
  Widget _buildTextField(String label, TextEditingController controller, FocusNode focusNode) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(4),
            child: Center(child: Text(label, style: widget.theme.textTheme.bodySmall)),
          ),
          Container(
            width: 245,
            height: 32,
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              style: const TextStyle(fontSize: 12),
              decoration: InputDecoration(
                isDense: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.white54, width: 1.5),
                  borderRadius: BorderRadius.circular(16.0),
                ),
                border: OutlineInputBorder(
                  borderSide: const BorderSide(color: Colors.black),
                  borderRadius: BorderRadius.circular(16.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Function to build the terms and conditions section
  Widget _buildTermsAndConditions() {
    return Container(
      margin: const EdgeInsets.all(32),
      child: Column(
        children: [
          const Text('Terms and condition'),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Checkbox(
                checkColor: Colors.grey.shade400,
                activeColor: Colors.grey.shade400,
                fillColor: MaterialStateProperty.all(Colors.grey.shade400),
                value: isCheck,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
                onChanged: (bool? value) {
                  setState(() {
                    isCheck = value!;
                  });
                },
              ),
              Text('I\'ve read......', style: TextStyle(color: Colors.grey.shade400)),
            ],
          ),
        ],
      ),
    );
  }

  // Function to build the sign-up button
  Widget _buildSignUpButton(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: FilledButton.tonal(
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.black,
          backgroundColor: Colors.white,
          side: const BorderSide(color: Colors.black, width: 1),
        ),
        // style: ButtonStyle(
        //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        //     RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(16),
        //     ),
        //   ),
        //   padding: MaterialStateProperty.all<EdgeInsets>(const EdgeInsets.all(20)),
        // ),
        onPressed: () {
          // Unfocus the text fields and initiate login when the button is pressed
          textfocus1.unfocus();
          textfocus2.unfocus();
          login();
          // Navigate to the MoodSelectPage after login
          Navigator.of(context).push(createRoute(page: MoodSelectPage()));
        },
        child: Text(
          'Sign up',
          style: GoogleFonts.biryani(
            fontSize: 13,
            fontWeight: FontWeight.w300,
            letterSpacing: 2.6,
          ),
        ),
      ),
    );
  }
}
