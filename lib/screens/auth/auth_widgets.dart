import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';

const List<Map<String, String>> kCountryCodes = [
  {'code': '+20', 'name': 'EG'},
  {'code': '+966', 'name': 'SA'},
  {'code': '+971', 'name': 'AE'},
  {'code': '+1', 'name': 'US'},
  {'code': '+44', 'name': 'UK'},
];

class AuthHeader extends StatelessWidget {
  final bool showBack;
  const AuthHeader({super.key, this.showBack = true});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Center(
            child: Image.asset(
              'assets/images/elezaby_logo.png',
              height: 40,
              errorBuilder: (_, __, ___) => RichText(
                text: const TextSpan(
                  children: [
                    TextSpan(
                      text: 'el',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontStyle: FontStyle.italic,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                    TextSpan(
                      text: 'ezaby',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showBack)
            Positioned(
              left: 0,
              child: IconButton(
                icon: const Icon(Icons.arrow_back,
                    color: AppColors.textMuted, size: 28),
                onPressed: () {
                  if (Navigator.of(context).canPop()) {
                    Navigator.of(context).pop();
                  } else {
                    context.go('/');
                  }
                },
              ),
            ),
        ],
      ),
    );
  }
}

InputDecoration authInputDecoration(String label, {Widget? suffixIcon}) {
  return InputDecoration(
    labelText: label,
    suffixIcon: suffixIcon,
    floatingLabelBehavior: FloatingLabelBehavior.never,
    contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
    labelStyle: const TextStyle(color: AppColors.textMuted, fontSize: 15),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFD7DDE3)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.red, width: 1.4),
    ),
  );
}

class CountryCodeDropdown extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;
  const CountryCodeDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD7DDE3)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isDense: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppColors.textMuted),
          style: const TextStyle(
            color: AppColors.textDark,
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
          items: kCountryCodes
              .map((c) => DropdownMenuItem<String>(
                    value: c['code'],
                    child: Text(c['code']!),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  const GradientButton({
    super.key,
    required this.label,
    this.onPressed,
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    final disabled = onPressed == null || loading;
    return Opacity(
      opacity: disabled ? 0.6 : 1,
      child: InkWell(
        borderRadius: BorderRadius.circular(40),
        onTap: disabled ? null : onPressed,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.primary, AppColors.primaryDarker],
            ),
            borderRadius: BorderRadius.circular(40),
          ),
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 17,
                    letterSpacing: 0.5,
                  ),
                ),
        ),
      ),
    );
  }
}

class SocialButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final Widget? icon;
  final Color labelColor;

  const SocialButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.labelColor = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(40),
      onTap: onPressed,
      child: Container(
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, AppColors.primaryLight],
          ),
          borderRadius: BorderRadius.circular(40),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.5)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              icon!,
              const SizedBox(width: 10),
            ],
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: labelColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
