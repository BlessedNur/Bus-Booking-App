import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';
import '../../models/user_model.dart';
import '../auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final UserModel? user;
  const ProfileScreen({super.key, this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Notification settings
  bool _pushNotifications = true;
  bool _emailNotifications = true;
  bool _smsNotifications = false;
  bool _bookingReminders = true;
  bool _promotionalUpdates = false;
  
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentUser = widget.user;
    if (_currentUser == null) {
      _loadUserData();
    } else {
      _isLoading = false;
    }
  }

  Future<void> _loadUserData() async {
    try {
      final apiService = ApiService();
      final user = await apiService.getUserProfile();
      if (mounted) {
        setState(() {
          _currentUser = user;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // User data from API
    final String userName = _currentUser?.name ?? 'User';
    final String userEmail = _currentUser?.email ?? '';
    final String userPhone = _currentUser?.phone ?? '';

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'My Account',
          style: quicksand(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Profile Header Card
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  // Profile Avatar
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF9500),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        userName.split(' ').map((n) => n[0]).take(2).join(),
                        style: quicksand(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: quicksand(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.envelope(),
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                userEmail,
                                style: quicksand(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            PhosphorIcon(
                              PhosphorIcons.phone(),
                              size: 16,
                              color: Colors.grey.shade600,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              userPhone,
                              style: quicksand(
                                fontSize: 14,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Edit Button
                  IconButton(
                    onPressed: () {
                      // TODO: Navigate to edit profile screen
                    },
                    icon: PhosphorIcon(
                      PhosphorIcons.pencilSimple(),
                      size: 24,
                      color: const Color(0xFFFF9500),
                    ),
                  ),
                ],
              ),
            ),

            // Payment Methods Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.creditCard(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Payment Methods',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Mobile Money
                  _buildPaymentMethodItem(
                    'Mobile Money',
                    '•••• •••• 1234',
                    PhosphorIcons.deviceMobile(),
                    Colors.green,
                    true,
                  ),
                  const SizedBox(height: 12),
                  // Orange Money
                  _buildPaymentMethodItem(
                    'Orange Money',
                    '•••• •••• 5678',
                    PhosphorIcons.deviceMobile(),
                    Colors.orange,
                    false,
                  ),
                  const SizedBox(height: 12),
                  // Add Payment Method Button
                  OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to add payment method screen
                    },
                    icon: PhosphorIcon(
                      PhosphorIcons.plus(),
                      size: 18,
                      color: const Color(0xFFFF9500),
                    ),
                    label: Text(
                      'Add Payment Method',
                      style: quicksand(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFF9500),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF9500), width: 1.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Notifications Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.bell(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Notifications',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildNotificationSwitch(
                    'Push Notifications',
                    'Receive push notifications on your device',
                    _pushNotifications,
                    (value) {
                      setState(() {
                        _pushNotifications = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  _buildNotificationSwitch(
                    'Email Notifications',
                    'Receive booking updates via email',
                    _emailNotifications,
                    (value) {
                      setState(() {
                        _emailNotifications = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  _buildNotificationSwitch(
                    'Booking Reminders',
                    'Get reminded before your trips',
                    _bookingReminders,
                    (value) {
                      setState(() {
                        _bookingReminders = value;
                      });
                    },
                  ),
                  const Divider(height: 32),
                  _buildNotificationSwitch(
                    'Promotional Updates',
                    'Receive offers and promotional content',
                    _promotionalUpdates,
                    (value) {
                      setState(() {
                        _promotionalUpdates = value;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Preferences & Settings Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.gear(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Preferences',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildPreferenceItem(
                    'Language',
                    'English',
                    PhosphorIcons.translate(),
                    () {
                      // TODO: Navigate to language selection
                    },
                  ),
                  const Divider(height: 32),
                  _buildPreferenceItem(
                    'Currency',
                    'FCFA',
                    PhosphorIcons.currencyCircleDollar(),
                    () {
                      // TODO: Navigate to currency selection
                    },
                  ),
                  const Divider(height: 32),
                  _buildPreferenceItem(
                    'Saved Addresses',
                    null,
                    PhosphorIcons.mapPin(),
                    () {
                      // TODO: Navigate to saved addresses
                    },
                  ),
                  const Divider(height: 32),
                  _buildPreferenceItem(
                    'Change Password',
                    null,
                    PhosphorIcons.lock(),
                    () {
                      // TODO: Navigate to change password
                    },
                  ),
                  const Divider(height: 32),
                  _buildPreferenceItem(
                    'Privacy & Security',
                    null,
                    PhosphorIcons.shield(),
                    () {
                      // TODO: Navigate to privacy settings
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Help & Support Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.question(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Help & Support',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSupportItem(
                    'Help Center',
                    PhosphorIcons.chatCircle(),
                    () {
                      // TODO: Navigate to help center
                    },
                  ),
                  const Divider(height: 32),
                  _buildSupportItem(
                    'Contact Us',
                    PhosphorIcons.phone(),
                    () {
                      // TODO: Navigate to contact us
                    },
                  ),
                  const Divider(height: 32),
                  _buildSupportItem(
                    'FAQs',
                    PhosphorIcons.info(),
                    () {
                      // TODO: Navigate to FAQs
                    },
                  ),
                  const Divider(height: 32),
                  _buildSupportItem(
                    'Terms & Conditions',
                    PhosphorIcons.fileText(),
                    () {
                      // TODO: Navigate to terms
                    },
                  ),
                  const Divider(height: 32),
                  _buildSupportItem(
                    'Privacy Policy',
                    PhosphorIcons.shield(),
                    () {
                      // TODO: Navigate to privacy policy
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // About Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PhosphorIcon(
                        PhosphorIcons.info(),
                        size: 20,
                        color: const Color(0xFFFF9500),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'About',
                        style: quicksand(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildAboutItem('App Version', '1.0.0'),
                  const Divider(height: 32),
                  _buildAboutItem('Build Number', '2024.01.15'),
                  const Divider(height: 32),
                  _buildSupportItem(
                    'Rate Us',
                    PhosphorIcons.star(),
                    () {
                      // TODO: Navigate to app store rating
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Logout Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: OutlinedButton.icon(
                  onPressed: () {
                    _showLogoutDialog(context);
                  },
                  icon: PhosphorIcon(
                    PhosphorIcons.signOut(),
                    size: 20,
                    color: Colors.red,
                  ),
                  label: Text(
                    'Logout',
                    style: quicksand(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red, width: 1.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodItem(
    String title,
    String number,
    IconData icon,
    Color color,
    bool isDefault,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDefault ? color.withOpacity(0.1) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDefault ? color : Colors.grey.shade300,
          width: isDefault ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDefault ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: PhosphorIcon(
              icon,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: quicksand(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (isDefault) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Default',
                          style: quicksand(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  number,
                  style: quicksand(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              // TODO: Edit or remove payment method
            },
            icon: PhosphorIcon(
              PhosphorIcons.dotsThreeVertical(),
              size: 20,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSwitch(
    String title,
    String subtitle,
    bool value,
    ValueChanged<bool> onChanged,
  ) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: quicksand(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: const Color(0xFFFF9500),
        ),
      ],
    );
  }

  Widget _buildPreferenceItem(
    String title,
    String? value,
    IconData icon,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: PhosphorIcon(
                icon,
                size: 20,
                color: const Color(0xFFFF9500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            if (value != null) ...[
              Text(
                value,
                style: quicksand(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(width: 8),
            ],
            PhosphorIcon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSupportItem(String title, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9500).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: PhosphorIcon(
                icon,
                size: 20,
                color: const Color(0xFFFF9500),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: quicksand(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            PhosphorIcon(
              PhosphorIcons.caretRight(),
              size: 20,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: quicksand(
                fontSize: 15,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            value,
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'Logout',
            style: quicksand(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          content: Text(
            'Are you sure you want to logout?',
            style: quicksand(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to login screen and clear navigation stack
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LoginScreen(),
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Logout',
                style: quicksand(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
