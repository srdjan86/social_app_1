// Page to create a post and upload it to the database

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/models/post.dart';
import 'package:social_app_1/providers/post_provider.dart';
import 'package:social_app_1/widgets/post_form.dart';

@RoutePage()
class CreatePostPage extends HookConsumerWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.red,
      ),
      body: PostForm(
        initialPost: null, // null for create mode
        submitButtonText: 'Create Post',
        onSubmit: (post) => ref.read(postProvider.notifier).createPost(post),
        onSuccess: () => context.router.pop(true),
      ),
    );
  }
}
