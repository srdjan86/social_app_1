import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/pages/profile_page.dart';
import 'package:social_app_1/providers/auth_provider.dart';

@RoutePage()
class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final index = useState(0);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: Colors.red,
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              Text('Menu'),
              Spacer(),
              TextButton(
                onPressed: () {
                  ref.read(authProvider.notifier).signOut();
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ),
      ),
      // Display the selected page based on the bottom navigation bar index
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: switch (index.value) {
          0 => const Center(child: Text('Home')),
          1 => const Center(child: Text('Search')),
          2 => ProfilePage(),
          _ => const Center(child: Text('Unknown')),
        },
      ),

      // Bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: index.value,
        onTap: (i) {
          index.value = i;
        },
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
