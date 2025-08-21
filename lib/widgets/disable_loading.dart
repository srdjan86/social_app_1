import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class DisableLoading<T> extends StatelessWidget {
  final AsyncValue<T> state;
  final Widget child;

  const DisableLoading({
    super.key,
    required this.state,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AsyncData() => child,
      AsyncLoading() => Stack(
          children: [
            child,
            Container(
              width: double.infinity,
              height: double.infinity,
              color: Colors.black.withValues(alpha: 0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      AsyncError() => child,
      _ => const SizedBox.shrink(), // This is a fallback case
    };
  }
}
