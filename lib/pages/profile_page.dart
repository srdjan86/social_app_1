import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/models/post.dart';
import 'package:social_app_1/providers/post_provider.dart';
import 'package:social_app_1/providers/posts_provider.dart';
import 'package:social_app_1/router/router.gr.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Stack(
      children: [
        _Body(),
        Positioned(
          bottom: 32,
          right: 32,
          child: FloatingActionButton(
            child: const Icon(Icons.add),
            onPressed: () async {
              final result = await context.pushRoute(const CreatePostRoute());
              if (result != null) {
                ref
                    .read(userPostsProvider.notifier)
                    .fetchPostsByUser(FirebaseAuth.instance.currentUser!.uid);
              }
            },
          ),
        ),
      ],
    );
  }
}

class _Body extends HookConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Lists all the posts for the current user
    final posts = ref.watch(userPostsProvider);
    //  Trigger fetch posts when the page is loaded
    useEffect(() {
      ref
          .read(userPostsProvider.notifier)
          .fetchPostsByUser(FirebaseAuth.instance.currentUser!.uid);
      return null;
    }, []);

    return switch (posts) {
      AsyncData() => ListView.builder(
          itemCount: posts.value.length,
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemBuilder: (context, index) {
            return _PostCard(post: posts.value[index]);
          },
        ),
      AsyncLoading() => const Center(child: CircularProgressIndicator()),
      AsyncError() => const Center(child: Text('Error')),
      _ => const SizedBox.shrink(),
    };
  }
}

class _PostCard extends HookConsumerWidget {
  final Post post;

  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return InkWell(
      onTap: () {
        context.pushRoute(PostRoute(postId: post.id));
      },
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      post.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () async {
                      final result = await ref
                          .read(postProvider.notifier)
                          .deletePost(post.id);
                      if (result) {
                        ref.read(userPostsProvider.notifier).fetchPostsByUser(
                            FirebaseAuth.instance.currentUser!.uid);
                      }
                    },
                    icon: const Icon(Icons.delete),
                    color: Colors.red.shade600,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                post.content,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Wrap(
                children: post.thumbnailUrls
                    .map((url) => Image.network(url))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
