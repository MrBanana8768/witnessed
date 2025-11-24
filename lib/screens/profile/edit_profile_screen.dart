import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user_model.dart';
import '../../providers/profile_provider.dart';
import '../../services/database_service.dart';
import '../../widgets/common/app_navigation_rail.dart';
import '../../config/constants.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({
    super.key,
    required this.user,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _databaseService = DatabaseService();
  late TextEditingController _displayNameController;
  late TextEditingController _usernameController;
  late TextEditingController _bioController;
  late TextEditingController _websiteController;
  late TextEditingController _locationController;
  bool _isPrivate = false;
  bool _hasChanges = false;
  String? _usernameError;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController(text: widget.user.displayName);
    _usernameController = TextEditingController(text: widget.user.username);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _websiteController = TextEditingController(text: widget.user.website ?? '');
    _locationController = TextEditingController(text: widget.user.location ?? '');
    _isPrivate = widget.user.isPrivate;

    // Add listeners to track changes
    _displayNameController.addListener(_onChanged);
    _usernameController.addListener(_onChanged);
    _bioController.addListener(_onChanged);
    _websiteController.addListener(_onChanged);
    _locationController.addListener(_onChanged);
  }

  void _onChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  Future<void> _checkUsernameAvailability(String username) async {
    // Clear previous error
    setState(() {
      _usernameError = null;
    });

    // Skip check if username hasn't changed
    if (username == widget.user.username) {
      return;
    }

    // Skip check if username is empty or invalid format
    if (username.trim().isEmpty || username.trim().length < 3) {
      return;
    }

    if (!AppConstants.usernameRegex.hasMatch(username.trim())) {
      return;
    }

    // Check availability
    final isAvailable = await _databaseService.isUsernameAvailable(
      username.trim(),
      excludeUserId: widget.user.id,
    );

    if (!isAvailable && mounted) {
      setState(() {
        _usernameError = 'Username is already taken';
      });
    }
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    _websiteController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final profileProvider = context.read<ProfileProvider>();

    // Show loading indicator
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    final success = await profileProvider.updateProfile(
      displayName: _displayNameController.text.trim(),
      username: _usernameController.text.trim(),
      bio: _bioController.text.trim(),
      website: _websiteController.text.trim(),
      location: _locationController.text.trim(),
      isPrivate: _isPrivate,
    );

    // Close loading dialog
    if (mounted) Navigator.pop(context);

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(profileProvider.error ?? 'Failed to update profile'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to discard them?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        final shouldPop = await _onWillPop();
        if (shouldPop && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: Row(
          children: [
            // Navigation Rail
            const AppNavigationRail(selectedIndex: 5),

            // Vertical Divider
            const VerticalDivider(thickness: 1, width: 1),

            // Main Content
            Expanded(
              child: Column(
                children: [
                  // App Bar
                  AppBar(
                    title: const Text('Edit Profile'),
                    automaticallyImplyLeading: true,
                  ),

                  // Form Content
                  Expanded(
                    child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Display Name
              TextFormField(
                controller: _displayNameController,
                decoration: const InputDecoration(
                  labelText: 'Display Name',
                  hintText: 'Your display name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person),
                ),
                maxLength: AppConstants.maxDisplayNameLength,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Display name is required';
                  }
                  if (value.trim().length < 2) {
                    return 'Display name must be at least 2 characters';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  hintText: 'Your unique username',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.alternate_email),
                  errorText: _usernameError,
                  suffixIcon: _usernameController.text != widget.user.username &&
                          _usernameController.text.isNotEmpty
                      ? (_usernameError == null
                          ? const Icon(Icons.check_circle, color: Colors.green)
                          : const Icon(Icons.error, color: Colors.red))
                      : null,
                ),
                maxLength: AppConstants.maxUsernameLength,
                onChanged: (value) {
                  _onChanged();
                  // Debounce the availability check
                  Future.delayed(const Duration(milliseconds: 500), () {
                    if (_usernameController.text == value) {
                      _checkUsernameAvailability(value);
                    }
                  });
                },
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Username is required';
                  }
                  if (value.trim().length < 3) {
                    return 'Username must be at least 3 characters';
                  }
                  if (!AppConstants.usernameRegex.hasMatch(value.trim())) {
                    return 'Username can only contain letters, numbers, and underscores';
                  }
                  if (_usernameError != null) {
                    return _usernameError;
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Bio
              TextFormField(
                controller: _bioController,
                decoration: const InputDecoration(
                  labelText: 'Bio',
                  hintText: AppConstants.bioPlaceholder,
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit_note),
                  alignLabelWithHint: true,
                ),
                maxLines: 4,
                maxLength: AppConstants.maxBioLength,
                validator: (value) {
                  if (value != null && value.trim().length > AppConstants.maxBioLength) {
                    return 'Bio is too long';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Location
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'City, Country',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),

              const SizedBox(height: 16),

              // Website
              TextFormField(
                controller: _websiteController,
                decoration: const InputDecoration(
                  labelText: 'Website',
                  hintText: 'https://example.com',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.trim().isNotEmpty) {
                    if (!value.startsWith('http://') && !value.startsWith('https://')) {
                      return 'Website must start with http:// or https://';
                    }
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),

              // Privacy Setting
              Card(
                child: SwitchListTile(
                  title: const Text('Private Account'),
                  subtitle: const Text('Only followers can see your posts'),
                  value: _isPrivate,
                  onChanged: (value) {
                    setState(() {
                      _isPrivate = value;
                      _hasChanges = true;
                    });
                  },
                  secondary: const Icon(Icons.lock),
                ),
              ),

              const SizedBox(height: 24),

              // Additional Info
              Card(
                color: Colors.blue[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Profile Tips',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '• Choose a unique username that represents you\n'
                        '• Write a bio that tells others about yourself\n'
                        '• Add a profile photo to make your profile stand out',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blue[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Save Button at Bottom
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _hasChanges ? _saveProfile : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 32),
            ],
          ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}