import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:provider/provider.dart';
import '../providers/technician_provider.dart';

class TechnicianLoginScreen extends StatefulWidget {
  const TechnicianLoginScreen({super.key});

  @override
  State<TechnicianLoginScreen> createState() => _TechnicianLoginScreenState();
}

class _TechnicianLoginScreenState extends State<TechnicianLoginScreen> {
  bool _isSignUp = false;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _bioController = TextEditingController();

  final List<String> _availableSpecialties = [
    'AC & Cooling',
    'Electrical',
    'Plumbing',
    'Appliances',
    'Carpentry',
    'Solar & Inverters',
  ];
  final Set<String> _selectedSpecialties = {'AC & Cooling'};

  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _vehicleController.dispose();
    _bioController.dispose();
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

    final provider = context.read<TechnicianProvider>();

    if (_isSignUp) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();

      if (name.isEmpty || name.length > 80) {
        setState(() => _errorMessage = 'Please enter your full name (max 80 characters).');
        return;
      }
      final phoneRegex = RegExp(r'^\+?[0-9\s\-]{10,20}$');
      if (phone.isEmpty || !phoneRegex.hasMatch(phone)) {
        setState(() => _errorMessage = 'Please enter a valid contact phone (e.g. +92 300 1234567).');
        return;
      }
      if (_selectedSpecialties.isEmpty) {
        setState(() => _errorMessage = 'Please select at least one trade skill.');
        return;
      }

      await provider.register(
        fullName: name,
        email: email,
        phoneNumber: phone,
        specialties: _selectedSpecialties.toList(),
        vehicleInfo: _vehicleController.text.trim().isNotEmpty
            ? _vehicleController.text.trim()
            : 'Motorcycle with Toolbox',
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : 'Certified service technician ready for dispatch.',
      );
    } else {
      await provider.login(email: email, password: password);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<TechnicianProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Pro Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: const Color(0xFF10B981)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.verified, size: 14, color: Color(0xFF10B981)),
                      SizedBox(width: 6),
                      Text(
                        'PARTNER & SPECIALIST APP',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Pro Logo Icon
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.handyman_rounded, color: Colors.white, size: 30),
                ),
                const SizedBox(height: 14),

                const Text(
                  'ApexFix Pro',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _isSignUp
                      ? 'Apply to join our network of certified home service technicians.'
                      : 'Sign in to access your dispatch radar, jobs, and daily payouts.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Color(0xFF94A3B8)),
                ),
                const SizedBox(height: 24),

                // Mode Selector
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
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
                              color: !_isSignUp ? const Color(0xFF2563EB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Partner Login',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: !_isSignUp ? Colors.white : const Color(0xFF94A3B8),
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
                              color: _isSignUp ? const Color(0xFF2563EB) : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              'Join as Pro',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: _isSignUp ? Colors.white : const Color(0xFF94A3B8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 14),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7F1D1D).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: const Color(0xFFEF4444)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Color(0xFFFCA5A5), size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(fontSize: 12, color: Color(0xFFFCA5A5), fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Form Container
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF334155)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (_isSignUp) ...[
                        const Text(
                          'Partner Details',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _nameController,
                          style: const TextStyle(color: Colors.white),
                          textCapitalization: TextCapitalization.words,
                          decoration: InputDecoration(
                            labelText: 'Full Name',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            hintText: 'e.g. Usman Tariq',
                            hintStyle: const TextStyle(color: Color(0xFF64748B)),
                            prefixIcon: const Icon(Icons.person_outline, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _phoneController,
                          style: const TextStyle(color: Colors.white),
                          keyboardType: TextInputType.phone,
                          decoration: InputDecoration(
                            labelText: 'Phone Number',
                            labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                            hintText: 'e.g. +92 321 1234567',
                            hintStyle: const TextStyle(color: Color(0xFF64748B)),
                            prefixIcon: const Icon(Icons.phone_outlined, color: Color(0xFF94A3B8)),
                            filled: true,
                            fillColor: const Color(0xFF0F172A),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: const BorderSide(color: Color(0xFF334155)),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        const Text(
                          'Primary Trade Specialties',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
                        ),
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: _availableSpecialties.map((spec) {
                            final isSel = _selectedSpecialties.contains(spec);
                            return FilterChip(
                              label: Text(spec),
                              selected: isSel,
                              selectedColor: const Color(0xFF2563EB),
                              backgroundColor: const Color(0xFF0F172A),
                              labelStyle: TextStyle(
                                color: isSel ? Colors.white : const Color(0xFF94A3B8),
                                fontSize: 11,
                                fontWeight: isSel ? FontWeight.w700 : FontWeight.w500,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                                side: BorderSide(
                                  color: isSel ? const Color(0xFF2563EB) : const Color(0xFF334155),
                                ),
                              ),
                              onSelected: (val) {
                                setState(() {
                                  if (val) {
                                    _selectedSpecialties.add(spec);
                                  } else {
                                    if (_selectedSpecialties.length > 1) {
                                      _selectedSpecialties.remove(spec);
                                    }
                                  }
                                });
                              },
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 14),
                      ],

                      // Email Field
                      TextField(
                        controller: _emailController,
                        style: const TextStyle(color: Colors.white),
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          labelText: 'Email Address / Pro ID',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          hintText: 'e.g. pro@apexfix.pk',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.email_outlined, color: Color(0xFF94A3B8)),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Password Field
                      TextField(
                        controller: _passwordController,
                        style: const TextStyle(color: Colors.white),
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          labelStyle: const TextStyle(color: Color(0xFF94A3B8)),
                          hintText: 'At least 6 characters',
                          hintStyle: const TextStyle(color: Color(0xFF64748B)),
                          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF94A3B8)),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off : Icons.visibility,
                              color: const Color(0xFF94A3B8),
                              size: 20,
                            ),
                            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                          ),
                          filled: true,
                          fillColor: const Color(0xFF0F172A),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                            borderSide: const BorderSide(color: Color(0xFF334155)),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Submit Button
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2563EB),
                          foregroundColor: Colors.white,
                          minimumSize: const Size(double.infinity, 48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: provider.isLoading ? null : _handleSubmit,
                        child: provider.isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : Text(
                                _isSignUp ? 'Submit Partner Application' : 'Enter Partner Dashboard',
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                              ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Switch text
                GestureDetector(
                  onTap: () => setState(() {
                    _isSignUp = !_isSignUp;
                    _errorMessage = null;
                  }),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      _isSignUp ? 'Already an approved partner? Sign In' : 'Want to earn as a specialist? Apply Now',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF60A5FA), fontWeight: FontWeight.w600),
                    ),
                  ),
                ),

                // Quick Demo Partner Accounts Section (Debug Mode Only)
                if (kDebugMode) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.bolt, color: Color(0xFF38BDF8), size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Quick Demo Partner Accounts (Development Only):',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF94A3B8),
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
                                backgroundColor: Color(0xFF2563EB),
                                child: Text('T', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Tariq Mahmood (HVAC)', style: TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFF334155)),
                              onPressed: () {
                                _emailController.text = 'tariq.hvac@apexfix.pk';
                                _passwordController.text = 'password123';
                                provider.login(email: 'tariq.hvac@apexfix.pk', password: 'password123');
                              },
                            ),
                            ActionChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFFD97706),
                                child: Text('K', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Kamran Ali (Electric & Solar)', style: TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFF334155)),
                              onPressed: () {
                                _emailController.text = 'kamran.electric@apexfix.pk';
                                _passwordController.text = 'password123';
                                provider.login(email: 'kamran.electric@apexfix.pk', password: 'password123');
                              },
                            ),
                            ActionChip(
                              avatar: const CircleAvatar(
                                backgroundColor: Color(0xFF059669),
                                child: Text('Z', style: TextStyle(color: Colors.white, fontSize: 10)),
                              ),
                              label: const Text('Zubair Ahmed (Plumbing)', style: TextStyle(fontSize: 11, color: Colors.white)),
                              backgroundColor: const Color(0xFF0F172A),
                              side: const BorderSide(color: Color(0xFF334155)),
                              onPressed: () {
                                _emailController.text = 'zubair.plumbing@apexfix.pk';
                                _passwordController.text = 'password123';
                                provider.login(email: 'zubair.plumbing@apexfix.pk', password: 'password123');
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

