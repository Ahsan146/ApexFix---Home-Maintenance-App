import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/app_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isSignUp = false;

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSubmit() async {
    setState(() => _errorMessage = null);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    final emailRegex = RegExp(r'^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)+$');
    if (email.isEmpty || !emailRegex.hasMatch(email) || email.length > 100) {
      setState(() => _errorMessage = 'Please enter a valid email address (max 100 characters).');
      return;
    }
    if (password.length < 6 || password.length > 128) {
      setState(() => _errorMessage = 'Password must be between 6 and 128 characters.');
      return;
    }

    final app = context.read<AppProvider>();

    if (_isSignUp) {
      final name = _fullNameController.text.trim();
      final phone = _phoneController.text.trim();
      final confirmPass = _confirmPasswordController.text.trim();

      if (name.isEmpty || name.length > 80) {
        setState(() => _errorMessage = 'Please enter your full name (max 80 characters).');
        return;
      }
      final phoneRegex = RegExp(r'^\+?[0-9\s\-]{10,20}$');
      if (phone.isEmpty || !phoneRegex.hasMatch(phone)) {
        setState(() => _errorMessage = 'Please enter a valid phone number (e.g. +92 300 1234567).');
        return;
      }
      if (password != confirmPass) {
        setState(() => _errorMessage = 'Passwords do not match.');
        return;
      }

      await app.signUpWithEmail(
        fullName: name,
        email: email,
        phoneNumber: phone,
        password: password,
      );
    } else {
      await app.loginWithEmail(email, password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 5, 29, 67),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Logo
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: const Color(0xFF4F46E5),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.build_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 16),
                const Text(
                  'ApexFix',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: Color.fromARGB(255, 255, 255, 255), letterSpacing: -0.5),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Create your account to book verified home repair experts.'
                      : 'Sign in to manage and track verified home repair services.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color.fromARGB(255, 255, 255, 255)),
                ),
                const SizedBox(height: 24),

                // Segmented Toggle (Sign In / Sign Up)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isSignUp = false;
                            _errorMessage = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: !_isSignUp ? Colors.white : const Color.fromARGB(255, 5, 29, 67),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: !_isSignUp
                                  ? [const BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 1))]
                                  : null,
                            ),
                            child: Text(
                              'Sign In',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: !_isSignUp ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 250, 250, 250),
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _isSignUp = true;
                            _errorMessage = null;
                          }),
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            decoration: BoxDecoration(
                              color: _isSignUp ? Colors.white : const Color.fromARGB(255, 5, 29, 67),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _isSignUp
                                  ? [const BoxShadow(color: Colors.black, blurRadius: 4, offset: Offset(0, 1))]
                                  : null,
                            ),
                            child: Text(
                              'Sign Up',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _isSignUp ? const Color.fromARGB(255, 0, 0, 0) : const Color.fromARGB(255, 250, 250, 250),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Continue with Google
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                    backgroundColor: Colors.white,
                    side: const BorderSide(color: Color(0xFFCBD5E1)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: app.isLoading ? null : () => app.loginWithGoogle(),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 22,
                        height: 22,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4285F4),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        _isSignUp ? 'Sign up with Google' : 'Continue with Google',
                        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: Color(0xFF1E293B)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                Row(
                  children: [
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        _isSignUp ? 'OR ENTER DETAILS' : 'OR EMAIL',
                        style: const TextStyle(fontSize: 10, color: Color.fromARGB(255, 160, 169, 181), fontWeight: FontWeight.w700),
                      ),
                    ),
                    const Expanded(child: Divider(color: Color(0xFFE2E8F0))),
                  ],
                ),
                const SizedBox(height: 16),

                // Error Message banner
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFFECACA)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFEF4444), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFB91C1C), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Full Name (Sign Up only)
                if (_isSignUp) ...[
                  TextField(
                    controller: _fullNameController,
                    textCapitalization: TextCapitalization.words,
                    decoration: InputDecoration(
                      labelText: 'Full Name',
                      hintText: 'e.g. Ali Ahmed',
                      prefixIcon: const Icon(Icons.person_outline, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Phone Number (Sign Up only)
                  TextField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'Phone Number',
                      hintText: 'e.g. +92 300 1234567',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // Email Field
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'Email Address',
                    hintText: 'e.g. user@example.com',
                    prefixIcon: const Icon(Icons.email_outlined, size: 20),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                // Password Field
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'At least 6 characters',
                    prefixIcon: const Icon(Icons.lock_outline, size: 20),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility, size: 20),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                    ),
                  ),
                ),

                // Confirm Password (Sign Up only)
                if (_isSignUp) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      hintText: 'Re-enter your password',
                      prefixIcon: const Icon(Icons.lock_outline, size: 20),
                      suffixIcon: IconButton(
                        icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility, size: 20),
                        onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action Button
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 48),
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: app.isLoading ? null : _handleSubmit,
                  child: app.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : Text(
                          _isSignUp ? 'Create Account' : 'Sign In',
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                ),
                const SizedBox(height: 16),

                // Bottom Toggle Text
                GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text.rich(
                      TextSpan(
                        text: _isSignUp ? 'Already have an account? ' : "Don't have an account? ",
                        style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                        children: [
                          TextSpan(
                            text: _isSignUp ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(
                              color: Color(0xFF4F46E5),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Quick Demo Accounts Section (Debug Mode Only)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEEF2FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFC7D2FE)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: Color(0xFF4F46E5), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Quick Demo Accounts (Development Only):',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF3730A3),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 8,
                          runSpacing: 6,
                          children: [
                            ActionChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFF4F46E5),
                                child: Text('H', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Hamza Malik (DHA Lahore)', style: TextStyle(fontSize: 11)),
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _emailController.text = 'hamza.malik@gmail.com';
                                _passwordController.text = 'password123';
                                app.loginWithEmail('hamza.malik@gmail.com', 'password123');
                              },
                            ),
                            ActionChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFF047857),
                                child: Text('A', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Ayesha Khan (Gulberg)', style: TextStyle(fontSize: 11)),
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _emailController.text = 'ayesha.khan@gmail.com';
                                _passwordController.text = 'password123';
                                app.loginWithEmail('ayesha.khan@gmail.com', 'password123');
                              },
                            ),
                            ActionChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFFB45309),
                                child: Text('Z', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Zainab Tariq (Islamabad)', style: TextStyle(fontSize: 11)),
                              backgroundColor: Colors.white,
                              onPressed: () {
                                _emailController.text = 'zainab.tariq@gmail.com';
                                _passwordController.text = 'password123';
                                app.loginWithEmail('zainab.tariq@gmail.com', 'password123');
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

