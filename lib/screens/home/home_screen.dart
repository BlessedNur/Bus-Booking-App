import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import 'widgets/bus_search_section.dart';
import '../bookings/my_bookings_screen.dart';
import '../profile/profile_screen.dart';
import '../agencies/agencies_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  late PageController _pageController;
  UserModel? _currentUser;
  bool _isLoadingUser = true;

  List<Widget> get _screens => [
    _HomeTabScreen(user: _currentUser),
    const _BookingsTabScreen(),
    const AgenciesScreen(),
    ProfileScreen(user: _currentUser),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _loadUserData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reload user data when screen becomes visible (e.g., after registration)
    if (!_isLoadingUser && _currentUser == null) {
      _loadUserData();
    }
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      final user = await apiService.getCurrentUser();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoadingUser = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingUser = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        physics: const BouncingScrollPhysics(), // Enable swiping
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFF9500), // Orange/Red navigation bar
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(PhosphorIcons.house(), 0),
                  _buildNavItem(PhosphorIcons.ticket(), 1),
                  _buildNavItem(PhosphorIcons.bus(), 2),
                  _buildNavItem(PhosphorIcons.userCircle(), 3),
                ],
              ),
          ),
        ),
      ),
    );
  }

  String _truncateEmail(String email) {
    if (email.length <= 20) return email;
    final parts = email.split('@');
    if (parts.length != 2) return email;
    final username = parts[0];
    final domain = parts[1];
    if (username.length <= 8) {
      return '$username@${domain.substring(0, domain.length > 8 ? 8 : domain.length)}...';
    }
    return '${username.substring(0, 8)}...@${domain.substring(0, domain.length > 8 ? 8 : domain.length)}...';
  }

  Widget _buildHeader() {
    return ClipRRect(
      
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
         
          child: Row(
            children: [
              // Logo on the left
              Image.asset(
                'assets/images/BONBLOGO.png',
                height: 50,
                errorBuilder: (context, error, stackTrace) {
                  return Text(
                    'B-ON-B',
                    style: quicksand(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White text on orange background
                    ),
                  );
                },
              ),
              const Spacer(),
              // Bell icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: PhosphorIcon(
                    PhosphorIcons.bell(),
                    size: 24.0,
                    color: Colors.white,
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 12),
              // Round profile with user info
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Profile avatar
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: _isLoadingUser
                          ? const SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF9500)),
                              ),
                            )
                          : Center(
                              child: Text(
                                _currentUser?.name.isNotEmpty == true 
                                    ? _currentUser!.name[0].toUpperCase() 
                                    : 'U',
                                style: quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFF9500),
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 8),
                    // User name and email
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isLoadingUser 
                              ? 'Loading...' 
                              : (_currentUser?.name ?? 'User'),
                          style: quicksand(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          _isLoadingUser 
                              ? '' 
                              : _truncateEmail(_currentUser?.email ?? ''),
                          style: quicksand(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      
    );
  }

  Widget _buildNavItem(PhosphorIconData iconData, int index) {
    final isActive = _currentIndex == index;
    return GestureDetector(
      onTap: () {
        if (_currentIndex != index) {
          // Animate to the selected page with smooth transition
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
          );
        }
      },
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.transparent,
          shape: BoxShape.circle, // Fully rounded
        ),
        child: Center(
          child: PhosphorIcon(
            iconData,
            size: 32.0,
            color: isActive ? const Color(0xFFFF9500) : Colors.white.withOpacity(0.8),
          ),
        ),
      ),
    );
  }
}

// Home Tab Screen
class _HomeTabScreen extends StatelessWidget {
  final UserModel? user;
  const _HomeTabScreen({this.user});

  @override
  Widget build(BuildContext context) {
    return BusSearchSection(user: user);
  }
}

// Bookings/Tickets Tab Screen
class _BookingsTabScreen extends StatelessWidget {
  const _BookingsTabScreen();

  @override
  Widget build(BuildContext context) {
    return const MyBookingsScreen();
  }
}

