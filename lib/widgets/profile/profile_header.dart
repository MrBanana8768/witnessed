import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';

class ProfileHeader extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onCoverPhotoTap;
  final VoidCallback? onProfilePhotoTap;
  final bool isCurrentUser;

  const ProfileHeader({
    super.key,
    required this.user,
    this.onCoverPhotoTap,
    this.onProfilePhotoTap,
    this.isCurrentUser = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        // Cover Photo
        GestureDetector(
          onTap: isCurrentUser ? onCoverPhotoTap : null,
          child: Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              image: user.hasCoverPhoto
                  ? DecorationImage(
                      image: CachedNetworkImageProvider(user.coverPhotoUrl!),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: !user.hasCoverPhoto
                ? Icon(
                    Icons.camera_alt,
                    size: 48,
                    color: Colors.grey[600],
                  )
                : null,
          ),
        ),

        // Profile Photo
        Positioned(
          bottom: -50,
          child: GestureDetector(
            onTap: isCurrentUser ? onProfilePhotoTap : null,
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 4,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[400],
                backgroundImage: user.hasProfilePhoto
                    ? CachedNetworkImageProvider(user.photoUrl!)
                    : null,
                child: !user.hasProfilePhoto
                    ? Text(
                        user.initials,
                        style: const TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      )
                    : null,
              ),
            ),
          ),
        ),

        // Camera icon for profile photo (if current user)
        if (isCurrentUser)
          Positioned(
            bottom: -45,
            right: MediaQuery.of(context).size.width / 2 - 100,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
              ),
              child: const Icon(
                Icons.camera_alt,
                size: 20,
                color: Colors.white,
              ),
            ),
          ),
      ],
    );
  }
}
