import 'package:flutter/material.dart';
import '../../utils/font_helper.dart';

/// Slide 1: Welcome/Introduction Screen
/// 
/// ILLUSTRATION NAME: "onboarding_welcome_illustration"
/// Description: A welcoming illustration showing people getting on a bus,
///              happy passengers, or a friendly bus traveling. Should convey
///              warmth and the beginning of a journey.
class OnboardingPageWelcome extends StatefulWidget {
  const OnboardingPageWelcome({super.key});

  @override
  State<OnboardingPageWelcome> createState() => _OnboardingPageWelcomeState();
}

class _OnboardingPageWelcomeState extends State<OnboardingPageWelcome>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFFF9500), // Orange background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            
            // Illustration image
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Image.asset(
                  'assets/illustrations/slide_one.png',
                  width: 220,
                  height: 220,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.image_not_supported,
                      size: 80,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),

            const SizedBox(height: 40),

            // Title - White text
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Text(
                  'Welcome to B-ON-B',
                  style: quicksand(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // White text
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Description - White text with opacity
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Text(
                    'Your journey begins here! Book bus tickets easily and travel comfortably across Cameroon.',
                    style: quicksand(
                      fontSize: 14,
                      color: Colors.white.withOpacity(0.9), // White text with slight opacity
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),

            const Spacer(flex: 3),
          ],
        ),
      ),
    );
  }
}
