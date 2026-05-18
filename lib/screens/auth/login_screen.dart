import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/auth_provider.dart';
import 'auth_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _mobileCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  int _tab = 0; // 0 = mobile, 1 = email
  String _countryCode = '+20';

  @override
  void dispose() {
    _emailCtrl.dispose();
    _mobileCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = _tab == 1
        ? await auth.signIn(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text,
          )
        : await auth.signInWithMobile(
            countryCode: _countryCode,
            mobile: _mobileCtrl.text.trim(),
            password: _passCtrl.text,
          );
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Login failed'),
          backgroundColor: AppColors.red,
        ),
      );
    }
  }

  Future<void> _googleSignIn() async {
    final auth = context.read<AuthProvider>();
    final ok = await auth.signInWithGoogle();
    if (!mounted) return;
    if (ok) {
      context.go('/home');
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.error!), backgroundColor: AppColors.red),
      );
    }
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
                const SizedBox(height: 16),
                const Center(
                  child: Text(
                    'Login or Sign Up',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                _PillTabs(
                  selected: _tab,
                  labels: const ['Mobile Number', 'Email'],
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: 20),
                if (_tab == 0)
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
                            if (_tab != 0) return null;
                            final t = v?.trim() ?? '';
                            if (t.length < 7 || t.length > 15) {
                              return 'Enter a valid mobile number';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  )
                else
                  TextFormField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: authInputDecoration('Email'),
                    validator: (v) {
                      if (_tab != 1) return null;
                      return (v == null || !v.contains('@'))
                          ? 'Enter a valid email'
                          : null;
                    },
                  ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passCtrl,
                  obscureText: _obscure,
                  decoration: authInputDecoration(
                    'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        color: AppColors.textMuted,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Min 6 characters' : null,
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => context.push('/forgot-password'),
                    child: const Text(
                      'FORGOT PASSWORD ?',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GradientButton(
                  label: 'LOGIN',
                  loading: auth.loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: 28),
                const Center(
                  child: Text(
                    'Login or Signup With Your Social Accounts',
                    style: TextStyle(color: AppColors.textMuted),
                  ),
                ),
                const SizedBox(height: 16),
                SocialButton(
                  label: 'Continue with Google',
                  onPressed: auth.loading ? null : _googleSignIn,
                  icon: const Text(
                    'G',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                const Center(
                  child: Text(
                    "Don't have an account?",
                    style: TextStyle(color: AppColors.textDark),
                  ),
                ),
                const SizedBox(height: 12),
                SocialButton(
                  label: 'SIGN UP',
                  labelColor: AppColors.primary,
                  onPressed: () => context.push('/signup'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PillTabs extends StatelessWidget {
  final int selected;
  final List<String> labels;
  final ValueChanged<int> onChanged;

  const _PillTabs({
    required this.selected,
    required this.labels,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFEDEFF2),
        borderRadius: BorderRadius.circular(40),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: List.generate(labels.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onChanged(i),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppColors.primaryLight : Colors.transparent,
                  borderRadius: BorderRadius.circular(40),
                ),
                child: Text(
                  labels[i],
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: active ? AppColors.primaryDark : AppColors.textMuted,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
