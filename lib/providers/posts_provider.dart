// Provider for all posts

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/models/post.dart';

class PostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  PostsNotifier() : super(const AsyncValue.loading());

  // Fetch all posts
  Future<void> fetchPosts() async {
    state = await AsyncValue.guard(() async {
      final posts = await FirebaseFirestore.instance.collection('posts').get();
      return posts.docs.map((doc) => Post.fromJson(doc.data())).toList();
    });
  }
}

final postsProvider =
    StateNotifierProvider<PostsNotifier, AsyncValue<List<Post>>>((ref) {
  return PostsNotifier();
});

class UserPostsNotifier extends StateNotifier<AsyncValue<List<Post>>> {
  UserPostsNotifier() : super(const AsyncValue.loading());

  // Fetch all posts by user
  Future<void> fetchPostsByUser(String userId) async {
    // Check if the user exists in the database
    final user =
        await FirebaseFirestore.instance.collection('users').doc(userId).get();
    if (!user.exists) {
      return;
    }

    // Get users post ids
    final postIds = user.data()?['posts'] as List<dynamic>? ?? [];

    if (postIds.isEmpty) {
      state = AsyncValue.data([]);
      return;
    }

    // Fetch posts by ids
    final posts = await FirebaseFirestore.instance
        .collection('posts')
        .where('id', whereIn: postIds)
        .get();
    state = AsyncValue.data(
        posts.docs.map((doc) => Post.fromJson(doc.data())).toList());
  }
}

final userPostsProvider =
    StateNotifierProvider<UserPostsNotifier, AsyncValue<List<Post>>>((ref) {
  return UserPostsNotifier();
});
