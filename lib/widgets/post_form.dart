import 'dart:typed_data';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:social_app_1/models/post.dart';
import 'package:social_app_1/providers/post_provider.dart';

class PostForm extends HookConsumerWidget {
  final Post? initialPost; // null for create, existing post for edit
  final String submitButtonText;
  final Function(Post) onSubmit;
  final VoidCallback? onSuccess;

  const PostForm({
    super.key,
    this.initialPost,
    required this.submitButtonText,
    required this.onSubmit,
    this.onSuccess,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleController =
        useTextEditingController(text: initialPost?.title ?? '');
    final contentController =
        useTextEditingController(text: initialPost?.content ?? '');

    // Use local state for draft post data
    final draftPost = useState<Post>(initialPost ??
        Post(
          id: '',
          title: '',
          content: '',
          userId: FirebaseAuth.instance.currentUser?.uid ?? '',
          imageUrls: [],
          thumbnailUrls: [],
        ));

    final postState = ref.watch(postProvider);

    // Update draft when text changes
    useEffect(() {
      void titleListener() {
        draftPost.value = draftPost.value.copyWith(
          title: titleController.text,
        );
      }

      titleController.addListener(titleListener);
      return () => titleController.removeListener(titleListener);
    }, []);

    useEffect(() {
      void contentListener() {
        draftPost.value = draftPost.value.copyWith(
          content: contentController.text,
        );
      }

      contentController.addListener(contentListener);
      return () => contentController.removeListener(contentListener);
    }, []);

    // Listen for successful post operation
    ref.listen<AsyncValue<Post?>>(postProvider, (previous, next) {
      if (previous is AsyncLoading &&
          next is AsyncData &&
          next.value?.id.isNotEmpty == true) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(initialPost != null
                  ? 'Post updated successfully.'
                  : 'Post created successfully.'),
              backgroundColor: Colors.green,
            ),
          );
          onSuccess?.call();
        }
      }
    });

    final draft = draftPost.value;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: titleController,
            enabled: postState is! AsyncLoading,
            decoration: const InputDecoration(
              hintText: 'Post title...',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: contentController,
              enabled: postState is! AsyncLoading,
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
            onImagesAdded: (imageUrls, thumbnailUrls) {
              draftPost.value = draft.copyWith(
                imageUrls: [...draft.imageUrls, ...imageUrls],
                thumbnailUrls: [...draft.thumbnailUrls, ...thumbnailUrls],
              );
            },
            isUploading: postState is AsyncLoading,
          ),
          if (draft.thumbnailUrls.isNotEmpty) ...[
            const SizedBox(height: 16),
            _ImagePreview(
              imageUrls: draft.thumbnailUrls,
              fullSizeUrls: draft.imageUrls,
              onImageRemoved: initialPost != null
                  ? (index) {
                      final newImageUrls = List<String>.from(draft.imageUrls);
                      final newThumbnailUrls =
                          List<String>.from(draft.thumbnailUrls);
                      newImageUrls.removeAt(index);
                      newThumbnailUrls.removeAt(index);
                      draftPost.value = draft.copyWith(
                        imageUrls: newImageUrls,
                        thumbnailUrls: newThumbnailUrls,
                      );
                    }
                  : null,
            ),
          ],
          if (postState.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                postState.error.toString(),
                style: const TextStyle(color: Colors.red),
              ),
            ),
        ],
      ),
    );
  }
}

class _ImagePicker extends HookConsumerWidget {
  final Function(List<String>, List<String>) onImagesAdded;
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
                    if (images.isNotEmpty) {
                      // Upload images using the provider
                      final uploadResults = await ref
                          .read(postProvider.notifier)
                          .uploadImages(images);

                      // Extract URLs
                      final imageUrls =
                          uploadResults.map((r) => r['full']!).toList();
                      final thumbnailUrls =
                          uploadResults.map((r) => r['thumbnail']!).toList();

                      // Add to draft
                      onImagesAdded(imageUrls, thumbnailUrls);
                    }
                  } catch (e, st) {
                    print('Upload error: $e');
                    print('Stack trace: $st');
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
  final List<String>? fullSizeUrls;
  final Function(int)? onImageRemoved;

  const _ImagePreview({
    required this.imageUrls,
    this.fullSizeUrls,
    this.onImageRemoved,
  });

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
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: imageUrls.length,
            itemBuilder: (context, index) {
              return Stack(
                children: [
                  GestureDetector(
                    onTap: () {
                      // Show full-size image if available
                      if (fullSizeUrls != null &&
                          fullSizeUrls!.length > index) {
                        _showFullSizeImage(context, fullSizeUrls![index]);
                      } else {
                        _showFullSizeImage(context, imageUrls[index]);
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      width: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          imageUrls[index],
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                                child: CircularProgressIndicator());
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(Icons.error);
                          },
                        ),
                      ),
                    ),
                  ),
                  if (onImageRemoved != null)
                    Positioned(
                      top: 4,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => onImageRemoved!(index),
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  void _showFullSizeImage(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Stack(
          children: [
            InteractiveViewer(
              child: Image.network(
                imageUrl,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Center(child: Icon(Icons.error, size: 50));
                },
              ),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.close, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
