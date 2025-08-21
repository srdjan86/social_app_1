import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/pages/home_page.dart';
import 'package:social_app_1/pages/login_page.dart';
import 'package:social_app_1/providers/auth_provider.dart';

@RoutePage()
class InitialPage extends HookConsumerWidget {
  const InitialPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    // Simple check: if we have user data, show HomePage, otherwise show LoginPage
    // Let individual pages handle their own loading/error states
    final user = authState.valueOrNull;

    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: user != null ? const HomePage() : const LoginPage(),
      ),
    );
  }
}
