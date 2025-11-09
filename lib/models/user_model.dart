import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel extends Equatable {
  final String id;
  final String email;
  final String username;
  final String displayName;
  final String? bio;
  final String? photoUrl;
  final String? coverPhotoUrl;
  final String? website;
  final String? location;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isVerified;
  final bool isPrivate;
  final bool isOnline;
  final DateTime? lastSeen;
  final int followersCount;
  final int followingCount;
  final int postsCount;
  final List<String> interests;
  final Map<String, dynamic>? settings;
  final Map<String, dynamic>? metadata;
  
  const UserModel({
    required this.id,
    required this.email,
    required this.username,
    required this.displayName,
    this.bio,
    this.photoUrl,
    this.coverPhotoUrl,
    this.website,
    this.location,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
    this.isVerified = false,
    this.isPrivate = false,
    this.isOnline = false,
    this.lastSeen,
    this.followersCount = 0,
    this.followingCount = 0,
    this.postsCount = 0,
    this.interests = const [],
    this.settings,
    this.metadata,
  });
  
  // Factory constructor for creating a new user
  factory UserModel.create({
    required String id,
    required String email,
    required String username,
    required String displayName,
  }) {
    final now = DateTime.now();
    return UserModel(
      id: id,
      email: email,
      username: username,
      displayName: displayName,
      createdAt: now,
      updatedAt: now,
    );
  }
  
  // JSON serialization
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
  
  // Firestore serialization
  factory UserModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return UserModel(
      id: documentId,
      email: data['email'] ?? '',
      username: data['username'] ?? '',
      displayName: data['displayName'] ?? '',
      bio: data['bio'],
      photoUrl: data['photoUrl'],
      coverPhotoUrl: data['coverPhotoUrl'],
      website: data['website'],
      location: data['location'],
      dateOfBirth: data['dateOfBirth'] != null 
          ? DateTime.parse(data['dateOfBirth']) 
          : null,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : DateTime.now(),
      isVerified: data['isVerified'] ?? false,
      isPrivate: data['isPrivate'] ?? false,
      isOnline: data['isOnline'] ?? false,
      lastSeen: data['lastSeen'] != null 
          ? DateTime.parse(data['lastSeen']) 
          : null,
      followersCount: data['followersCount'] ?? 0,
      followingCount: data['followingCount'] ?? 0,
      postsCount: data['postsCount'] ?? 0,
      interests: List<String>.from(data['interests'] ?? []),
      settings: data['settings'],
      metadata: data['metadata'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'username': username,
      'displayName': displayName,
      'bio': bio,
      'photoUrl': photoUrl,
      'coverPhotoUrl': coverPhotoUrl,
      'website': website,
      'location': location,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isVerified': isVerified,
      'isPrivate': isPrivate,
      'isOnline': isOnline,
      'lastSeen': lastSeen?.toIso8601String(),
      'followersCount': followersCount,
      'followingCount': followingCount,
      'postsCount': postsCount,
      'interests': interests,
      'settings': settings,
      'metadata': metadata,
    };
  }
  
  // CopyWith method for updating user
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? displayName,
    String? bio,
    String? photoUrl,
    String? coverPhotoUrl,
    String? website,
    String? location,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isVerified,
    bool? isPrivate,
    bool? isOnline,
    DateTime? lastSeen,
    int? followersCount,
    int? followingCount,
    int? postsCount,
    List<String>? interests,
    Map<String, dynamic>? settings,
    Map<String, dynamic>? metadata,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      bio: bio ?? this.bio,
      photoUrl: photoUrl ?? this.photoUrl,
      coverPhotoUrl: coverPhotoUrl ?? this.coverPhotoUrl,
      website: website ?? this.website,
      location: location ?? this.location,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isVerified: isVerified ?? this.isVerified,
      isPrivate: isPrivate ?? this.isPrivate,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
      followersCount: followersCount ?? this.followersCount,
      followingCount: followingCount ?? this.followingCount,
      postsCount: postsCount ?? this.postsCount,
      interests: interests ?? this.interests,
      settings: settings ?? this.settings,
      metadata: metadata ?? this.metadata,
    );
  }
  
  // Helper getters
  String get initials {
    final names = displayName.split(' ');
    if (names.length >= 2) {
      return '${names[0][0]}${names[1][0]}'.toUpperCase();
    }
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : '';
  }
  
  bool get hasProfilePhoto => photoUrl != null && photoUrl!.isNotEmpty;
  
  bool get hasCoverPhoto => coverPhotoUrl != null && coverPhotoUrl!.isNotEmpty;
  
  String get profileUrl => '/profile/$username';
  
  @override
  List<Object?> get props => [
    id,
    email,
    username,
    displayName,
    bio,
    photoUrl,
    coverPhotoUrl,
    website,
    location,
    dateOfBirth,
    createdAt,
    updatedAt,
    isVerified,
    isPrivate,
    isOnline,
    lastSeen,
    followersCount,
    followingCount,
    postsCount,
    interests,
    settings,
    metadata,
  ];
}
