import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/providers/post_provider.dart';
import 'package:social_app_1/widgets/post_form.dart';

@RoutePage()
class PostPage extends HookConsumerWidget {
  final String postId;
  const PostPage({super.key, required this.postId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = ref.watch(postByIdProvider(postId));

    return post.when(
      data: (postData) => postData != null
          ? Scaffold(
              appBar: AppBar(
                title: const Text('Edit Post'),
                backgroundColor: Colors.red,
              ),
              body: PostForm(
                initialPost: postData, // existing post for edit mode
                submitButtonText: 'Update Post',
                onSubmit: (post) =>
                    ref.read(postProvider.notifier).updatePost(post),
                onSuccess: () => context.router.pop(true),
              ),
            )
          : const Scaffold(
              body: Center(child: Text('Post not found')),
            ),
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(child: Text('Error: $error')),
      ),
    );
  }
}
