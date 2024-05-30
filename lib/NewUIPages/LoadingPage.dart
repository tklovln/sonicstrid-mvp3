import 'package:flutter/material.dart';
import 'dart:async';
import 'package:animated_text_kit/animated_text_kit.dart';

import '../theme.dart';
import '../utils.dart';
import 'Mvp3MusicPlayerPage.dart';

class LoadingPage extends StatefulWidget {
  LoadingPage({super.key});
  final ThemeData theme = MoodSelectTheme.customTheme;

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  late Timer _timer; // Timer for the countdown
  int _secondsRemaining = 3; // Starting value for the countdown
  bool downCountingFlag = false; // Flag to indicate if countdown has started

  double _position = 0.0; // Initial position for the animation
  double _speed = 2.0; // Speed of the animation

  // Starts the bouncing animation of the image
  void _startAnimation() {
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        _position = 50; // Move the image down
      });
    });

    Future.delayed(Duration(milliseconds: 1000), () {
      setState(() {
        _position = 0.0; // Move the image back up
        _startAnimation(); // Restart the animation
      });
    });
  }

  // Starts the countdown animation
  void _startDownCountingAnimate() {
    downCountingFlag = true;
    const oneSecond = Duration(seconds: 1);
    _timer = Timer.periodic(oneSecond, (timer) {
      if (_secondsRemaining == 1) {
        // When countdown reaches 1, navigate to the next page
        Navigator.of(context)
            .push(createRoute(page: Mvp3MusicPlayerPage()))
            .then((_) => initState());
        timer.cancel();
      } else {
        setState(() {
          _secondsRemaining--; // Decrement the countdown
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _startAnimation(); // Start the animation when the widget is initialized
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  // Builds the text animation container
  Widget AnimationTextContainer() {
    if (downCountingFlag) {
      // If countdown has started, display the countdown number
      return Text("$_secondsRemaining", style: widget.theme.textTheme.titleLarge);
      // return AnimatedTextKit(
      //   animatedTexts: [
      //     FadeAnimatedText("$_secondsRemaining", duration: const Duration(milliseconds: 1000)),
      //   ],
      //   pause: const Duration(milliseconds: 0),
      //   );
    } else {
      // If countdown hasn't started, display the typewriter animation
      return AnimatedTextKit(
        repeatForever: true,
        // pause: const Duration(milliseconds: 1000),
        animatedTexts: [
          TypewriterAnimatedText('location accessing...', speed: const Duration(milliseconds: 160)),
          TypewriterAnimatedText('composing...', speed: const Duration(milliseconds: 160)),
        ],
        onTap: () {
          print("Tap Event");
          setState(() {
            _startDownCountingAnimate(); // Start the countdown on tap
          });
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: MyThemes.customTheme,
      child: CoverScaffoldWidget(childrens: _buildPage(context, _position))
    );
  }

  // Builds the main content of the page
  Widget _buildPage(BuildContext context, double position) {
    return Container(
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 1,
            child: Align(
              alignment: Alignment.bottomCenter,
              // Animated container for the bouncing image
              child: AnimatedContainer(
                duration: Duration(seconds: 1),
                margin: EdgeInsets.only(bottom: position),
                child: Image.asset('assets/images/location.png'),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              padding: const EdgeInsets.all(32),
              child: AnimationTextContainer(), // Container for the animated text
            ),
          ),
        ],
      ),
    );
  }
}
