import 'package:flutter/material.dart';
import 'wreck_theme.dart';

/// Lightweight onboarding (1 page) to clarify: this is NOT a marketplace.
class WreckOnboarding extends StatelessWidget {
  final VoidCallback onDone;

  const WreckOnboarding({super.key, required this.onDone});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(WreckTheme.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              Text('Welcome to', style: t.titleLarge?.copyWith(color: WreckTheme.text1)),
              const SizedBox(height: 6),
              Text('WreckLog', style: t.displaySmall?.copyWith(fontWeight: FontWeight.w900)),
              const SizedBox(height: 18),

              _bullet('Track vehicles you’re dismantling.'),
              _bullet('Log parts removed, listed, sold, and scrapped.'),
              _bullet('See revenue + profit per vehicle.'),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(WreckTheme.s12),
                decoration: BoxDecoration(
                  color: WreckTheme.surface,
                  borderRadius: BorderRadius.circular(WreckTheme.r12),
                  border: Border.all(color: WreckTheme.border),
                ),
                child: Text(
                  'Important: WreckLog is NOT a marketplace.\n'
                  'It helps you track parts and profits — you still list on eBay/Facebook/Gumtree.',
                  style: t.bodyMedium?.copyWith(color: WreckTheme.text0, fontWeight: FontWeight.w600),
                ),
              ),

              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: onDone,
                  child: const Text('Got it'),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          const Icon(Icons.check_circle, size: 18, color: WreckTheme.accent),
          const SizedBox(width: 10),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }
}