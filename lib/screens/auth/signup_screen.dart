import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  String _countryCode = '+20';
  String? _gender;
  DateTime? _dob;
  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final initial = _dob ?? DateTime(now.year - 20, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
    );
    if (picked != null) setState(() => _dob = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_gender == null) {
      _snack('Please select a gender');
      return;
    }
    if (_dob == null) {
      _snack('Please select your date of birth');
      return;
    }
    if (!_acceptTerms) return;

    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.signUp(
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      firstName: _firstCtrl.text.trim(),
      lastName: _lastCtrl.text.trim(),
      countryCode: _countryCode,
      mobile: _mobileCtrl.text.trim(),
      gender: _gender,
      dateOfBirth: _dob,
    );
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      _snack(auth.error ?? 'Sign up failed');
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: AppColors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AuthHeader(),
                const SizedBox(height: 8),
                const Center(
                  child: Text(
                    'Sign Up',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _firstCtrl,
                  decoration: authInputDecoration('First Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _lastCtrl,
                  decoration: authInputDecoration('Last Name'),
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: authInputDecoration('Email'),
                  validator: (v) => (v == null || !v.contains('@'))
                      ? 'Enter a valid email'
                      : null,
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CountryCodeDropdown(
                      value: _countryCode,
                      onChanged: (v) => setState(() => _countryCode = v),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _mobileCtrl,
                        keyboardType: TextInputType.phone,
                        decoration: authInputDecoration('Mobile Number'),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.length < 7 || t.length > 15) {
                            return 'Enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Padding(
                  padding: EdgeInsets.only(left: 4),
                  child: Text(
                    'We will send SMS to this number to verify it',
                    style:
                        TextStyle(color: AppColors.textMuted, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _gender,
                  decoration: authInputDecoration('Gender'),
                  hint: const Text('Gender',
                      style: TextStyle(color: AppColors.textMuted)),
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: AppColors.textMuted),
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (v) => setState(() => _gender = v),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: _pickDate,
                  child: AbsorbPointer(
                    child: TextFormField(
                      decoration: authInputDecoration(
                        'Date Of Birth',
                        suffixIcon: const Icon(Icons.calendar_today_outlined,
                            color: AppColors.textMuted, size: 20),
                      ),
                      controller: TextEditingController(
                        text: _dob == null
                            ? ''
                            : DateFormat('dd / MM / yyyy').format(_dob!),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscurePass,
                  decoration: authInputDecoration(
                    'Create Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePass
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _confirmCtrl,
                  obscureText: _obscureConfirm,
                  decoration: authInputDecoration(
                    'Confirm Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) => v != _passCtrl.text
                      ? 'Passwords do not match'
                      : null,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptTerms,
                        onChanged: (v) =>
                            setState(() => _acceptTerms = v ?? false),
                        side: const BorderSide(
                            color: AppColors.primary, width: 1.5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(
                              color: AppColors.textMuted, fontSize: 14),
                          children: [
                            TextSpan(text: 'I Accept '),
                            TextSpan(
                              text: 'Terms and Conditions',
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                SocialButton(
                  label: 'CONTINUE',
                  labelColor: _acceptTerms
                      ? AppColors.primary
                      : AppColors.textMuted,
                  onPressed:
                      (auth.loading || !_acceptTerms) ? null : _submit,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
