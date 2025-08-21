import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/providers/auth_provider.dart';
import 'package:social_app_1/router/router.gr.dart';

@RoutePage()
class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        backgroundColor: Colors.red,
      ),
      body: _LoginForm(),
    );
  }
}

class _LoginForm extends HookConsumerWidget {
  const _LoginForm();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();

    final authState = ref.watch(authProvider);
    final isLoading = authState is AsyncLoading;
    final error = authState is AsyncError ? authState.error : null;

    return Stack(
      children: [
        // Main form - always visible
        Column(
          children: [
            // Show error message if exists
            if (error != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade200),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Error: $error',
                  style: TextStyle(color: Colors.red.shade700),
                ),
              ),
            ],
            // Login form
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: _LoginFormBody(
                  emailController: emailController,
                  passwordController: passwordController,
                  ref: ref,
                  isLoading: isLoading,
                ),
              ),
            ),
          ],
        ),

        // Loading overlay
        if (isLoading)
          Container(
            color: Colors.black.withValues(alpha: 0.3),
            child: const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Signing in...'),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LoginFormBody extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final WidgetRef ref;
  final bool isLoading;

  const _LoginFormBody({
    required this.emailController,
    required this.passwordController,
    required this.ref,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        TextField(
          controller: emailController,
          enabled: !isLoading,
          decoration: InputDecoration(hintText: 'Email'),
        ),
        TextField(
          controller: passwordController,
          enabled: !isLoading,
          obscureText: true,
          decoration: InputDecoration(hintText: 'Password'),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: isLoading
              ? null
              : () {
                  ref.read(authProvider.notifier).signInWithEmailAndPassword(
                        email: emailController.text,
                        password: passwordController.text,
                      );
                },
          child: const Text('Login'),
        ),
        const SizedBox(height: 32),
        TextButton(
          onPressed: isLoading
              ? null
              : () {
                  context.pushRoute(const SignUpRoute());
                },
          child: const Text('Sign Up'),
        ),
      ],
    );
  }
}
