import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';

/// Slide 2: Features Screen
/// 
/// ILLUSTRATION NAME: "onboarding_features_illustration"
/// Description: An illustration showing multiple features like:
///              - A calendar/date picker
///              - Seat selection view
///              - Mobile payment
///              - Map with route
///              Should show key features of the app visually.
class OnboardingPageFeatures extends StatefulWidget {
  const OnboardingPageFeatures({super.key});

  @override
  State<OnboardingPageFeatures> createState() => _OnboardingPageFeaturesState();
}

class _OnboardingPageFeaturesState extends State<OnboardingPageFeatures>
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
                  'assets/illustrations/slide_2.png',
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
                'Book with Ease',
                style: quicksand(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white, // White text
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Features list - Modern vertical layout with icons
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    _buildFeatureItem(
                      PhosphorIcons.listMagnifyingGlass(),
                      'Search Buses',
                      'Find your perfect ride',
                    ),
                    const SizedBox(height: 18),
                    _buildFeatureItem(
                      PhosphorIcons.seat(),
                      'Select Seats',
                      'Choose your preferred seat',
                    ),
                    const SizedBox(height: 18),
                    _buildFeatureItem(
                      PhosphorIcons.creditCard(),
                      'Easy Payment',
                      'Quick and secure checkout',
                    ),
                  ],
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

  Widget _buildFeatureItem(PhosphorIconData icon, String title, String subtitle) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon with circular background
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: PhosphorIcon(
              icon,
              size: 22.0,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 14),
        // Text content
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: quicksand(
                  fontSize: 12,
                  color: Colors.white.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
