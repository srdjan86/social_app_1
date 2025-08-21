import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/router/router.dart';
import 'package:social_app_1/utils/firebase.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initFirebase();

  runApp(ProviderScope(child: const MainApp()));
}

class MainApp extends HookWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = useMemoized(() => AppRouter(), []);

    return MaterialApp.router(
      routerConfig: router.config(),
    );
  }
}
