// Provider for the post

import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app_1/models/post.dart';
import 'package:social_app_1/utils/image_compress.dart';

class PostNotifier extends StateNotifier<AsyncValue<Post?>> {
  PostNotifier() : super(const AsyncValue.data(null));

  // Upload images and return both full-size and thumbnail URLs
  Future<List<Map<String, String>>> uploadImages(List<XFile> images) async {
    final results = <Map<String, String>>[];
    final storageRef = FirebaseStorage.instance.ref();
    final userId = FirebaseAuth.instance.currentUser!.uid;

    for (var image in images) {
      final file = File(image.path);
      final fileBytes = await file.readAsBytes();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final baseFileName = image.name.split('.').first;
      final fileExtension = image.name.split('.').last;

      // Create compressed thumbnail
      final thumbnailBytes = await ImageCompressor.compressImage(
        fileBytes,
        maxWidth: 300,
        maxHeight: 300,
      );

      // Upload full-size image
      final fullImagePath =
          'users/$userId/posts/${timestamp}_${baseFileName}_full.$fileExtension';
      final fullImageRef = storageRef.child(fullImagePath);

      // Upload thumbnail
      final thumbnailPath =
          'users/$userId/posts/${timestamp}_${baseFileName}_thumb.$fileExtension';
      final thumbnailRef = storageRef.child(thumbnailPath);

      // Determine content type
      String contentType = 'image/jpeg';
      final fileName = image.name.toLowerCase();
      if (fileName.endsWith('.png')) {
        contentType = 'image/png';
      } else if (fileName.endsWith('.gif')) {
        contentType = 'image/gif';
      } else if (fileName.endsWith('.webp')) {
        contentType = 'image/webp';
      }

      // Upload both images in parallel
      await Future.wait([
        fullImageRef.putData(
            fileBytes,
            SettableMetadata(
              contentType: contentType,
              customMetadata: {
                'uploaded_by': userId,
                'original_name': image.name,
                'type': 'full',
              },
            )),
        thumbnailRef.putData(
            thumbnailBytes,
            SettableMetadata(
              contentType: contentType,
              customMetadata: {
                'uploaded_by': userId,
                'original_name': image.name,
                'type': 'thumbnail',
              },
            )),
      ]);

      // Get download URLs
      final fullImageUrl = await fullImageRef.getDownloadURL();
      final thumbnailUrl = await thumbnailRef.getDownloadURL();

      results.add({
        'full': fullImageUrl,
        'thumbnail': thumbnailUrl,
      });
    }

    return results;
  }

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

  // Update an existing post
  Future<void> updatePost(Post post) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final postRef =
          FirebaseFirestore.instance.collection('posts').doc(post.id);
      await postRef.update(post.toJson());
      return post;
    });
  }

  Future<bool> deletePost(String postId) async {
    state = const AsyncValue.loading();

    // Also remove id from users post list
    await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .update({
      'posts': FieldValue.arrayRemove([postId]),
    });
    // Also delete images from storage
    final postRef = FirebaseFirestore.instance.collection('posts').doc(postId);
    final postData = await postRef.get();
    final post = Post.fromJson(postData.data()!);
    for (var imageUrl in post.imageUrls) {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }
    for (var imageUrl in post.thumbnailUrls) {
      final storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
      await storageRef.delete();
    }

    await FirebaseFirestore.instance.collection('posts').doc(postId).delete();

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

// Provider for fetching individual posts by ID
final postByIdProvider =
    FutureProvider.family<Post?, String>((ref, postId) async {
  final doc =
      await FirebaseFirestore.instance.collection('posts').doc(postId).get();
  if (doc.exists) {
    return Post.fromJson(doc.data()!);
  }
  return null;
});
