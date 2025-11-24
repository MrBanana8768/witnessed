import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../../models/post_model.dart';
import '../../models/user_model.dart';
import '../../providers/post_provider.dart';
import '../../services/auth_service.dart';
import '../../services/database_service.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({
    super.key,
    required this.post,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  UserModel? _author;
  bool _isLoading = true;
  bool _isLiked = false;

  @override
  void initState() {
    super.initState();
    _loadAuthor();
  }

  Future<void> _loadAuthor() async {
    final databaseService = DatabaseService();
    final author = await databaseService.getUser(widget.post.userId);

    if (mounted) {
      setState(() {
        _author = author;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Author header
            _buildAuthorHeader(),

            const SizedBox(height: 12),

            // Post content
            Text(
              widget.post.content,
              style: const TextStyle(fontSize: 16),
            ),

            // Images if present
            if (widget.post.hasImages) ...[
              const SizedBox(height: 12),
              _buildImages(),
            ],

            const SizedBox(height: 12),

            // Post metadata
            _buildMetadata(),

            const Divider(height: 24),

            // Actions (like, comment, share)
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthorHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 20,
          backgroundColor: Theme.of(context).primaryColor.withValues(alpha: 0.1),
          backgroundImage: _author?.hasProfilePhoto == true
              ? CachedNetworkImageProvider(_author!.photoUrl!)
              : null,
          child: _author?.hasProfilePhoto != true
              ? Text(
                  _author?.initials ?? '?',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                )
              : null,
        ),

        const SizedBox(width: 12),

        // Author info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    _author?.displayName ?? 'Unknown User',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (_author?.isVerified == true) ...[
                    const SizedBox(width: 4),
                    Icon(
                      Icons.verified,
                      size: 16,
                      color: Theme.of(context).primaryColor,
                    ),
                  ],
                ],
              ),
              Text(
                '@${_author?.username ?? 'unknown'}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),

        // More options
        IconButton(
          icon: const Icon(Icons.more_horiz),
          onPressed: () => _showPostOptions(),
        ),
      ],
    );
  }

  Widget _buildImages() {
    if (widget.post.imageUrls.length == 1) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: CachedNetworkImage(
          imageUrl: widget.post.imageUrls.first,
          width: double.infinity,
          fit: BoxFit.cover,
          placeholder: (context, url) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Center(child: CircularProgressIndicator()),
          ),
          errorWidget: (context, url, error) => Container(
            height: 200,
            color: Colors.grey[200],
            child: const Icon(Icons.error),
          ),
        ),
      );
    }

    // Multiple images - grid layout
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: widget.post.imageUrls.length,
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: CachedNetworkImage(
            imageUrl: widget.post.imageUrls[index],
            fit: BoxFit.cover,
            placeholder: (context, url) => Container(
              color: Colors.grey[200],
              child: const Center(child: CircularProgressIndicator()),
            ),
            errorWidget: (context, url, error) => Container(
              color: Colors.grey[200],
              child: const Icon(Icons.error),
            ),
          ),
        );
      },
    );
  }

  Widget _buildMetadata() {
    return Row(
      children: [
        Text(
          timeago.format(widget.post.createdAt),
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 13,
          ),
        ),
        if (widget.post.isEdited) ...[
          const SizedBox(width: 8),
          Text(
            '(edited)',
            style: TextStyle(
              color: Colors.grey[500],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
        if (widget.post.isAIGenerated) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.auto_awesome,
                  size: 12,
                  color: Colors.purple[700],
                ),
                const SizedBox(width: 4),
                Text(
                  'AI',
                  style: TextStyle(
                    color: Colors.purple[700],
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      children: [
        // Like button
        _buildActionButton(
          icon: _isLiked ? Icons.favorite : Icons.favorite_border,
          label: widget.post.formattedLikes,
          color: _isLiked ? Colors.red : null,
          onPressed: _handleLike,
        ),

        const SizedBox(width: 24),

        // Comment button
        _buildActionButton(
          icon: Icons.comment_outlined,
          label: widget.post.commentsCount.toString(),
          onPressed: _handleComment,
        ),

        const SizedBox(width: 24),

        // Share button
        _buildActionButton(
          icon: Icons.share_outlined,
          label: widget.post.sharesCount > 0
              ? widget.post.sharesCount.toString()
              : '',
          onPressed: _handleShare,
        ),

        const Spacer(),

        // Bookmark button
        IconButton(
          icon: const Icon(Icons.bookmark_border),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Bookmark - Coming Soon!'),
                duration: Duration(seconds: 1),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    Color? color,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          children: [
            Icon(
              icon,
              size: 20,
              color: color ?? Colors.grey[700],
            ),
            if (label.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  color: color ?? Colors.grey[700],
                  fontSize: 13,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _handleLike() async {
    final authService = context.read<AuthService>();
    final postProvider = context.read<PostProvider>();
    final userId = authService.currentUser?.uid;

    if (userId == null) return;

    setState(() {
      _isLiked = !_isLiked;
    });

    if (_isLiked) {
      await postProvider.likePost(widget.post.id, userId);
    } else {
      await postProvider.unlikePost(widget.post.id, userId);
    }
  }

  void _handleComment() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Comments - Coming Soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _handleShare() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share - Coming Soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }

  void _showPostOptions() {
    final authService = context.read<AuthService>();
    final currentUserId = authService.currentUser?.uid;
    final isOwnPost = currentUserId == widget.post.userId;

    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isOwnPost) ...[
              ListTile(
                leading: const Icon(Icons.delete, color: Colors.red),
                title: const Text(
                  'Delete Post',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleDelete();
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: const Text('Report Post'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Report - Coming Soon!')),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel_outlined),
              title: const Text('Cancel'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleDelete() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Post'),
        content: const Text('Are you sure you want to delete this post?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final postProvider = context.read<PostProvider>();
      final success = await postProvider.deletePost(widget.post.id, widget.post.userId);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post deleted successfully')),
        );
      }
    }
  }
}
