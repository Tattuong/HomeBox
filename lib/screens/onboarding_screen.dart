import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../core/constants/app_strings.dart';
import '../providers/home_provider.dart';
import 'main_shell.dart';

class OnboardingScreen extends StatelessWidget {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/onboarding_bg.png', fit: BoxFit.cover),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.15),
                  Colors.black.withValues(alpha: 0.55),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(),
                  Text(
                    AppStrings.t(context, 'welcomeTitle'),
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w300, color: Colors.white, height: 1.2),
                  ),
                  Text(
                    AppStrings.t(context, 'welcomeSubtitle'),
                    style: const TextStyle(fontSize: 40, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.t(context, 'welcomeDesc'),
                    style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.9), height: 1.45),
                  ),
                  const SizedBox(height: 24),
                  _FeatureRow(icon: Icons.inventory_2_outlined, text: AppStrings.t(context, 'modStorage')),
                  _FeatureRow(icon: Icons.receipt_long_outlined, text: AppStrings.t(context, 'modBills')),
                  _FeatureRow(icon: Icons.verified_outlined, text: AppStrings.t(context, 'modWarranty')),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () async {
                        await context.read<HomeProvider>().completeOnboarding();
                        if (!context.mounted) return;
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const MainShell()),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(AppStrings.t(context, 'getStarted'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(width: 8),
                          const Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.9), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.92), fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}
