import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import '../config/constants.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  
  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '${userId}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('${AppConstants.profileImagesPath}/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading profile image: $e');
      return null;
    }
  }

  // Upload cover image
  Future<String?> uploadCoverImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      final String fileName = '${userId}_cover_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final Reference ref = _storage.ref().child('cover_images/$fileName');

      final UploadTask uploadTask = ref.putFile(imageFile);
      final TaskSnapshot snapshot = await uploadTask;

      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading cover image: $e');
      return null;
    }
  }
  
  // Upload post image
  Future<List<String>> uploadPostImages({
    required String postId,
    required List<File> imageFiles,
  }) async {
    try {
      final List<String> imageUrls = [];
      
      for (int i = 0; i < imageFiles.length; i++) {
        final String fileName = '${postId}_${i}_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final Reference ref = _storage.ref().child('${AppConstants.postImagesPath}/$fileName');
        
        final UploadTask uploadTask = ref.putFile(imageFiles[i]);
        final TaskSnapshot snapshot = await uploadTask;
        
        if (snapshot.state == TaskState.success) {
          final String downloadUrl = await snapshot.ref.getDownloadURL();
          imageUrls.add(downloadUrl);
        }
      }
      
      return imageUrls;
    } catch (e) {
      print('Error uploading post images: $e');
      return [];
    }
  }
  
  // Upload video
  Future<String?> uploadVideo({
    required String postId,
    required File videoFile,
  }) async {
    try {
      // Check file size
      final int fileSizeInMB = await videoFile.length() ~/ (1024 * 1024);
      if (fileSizeInMB > AppConstants.maxVideoSizeInMB) {
        throw Exception('Video file size exceeds ${AppConstants.maxVideoSizeInMB}MB limit');
      }
      
      final String fileName = '${postId}_${DateTime.now().millisecondsSinceEpoch}.mp4';
      final Reference ref = _storage.ref().child('videos/$fileName');
      
      final UploadTask uploadTask = ref.putFile(videoFile);
      
      // Monitor upload progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(2)}%');
      });
      
      final TaskSnapshot snapshot = await uploadTask;
      
      if (snapshot.state == TaskState.success) {
        final String downloadUrl = await snapshot.ref.getDownloadURL();
        return downloadUrl;
      }
      return null;
    } catch (e) {
      print('Error uploading video: $e');
      return null;
    }
  }
  
  // Delete file
  Future<bool> deleteFile(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      await ref.delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
  
  // Delete multiple files
  Future<bool> deleteFiles(List<String> fileUrls) async {
    try {
      final List<Future<void>> deleteFutures = fileUrls.map((url) {
        final Reference ref = _storage.refFromURL(url);
        return ref.delete();
      }).toList();
      
      await Future.wait(deleteFutures);
      return true;
    } catch (e) {
      print('Error deleting files: $e');
      return false;
    }
  }
  
  // Get file metadata
  Future<Map<String, dynamic>?> getFileMetadata(String fileUrl) async {
    try {
      final Reference ref = _storage.refFromURL(fileUrl);
      final FullMetadata metadata = await ref.getMetadata();
      
      return {
        'size': metadata.size,
        'contentType': metadata.contentType,
        'timeCreated': metadata.timeCreated,
        'updated': metadata.updated,
        'name': metadata.name,
        'fullPath': metadata.fullPath,
      };
    } catch (e) {
      print('Error getting file metadata: $e');
      return null;
    }
  }
}
