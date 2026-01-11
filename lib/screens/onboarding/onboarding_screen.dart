import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login_screen.dart';
import '../../utils/font_helper.dart';
import 'onboarding_page_welcome.dart';
import 'onboarding_page_features.dart';
import 'onboarding_page_get_started.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // List of onboarding pages
  final List<Widget> _pages = [
    const OnboardingPageWelcome(),      // Slide 1: Welcome illustration
    const OnboardingPageFeatures(),     // Slide 2: Features illustration
    const OnboardingPageGetStarted(),   // Slide 3: Get Started illustration
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    if (mounted) {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            // Fade and slide transition
            const begin = Offset(0.0, 1.0);
            const end = Offset.zero;
            const curve = Curves.easeInOutCubic;

            var tween = Tween(begin: begin, end: end).chain(
              CurveTween(curve: curve),
            );

            return FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: animation.drive(tween),
                child: child,
              ),
            );
          },
          transitionDuration: const Duration(milliseconds: 600),
        ),
      );
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFF9500), // Orange/Yellow background
      body: SafeArea(
        child: Stack(
          children: [
            // PageView with onboarding pages - Swipeable enabled
            PageView.builder(
              controller: _pageController,
              onPageChanged: _onPageChanged,
              itemCount: _pages.length,
              itemBuilder: (context, index) => _pages[index],
              physics: const BouncingScrollPhysics(), // Smooth swipe with bounce effect
              allowImplicitScrolling: false,
            ),

            // B-ON-B Logo (top left)
            Positioned(
              top: 16,
              left: 16,
              child: Image.asset(
                'assets/images/BONBLOGO.png',
                width: 70,
                height: 50,
                fit: BoxFit.contain,
              ),
            ),

            // Skip button (top right)
            if (_currentPage < _pages.length - 1)
              Positioned(
                top: 16,
                right: 16,
                child: TextButton(
                  onPressed: _skipOnboarding,
                  child: Text(
                    'Skip',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.white, // White text on orange background
                    ),
                  ),
                ),
              ),

            // Page indicators (bottom center)
            Positioned(
              bottom: _currentPage == _pages.length - 1 ? 120 : 60,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  _pages.length,
                  (index) => _buildPageIndicator(index == _currentPage),
                ),
              ),
            ),

            // Get Started Button (only on last page, below dots)
            if (_currentPage == _pages.length - 1)
              Positioned(
                bottom: 40,
                left: 24,
                right: 24,
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      _completeOnboarding();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white, // White button
                      foregroundColor: const Color(0xFFFF9500), // Orange text on white button
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Get Started',
                      style: quicksand(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFFFF9500), // Orange text on white button
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicator(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 24 : 8,
              decoration: BoxDecoration(
                color: isActive ? Colors.white : Colors.white.withOpacity(0.5), // White dots on orange background
                borderRadius: BorderRadius.circular(4),
              ),
    );
  }
}
