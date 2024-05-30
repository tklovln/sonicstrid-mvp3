import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:provider/provider.dart';

import './Mvp3LoginPage.dart';
import './Mvp3MusicPlayerPage.dart';
import '../utils.dart';
import '../pdTestPage.dart';
import '../endpoint/backend_api.dart' as backend_api;
import '../theme.dart';

class Mvp3CoverPage extends StatefulWidget {
  Mvp3CoverPage({super.key});
  final ThemeData theme = MoodSelectTheme.customTheme; // Custom theme for the app

  @override
  State<Mvp3CoverPage> createState() => _Mvp3CoverPageState();
}

class _Mvp3CoverPageState extends State<Mvp3CoverPage> {
  @override
  Widget build(BuildContext context) {
    // Applying the custom theme to the entire page
    return Theme(
      data: widget.theme,
      child: SafeArea( // Ensures the UI doesn't intrude into system areas
        child: Scaffold(
          body: Padding(
            padding: EdgeInsets.symmetric(horizontal: 32), // Consistent horizontal padding
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Centering content vertically
              crossAxisAlignment: CrossAxisAlignment.center, // Centering content horizontally
              children: [
                Container(
                  margin: EdgeInsets.symmetric(vertical: 16), // Spacing above and below the logo
                  child: Image.asset('assets/images/logo.png'), // App logo
                ),
                FractionallySizedBox(
                  alignment: Alignment.center, // Centering text
                  widthFactor: 0.7, // Text box takes up 70% of the screen width
                  child: Text(
                    "Welcome",
                    style: widget.theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center, // Centering text within the Text widget
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.center,
                  widthFactor: 0.7,
                  child: Text(
                    "We’re glad to see you here, Let's begin your sound journey now!",
                    style: widget.theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 32), // Spacing above and below the button
                  child: FilledButton.tonal(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.black,
                      backgroundColor: Colors.white,
                      side: const BorderSide(color: Colors.black, width: 1), // Border styling
                    ),
                    onPressed: () {
                      // Navigating to the login page when the button is pressed
                      Navigator.of(context).push(createRoute(page: Mvp3LoginPage()));
                    },
                    child: Text(
                      'Get started',
                      style: GoogleFonts.biryani(
                        fontSize: 13,
                        fontWeight: FontWeight.w300,
                        letterSpacing: 2.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}