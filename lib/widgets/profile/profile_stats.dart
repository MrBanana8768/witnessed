import 'package:flutter/material.dart';
import '../../models/user_model.dart';

class ProfileStats extends StatelessWidget {
  final UserModel user;
  final VoidCallback? onFollowersTap;
  final VoidCallback? onFollowingTap;
  final VoidCallback? onPostsTap;

  const ProfileStats({
    Key? key,
    required this.user,
    this.onFollowersTap,
    this.onFollowingTap,
    this.onPostsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _StatItem(
          count: user.postsCount,
          label: 'Posts',
          onTap: onPostsTap,
        ),
        _StatItem(
          count: user.followersCount,
          label: 'Followers',
          onTap: onFollowersTap,
        ),
        _StatItem(
          count: user.followingCount,
          label: 'Following',
          onTap: onFollowingTap,
        ),
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  final int count;
  final String label;
  final VoidCallback? onTap;

  const _StatItem({
    required this.count,
    required this.label,
    this.onTap,
  });

  String _formatCount(int count) {
    if (count >= 1000000) {
      return '${(count / 1000000).toStringAsFixed(1)}M';
    } else if (count >= 1000) {
      return '${(count / 1000).toStringAsFixed(1)}K';
    }
    return count.toString();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            Text(
              _formatCount(count),
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }
}