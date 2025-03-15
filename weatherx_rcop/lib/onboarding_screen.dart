import 'package:flutter/material.dart';
import 'package:intro_screen_onboarding_flutter/introduction.dart';
import 'package:intro_screen_onboarding_flutter/introscreenonboarding.dart';
import 'home_screen.dart';

class OnboardingScreen extends StatelessWidget {
  OnboardingScreen({super.key});

  final List<Introduction> list = [
    Introduction(
      title: 'Weather Forecast',
      subTitle:
          'Get accurate weather forecasts for any location with beautiful visualizations',
      imageUrl: 'assets/onboarding1.png',
    ),
    Introduction(
      title: 'Air Quality Monitoring',
      subTitle:
          'Track real-time air quality data and receive health recommendations',
      imageUrl: 'assets/onboarding2.png',
    ),
    Introduction(
      title: 'Interactive Maps',
      subTitle:
          'Explore weather patterns and air quality worldwide with interactive maps',
      imageUrl: 'assets/onboarding3.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return IntroScreenOnboarding(
      backgroudColor: const Color(0xFF1A1A2E),
      foregroundColor: const Color(0xFF87CEEB),
      introductionList: list,
      onTapSkipButton: () {
        // Use Navigator.pushReplacement to prevent going back to onboarding
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      },
      skipTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}
