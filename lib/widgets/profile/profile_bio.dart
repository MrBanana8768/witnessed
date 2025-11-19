import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import 'package:intl/intl.dart';

class ProfileBio extends StatelessWidget {
  final UserModel user;

  const ProfileBio({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display Name
          Row(
            children: [
              Text(
                user.displayName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (user.isVerified) ...[
                const SizedBox(width: 6),
                Icon(
                  Icons.verified,
                  color: Colors.blue[700],
                  size: 22,
                ),
              ],
            ],
          ),

          const SizedBox(height: 4),

          // Username
          Text(
            '@${user.username}',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),

          // Bio
          if (user.bio != null && user.bio!.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              user.bio!,
              style: const TextStyle(
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ],

          const SizedBox(height: 12),

          // Location
          if (user.location != null && user.location!.isNotEmpty)
            _InfoRow(
              icon: Icons.location_on_outlined,
              text: user.location!,
            ),

          // Website
          if (user.website != null && user.website!.isNotEmpty)
            _InfoRow(
              icon: Icons.link,
              text: user.website!,
              isLink: true,
            ),

          // Join Date
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            text: 'Joined ${DateFormat.yMMMM().format(user.createdAt)}',
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLink;

  const _InfoRow({
    required this.icon,
    required this.text,
    this.isLink = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: Colors.grey[600],
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: isLink ? Colors.blue[700] : Colors.grey[800],
                decoration: isLink ? TextDecoration.underline : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}