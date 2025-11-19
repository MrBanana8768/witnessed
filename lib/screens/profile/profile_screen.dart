import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/auth_service.dart';
import '../../widgets/profile/profile_header.dart';
import '../../widgets/profile/profile_stats.dart';
import '../../widgets/profile/profile_bio.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  final String userId;

  const ProfileScreen({
    Key? key,
    required this.userId,
  }) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch user profile when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authService = context.read<AuthService>();
      final currentUser = authService.currentUser;

      // If viewing own profile and Firebase user exists, pass email and displayName
      // This allows creating profile if it doesn't exist
      if (currentUser != null && currentUser.uid == widget.userId) {
        context.read<ProfileProvider>().fetchUserProfile(
          widget.userId,
          email: currentUser.email,
          displayName: currentUser.displayName,
        );
      } else {
        context.read<ProfileProvider>().fetchUserProfile(widget.userId);
      }
    });
  }

  bool _isCurrentUser(BuildContext context) {
    final currentUser = context.read<AuthService>().currentUser;
    return currentUser?.uid == widget.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          if (profileProvider.isLoading && profileProvider.user == null) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (profileProvider.error != null && profileProvider.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    profileProvider.error!,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      profileProvider.fetchUserProfile(widget.userId);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final user = profileProvider.user;
          if (user == null) {
            return const Center(
              child: Text('User not found'),
            );
          }

          final isCurrentUser = _isCurrentUser(context);

          return CustomScrollView(
            slivers: [
              // App Bar
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                flexibleSpace: FlexibleSpaceBar(
                  background: ProfileHeader(
                    user: user,
                    isCurrentUser: isCurrentUser,
                    onCoverPhotoTap: isCurrentUser
                        ? () => _showImagePickerDialog(context, isCover: true)
                        : null,
                    onProfilePhotoTap: isCurrentUser
                        ? () => _showImagePickerDialog(context, isCover: false)
                        : null,
                  ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Space for profile picture

                    // Edit Profile / Follow Button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          const Spacer(),
                          if (isCurrentUser)
                            OutlinedButton.icon(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(user: user),
                                  ),
                                );
                              },
                              icon: const Icon(Icons.edit, size: 18),
                              label: const Text('Edit Profile'),
                              style: OutlinedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            )
                          else
                            ElevatedButton.icon(
                              onPressed: () {
                                final currentUserId =
                                    context.read<AuthService>().currentUser?.uid;
                                if (currentUserId != null) {
                                  profileProvider.toggleFollow(
                                    currentUserId,
                                    widget.userId,
                                  );
                                }
                              },
                              icon: Icon(
                                profileProvider.isFollowing
                                    ? Icons.check
                                    : Icons.person_add,
                                size: 18,
                              ),
                              label: Text(
                                profileProvider.isFollowing ? 'Following' : 'Follow',
                              ),
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Bio Section
                    ProfileBio(user: user),

                    const SizedBox(height: 24),

                    const Divider(),

                    // Stats Section
                    ProfileStats(
                      user: user,
                      onFollowersTap: () {
                        // TODO: Navigate to followers list
                        _showComingSoon(context, 'Followers List');
                      },
                      onFollowingTap: () {
                        // TODO: Navigate to following list
                        _showComingSoon(context, 'Following List');
                      },
                      onPostsTap: () {
                        // TODO: Scroll to posts section
                      },
                    ),

                    const Divider(),

                    const SizedBox(height: 16),

                    // Posts Section
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Posts',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Posts List (placeholder)
                    _buildPostsPlaceholder(context),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPostsPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(48),
      child: Column(
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No posts yet',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Posts will appear here',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _showImagePickerDialog(BuildContext context, {required bool isCover}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isCover ? 'Update Cover Photo' : 'Update Profile Photo'),
        content: const Text(
          'Image picker functionality will be implemented here.\n\n'
          'This will allow you to:\n'
          '• Take a photo with camera\n'
          '• Choose from gallery\n'
          '• Upload to Firebase Storage',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement image picker
              _showComingSoon(
                context,
                isCover ? 'Cover Photo Upload' : 'Profile Photo Upload',
              );
            },
            child: const Text('Choose Image'),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context, String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$feature - Coming Soon!'),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
