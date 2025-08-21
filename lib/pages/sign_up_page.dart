import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/providers/auth_provider.dart';

@RoutePage()
class SignUpPage extends HookConsumerWidget {
  const SignUpPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
        backgroundColor: Colors.red,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: _Body(),
      ),
    );
  }
}

class _Body extends HookConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    // Listen to auth state changes for success feedback
    ref.listen<AsyncValue<User?>>(authProvider, (previous, next) {
      // Check if we just completed a successful signup (loading -> data with user)
      if (previous is AsyncLoading && next is AsyncData && next.value != null) {
        // Show welcome message (InitialPage will handle navigation automatically)
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Welcome! Your account has been created.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    });

    return switch (authState) {
      AsyncData(value: User? user) => user != null
          ? const SizedBox
              .shrink() // User is logged in, InitialPage will handle display
          : _buildSignUpForm(emailController, passwordController, ref),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError(:final error) => Column(
          children: [
            Text('Error: $error'),
            _buildSignUpForm(emailController, passwordController, ref),
          ],
        ),
      _ => const Center(child: Text('Unknown state')),
    };
  }

  Widget _buildSignUpForm(
    TextEditingController emailController,
    TextEditingController passwordController,
    WidgetRef ref,
  ) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
            controller: emailController,
            decoration: InputDecoration(hintText: 'Email')),
        TextField(
            controller: passwordController,
            decoration: InputDecoration(hintText: 'Password')),
        ElevatedButton(
            onPressed: () {
              ref.read(authProvider.notifier).signUpWithEmailAndPassword(
                    email: emailController.text,
                    password: passwordController.text,
                  );
            },
            child: const Text('Sign Up')),
      ],
    );
  }
}
