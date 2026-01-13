import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'login_screen.dart';
import 'otp_verification_screen.dart';
import '../../utils/app_styles.dart';
import '../../utils/text_styles.dart';
import '../../utils/font_helper.dart';
import '../../services/api_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _isLoading = false;
  bool _agreeToTerms = false;
  bool _obscurePassword = true;
  CountryCode _selectedCountryCode = CountryCode(name: 'Cameroon', code: 'CM', dialCode: '+237');

  final Color _primaryColor = const Color(0xFFFF9500); // Main color FF9500

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      if (!_agreeToTerms) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Please agree to Terms & Conditions',
              style: quicksand(),
            ),
          ),
        );
        return;
      }

      setState(() {
        _isLoading = true;
      });

      try {
        final apiService = ApiService();
        // Clean phone number: remove spaces, hyphens, and any country code if entered
        String phoneNumber = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-]'), '');
        final countryCodeDigits = _selectedCountryCode.dialCode?.replaceAll('+', '') ?? '';
        // Remove country code if user entered it
        if (countryCodeDigits.isNotEmpty && phoneNumber.startsWith(countryCodeDigits)) {
          phoneNumber = phoneNumber.substring(countryCodeDigits.length);
        }
        
        await apiService.register(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: phoneNumber,
          password: _passwordController.text,
          countryCode: _selectedCountryCode.dialCode ?? '+237',
        );

        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          // Navigate to OTP verification screen
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              pageBuilder: (context, animation, secondaryAnimation) => OTPVerificationScreen(
                email: _emailController.text.trim(),
              ),
              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                return FadeTransition(
                  opacity: animation,
                  child: child,
                );
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                e.toString().replaceAll('Exception: ', ''),
                style: quicksand(),
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppStyles.space20),
                      // Title
                      Text(
                        'Join B-ON-B Today',
                        style: AppTextStyles.h2(),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: AppStyles.space16),
                      // Instructions
                      Text(
                        "Let's get started! Enter your details to create your B-ON-B account.",
                        style: AppTextStyles.bodySmall().copyWith(height: 1.5),
                        textAlign: TextAlign.left,
                      ),
                      const SizedBox(height: AppStyles.space32),
                      
                      // Name Field
                      TextFormField(
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        textCapitalization: TextCapitalization.words,
                        enableSuggestions: true,
                        autocorrect: true,
                        decoration: InputDecoration(
                          labelText: 'Full Name',
                          labelStyle: quicksand(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          prefixIcon: PhosphorIcon(
                            PhosphorIcons.user(),
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        style: quicksand(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          if (value.length < 2) {
                            return 'Name must be at least 2 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.space20),
                      
                      // Email Field
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        enableSuggestions: true,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Email',
                          labelStyle: quicksand(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          prefixIcon: PhosphorIcon(
                            PhosphorIcons.envelope(),
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        style: quicksand(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@') || !value.contains('.')) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.space20),
                      
                      // Phone Number Field with Country Code
                      Row(
                        children: [
                          // Country Code Picker
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade50,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: CountryCodePicker(
                              onChanged: (CountryCode code) {
                                setState(() {
                                  _selectedCountryCode = code;
                                });
                              },
                              initialSelection: 'PK',
                              favorite: const ['+92', 'PK'],
                              showCountryOnly: false,
                              showOnlyCountryWhenClosed: false,
                              alignLeft: false,
                              textStyle: quicksand(),
                              flagDecoration: const BoxDecoration(
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              dialogBackgroundColor: Colors.white,
                              barrierColor: Colors.black54,
                              showDropDownButton: true,
                              hideMainText: false,
                              boxDecoration: const BoxDecoration(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Phone Number Input
                          Expanded(
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              enableSuggestions: false,
                              autocorrect: false,
                              inputFormatters: [
                                // Prevent entering country code characters
                                FilteringTextInputFormatter.deny(RegExp(r'^\+')),
                                // Only allow digits, spaces, and hyphens
                                FilteringTextInputFormatter.allow(RegExp(r'[0-9\s\-]')),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Phone Number',
                                hintText: 'Enter number without country code',
                                labelStyle: quicksand(
                                  fontSize: 13,
                                  color: Colors.grey.shade600,
                                ),
                                hintStyle: quicksand(
                                  fontSize: 12,
                                  color: Colors.grey.shade400,
                                ),
                                prefixIcon: PhosphorIcon(
                                  PhosphorIcons.phone(),
                                  size: 20,
                                  color: Colors.grey.shade400,
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.shade300),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: const BorderSide(color: Colors.red, width: 2),
                                ),
                              ),
                              style: quicksand(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your phone number';
                                }
                                // Remove spaces and hyphens for validation
                                final cleanNumber = value.replaceAll(RegExp(r'[\s\-]'), '');
                                // Check if user tried to enter country code
                                final countryCodeDigits = _selectedCountryCode.dialCode?.replaceAll('+', '') ?? '';
                                if (countryCodeDigits.isNotEmpty && cleanNumber.startsWith(countryCodeDigits)) {
                                  return 'Country code already selected. Enter only your number';
                                }
                                // Check minimum length (at least 7 digits for most countries)
                                if (cleanNumber.length < 7) {
                                  return 'Please enter a valid phone number';
                                }
                                // Check maximum length (reasonable limit)
                                if (cleanNumber.length > 15) {
                                  return 'Phone number is too long';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppStyles.space20),
                      
                      // Password Field
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        enableSuggestions: false,
                        autocorrect: false,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: quicksand(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                          prefixIcon: PhosphorIcon(
                            PhosphorIcons.lock(),
                            size: 20,
                            color: Colors.grey.shade400,
                          ),
                          suffixIcon: IconButton(
                            icon: PhosphorIcon(
                              _obscurePassword ? PhosphorIcons.eyeSlash() : PhosphorIcons.eye(),
                              size: 20,
                              color: Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Color(0xFFFF9500), width: 2),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.red, width: 2),
                          ),
                        ),
                        style: quicksand(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: AppStyles.space24),
                      
                      // Terms & Conditions Checkbox
                      Row(
                        children: [
                          SizedBox(
                            width: 24,
                            height: 24,
                            child: Theme(
                              data: ThemeData(
                                checkboxTheme: CheckboxThemeData(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: _primaryColor,
                                    width: 2,
                                  ),
                                ),
                              ),
                              child: Checkbox(
                                value: _agreeToTerms,
                                onChanged: (value) {
                                  setState(() {
                                    _agreeToTerms = value ?? false;
                                  });
                                },
                                activeColor: _primaryColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: AppTextStyles.bodySmall(),
                                children: [
                                  const TextSpan(text: 'I agree with B-ON-B '),
                                  TextSpan(
                                    text: 'Terms & Conditions',
                                    style: AppTextStyles.link(),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Already have account link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: AppTextStyles.bodySmall(),
                          ),
                          GestureDetector(
                                  onTap: () {
                                    Navigator.pushReplacement(
                                      context,
                                      PageRouteBuilder(
                                        pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                          return FadeTransition(
                                            opacity: animation,
                                            child: child,
                                          );
                                        },
                                        transitionDuration: const Duration(milliseconds: 300),
                                      ),
                                    );
                                  },
                            child: Text(
                              'Sign in',
                              style: AppTextStyles.link(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Divider
                      Row(
                        children: [
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Text(
                              'or',
                              style: AppTextStyles.bodySmall(),
                            ),
                          ),
                          Expanded(child: Divider(color: Colors.grey.shade300)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Social Login Buttons - Black and White
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Facebook - Black circle with white 'f'
                          _SocialLoginButton(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Text(
                                  'f',
                                  style: quicksand(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                            onTap: () {
                              // TODO: Implement Facebook login
                            },
                          ),
                          const SizedBox(width: 16),
                          // Google - White circle with Google logo image and black border
                          _SocialLoginButton(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/images/google_logo.png',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    // Fallback to FontAwesome Google icon if image fails to load
                                    return const FaIcon(
                                      FontAwesomeIcons.google,
                                      color: Colors.black,
                                      size: 24,
                                    );
                                  },
                                ),
                              ),
                            ),
                            onTap: () {
                              // TODO: Implement Google login
                            },
                          ),
                          const SizedBox(width: 16),
                          // Apple - White circle with black Apple logo
                          _SocialLoginButton(
                            child: Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.black, width: 2),
                              ),
                              child: const Icon(
                                Icons.apple,
                                color: Colors.black,
                                size: 28,
                              ),
                            ),
                            onTap: () {
                              // TODO: Implement Apple login
                            },
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      
                      // Sign Up Button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _handleRegister,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : Text(
                                'Sign up',
                                style: quicksand(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Social Login Button Widget
class _SocialLoginButton extends StatelessWidget {
  final Widget child;
  final VoidCallback onTap;

  const _SocialLoginButton({
    required this.child,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: child,
    );
  }
}
