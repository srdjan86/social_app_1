// Provider for the post

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:social_app_1/models/post.dart';

class PostNotifier extends StateNotifier<AsyncValue<Post?>> {
  PostNotifier() : super(const AsyncValue.data(null));

  // Create a post from the provided Post object
  Future<void> createPost(Post post) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final postRef = FirebaseFirestore.instance.collection('posts').doc();
      final postWithId = post.copyWith(
        id: postRef.id,
        userId: FirebaseAuth.instance.currentUser!.uid,
      );

      await postRef.set(postWithId.toJson());

      // Also update users post list so that Firebase query can be quicker
      await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .update({
        'posts': FieldValue.arrayUnion([postRef.id]),
      });

      return postWithId;
    });
  }

  Future<bool> deletePost(String postId) async {
    state = const AsyncValue.loading();
    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();
    // Also remove id from users post list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'posts': FieldValue.arrayRemove([postId]),
    });
    state = const AsyncValue.data(null);
    return true;
  }

  // Reset state (for cleanup)
  void reset() {
    state = const AsyncValue.data(null);
  }
}

final postProvider =
    StateNotifierProvider<PostNotifier, AsyncValue<Post?>>((ref) {
  return PostNotifier();
});
