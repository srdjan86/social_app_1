// Page to create a post and upload it to the database

import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app_1/models/post.dart';
import 'package:social_app_1/providers/post_provider.dart';

@RoutePage()
class CreatePostPage extends HookConsumerWidget {
  const CreatePostPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController = useTextEditingController();
    final contentController = useTextEditingController();

    // Use local state for draft post data
    final draftPost = useState<Post?>(null);
    final createPostState = ref.watch(postProvider);

    // Initialize empty draft when page loads
    useEffect(() {
      draftPost.value = Post(
        id: '',
        title: '',
        content: '',
        userId: FirebaseAuth.instance.currentUser?.uid ?? '',
        imageUrls: [],
      );
      return null;
    }, []);

    // Update draft when text changes
    useEffect(() {
      void titleListener() {
        if (draftPost.value != null) {
          draftPost.value = draftPost.value!.copyWith(
            title: titleController.text,
          );
        }
      }

      titleController.addListener(titleListener);
      return () => titleController.removeListener(titleListener);
    }, []);

    useEffect(() {
      void contentListener() {
        if (draftPost.value != null) {
          draftPost.value = draftPost.value!.copyWith(
            content: contentController.text,
          );
        }
      }

      contentController.addListener(contentListener);
      return () => contentController.removeListener(contentListener);
    }, []);

    // Listen for successful post creation
    ref.listen<AsyncValue<Post?>>(postProvider, (previous, next) {
      if (previous is AsyncLoading &&
          next is AsyncData &&
          next.value?.id.isNotEmpty == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Post created successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          context.router.pop(true);
        }
      }
    });

    final draft = draftPost.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Post'),
        backgroundColor: Colors.red,
        actions: [
          TextButton(
            onPressed: draft != null &&
                    draft.title.isNotEmpty &&
                    draft.content.isNotEmpty &&
                    createPostState is! AsyncLoading
                ? () => ref.read(postProvider.notifier).createPost(draft)
                : null,
            child: createPostState is AsyncLoading
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Create Post',
                    style: TextStyle(color: Colors.white),
                  ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: titleController,
              enabled: createPostState is! AsyncLoading,
              decoration: const InputDecoration(
                hintText: 'Post title...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: TextField(
                controller: contentController,
                enabled: createPostState is! AsyncLoading,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'What\'s on your mind?',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ImagePicker(
              onImagesAdded: (imageUrls) {
                if (draft != null) {
                  draftPost.value = draft.copyWith(
                    imageUrls: [...draft.imageUrls, ...imageUrls],
                  );
                }
              },
              isUploading: createPostState is AsyncLoading,
            ),
            if (draft?.imageUrls.isNotEmpty == true) ...[
              const SizedBox(height: 16),
              _ImagePreview(imageUrls: draft!.imageUrls),
            ],
            if (createPostState.hasError)
              Padding(
                padding: const EdgeInsets.only(top: 16),
                child: Text(
                  createPostState.error.toString(),
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ImagePicker extends HookConsumerWidget {
  final Function(List<String>) onImagesAdded;
  final bool isUploading;

  const _ImagePicker({required this.onImagesAdded, required this.isUploading});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isUploadingImages = useState(false);

    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: isUploading || isUploadingImages.value
              ? null
              : () async {
                  try {
                    isUploadingImages.value = true;

                    // Pick images from gallery
                    final images = await ImagePicker().pickMultiImage();
                    final imageUrls = <String>[];
                    if (images.isNotEmpty) {
                      // Upload images to Firebase Storage
                      final storageRef = FirebaseStorage.instance.ref();

                      for (var image in images) {
                        final file = File(image.path);

                        final fileBytes = await file.readAsBytes();

                        // Use user-specific folder structure
                        final imagePath =
                            'users/${FirebaseAuth.instance.currentUser!.uid}/posts/${DateTime.now().millisecondsSinceEpoch}_${image.name}';

                        final imageRef = storageRef.child(imagePath);

                        // Determine content type from file extension
                        String contentType = 'image/jpeg'; // default
                        final fileName = image.name.toLowerCase();
                        if (fileName.endsWith('.png')) {
                          contentType = 'image/png';
                        } else if (fileName.endsWith('.gif')) {
                          contentType = 'image/gif';
                        } else if (fileName.endsWith('.webp')) {
                          contentType = 'image/webp';
                        }

                        // Add metadata with proper content type
                        final metadata = SettableMetadata(
                          contentType: contentType,
                          customMetadata: {
                            'uploaded_by':
                                FirebaseAuth.instance.currentUser!.uid,
                            'original_name': image.name,
                          },
                        );

                        await imageRef.putData(fileBytes, metadata);

                        final imageUrl = await imageRef.getDownloadURL();

                        imageUrls.add(imageUrl);
                      }

                      onImagesAdded(imageUrls);
                    }
                  } catch (e, st) {
                    print(st);

                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error uploading images: $e'),
                          backgroundColor: Colors.red,
                          duration: const Duration(seconds: 5),
                        ),
                      );
                    }
                  } finally {
                    isUploadingImages.value = false;
                  }
                },
          icon: isUploadingImages.value
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.image),
          label: Text(isUploadingImages.value ? 'Uploading...' : 'Add Images'),
        ),
      ],
    );
  }
}

class _ImagePreview extends StatelessWidget {
  final List<String> imageUrls;

  const _ImagePreview({required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Images (${imageUrls.length})',
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 100,
          child: Wrap(
            children: imageUrls.map((url) {
              return Container(
                margin: const EdgeInsets.only(right: 8),
                width: 100,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    url,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.error);
                    },
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
