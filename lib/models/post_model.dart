import 'package:equatable/equatable.dart';
import 'package:json_annotation/json_annotation.dart';
import 'user_model.dart';

part 'post_model.g.dart';

enum PostType { text, image, video, link, poll, ai_generated }
enum PostVisibility { public, followers, private }

@JsonSerializable()
class PostModel extends Equatable {
  final String id;
  final String userId;
  final String content;
  final PostType type;
  final PostVisibility visibility;
  final List<String> imageUrls;
  final String? videoUrl;
  final String? linkUrl;
  final Map<String, dynamic>? linkPreview;
  final PollData? poll;
  final List<String> hashtags;
  final List<String> mentions;
  final int likesCount;
  final int commentsCount;
  final int sharesCount;
  final int viewsCount;
  final bool isEdited;
  final DateTime? editedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? replyToId;
  final String? repostOfId;
  final bool isDeleted;
  final bool isPinned;
  final bool isAIGenerated;
  final Map<String, dynamic>? aiMetadata;
  final UserModel? author;
  final Map<String, dynamic>? metadata;
  
  const PostModel({
    required this.id,
    required this.userId,
    required this.content,
    this.type = PostType.text,
    this.visibility = PostVisibility.public,
    this.imageUrls = const [],
    this.videoUrl,
    this.linkUrl,
    this.linkPreview,
    this.poll,
    this.hashtags = const [],
    this.mentions = const [],
    this.likesCount = 0,
    this.commentsCount = 0,
    this.sharesCount = 0,
    this.viewsCount = 0,
    this.isEdited = false,
    this.editedAt,
    required this.createdAt,
    required this.updatedAt,
    this.replyToId,
    this.repostOfId,
    this.isDeleted = false,
    this.isPinned = false,
    this.isAIGenerated = false,
    this.aiMetadata,
    this.author,
    this.metadata,
  });
  
  // Factory constructor for creating a new post
  factory PostModel.create({
    required String id,
    required String userId,
    required String content,
    PostType type = PostType.text,
    List<String> imageUrls = const [],
    String? videoUrl,
    bool isAIGenerated = false,
  }) {
    final now = DateTime.now();
    
    // Extract hashtags and mentions from content
    final hashtags = _extractHashtags(content);
    final mentions = _extractMentions(content);
    
    return PostModel(
      id: id,
      userId: userId,
      content: content,
      type: type,
      imageUrls: imageUrls,
      videoUrl: videoUrl,
      hashtags: hashtags,
      mentions: mentions,
      createdAt: now,
      updatedAt: now,
      isAIGenerated: isAIGenerated,
    );
  }
  
  // JSON serialization
  factory PostModel.fromJson(Map<String, dynamic> json) => _$PostModelFromJson(json);
  Map<String, dynamic> toJson() => _$PostModelToJson(this);
  
  // Firestore serialization
  factory PostModel.fromFirestore(Map<String, dynamic> data, String documentId) {
    return PostModel(
      id: documentId,
      userId: data['userId'] ?? '',
      content: data['content'] ?? '',
      type: PostType.values[data['type'] ?? 0],
      visibility: PostVisibility.values[data['visibility'] ?? 0],
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      videoUrl: data['videoUrl'],
      linkUrl: data['linkUrl'],
      linkPreview: data['linkPreview'],
      poll: data['poll'] != null ? PollData.fromMap(data['poll']) : null,
      hashtags: List<String>.from(data['hashtags'] ?? []),
      mentions: List<String>.from(data['mentions'] ?? []),
      likesCount: data['likesCount'] ?? 0,
      commentsCount: data['commentsCount'] ?? 0,
      sharesCount: data['sharesCount'] ?? 0,
      viewsCount: data['viewsCount'] ?? 0,
      isEdited: data['isEdited'] ?? false,
      editedAt: data['editedAt'] != null 
          ? DateTime.parse(data['editedAt']) 
          : null,
      createdAt: data['createdAt'] != null 
          ? DateTime.parse(data['createdAt']) 
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null 
          ? DateTime.parse(data['updatedAt']) 
          : DateTime.now(),
      replyToId: data['replyToId'],
      repostOfId: data['repostOfId'],
      isDeleted: data['isDeleted'] ?? false,
      isPinned: data['isPinned'] ?? false,
      isAIGenerated: data['isAIGenerated'] ?? false,
      aiMetadata: data['aiMetadata'],
      metadata: data['metadata'],
    );
  }
  
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'content': content,
      'type': type.index,
      'visibility': visibility.index,
      'imageUrls': imageUrls,
      'videoUrl': videoUrl,
      'linkUrl': linkUrl,
      'linkPreview': linkPreview,
      'poll': poll?.toMap(),
      'hashtags': hashtags,
      'mentions': mentions,
      'likesCount': likesCount,
      'commentsCount': commentsCount,
      'sharesCount': sharesCount,
      'viewsCount': viewsCount,
      'isEdited': isEdited,
      'editedAt': editedAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'replyToId': replyToId,
      'repostOfId': repostOfId,
      'isDeleted': isDeleted,
      'isPinned': isPinned,
      'isAIGenerated': isAIGenerated,
      'aiMetadata': aiMetadata,
      'metadata': metadata,
    };
  }
  
  // CopyWith method
  PostModel copyWith({
    String? id,
    String? userId,
    String? content,
    PostType? type,
    PostVisibility? visibility,
    List<String>? imageUrls,
    String? videoUrl,
    String? linkUrl,
    Map<String, dynamic>? linkPreview,
    PollData? poll,
    List<String>? hashtags,
    List<String>? mentions,
    int? likesCount,
    int? commentsCount,
    int? sharesCount,
    int? viewsCount,
    bool? isEdited,
    DateTime? editedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? replyToId,
    String? repostOfId,
    bool? isDeleted,
    bool? isPinned,
    bool? isAIGenerated,
    Map<String, dynamic>? aiMetadata,
    UserModel? author,
    Map<String, dynamic>? metadata,
  }) {
    return PostModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      content: content ?? this.content,
      type: type ?? this.type,
      visibility: visibility ?? this.visibility,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrl: videoUrl ?? this.videoUrl,
      linkUrl: linkUrl ?? this.linkUrl,
      linkPreview: linkPreview ?? this.linkPreview,
      poll: poll ?? this.poll,
      hashtags: hashtags ?? this.hashtags,
      mentions: mentions ?? this.mentions,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount: sharesCount ?? this.sharesCount,
      viewsCount: viewsCount ?? this.viewsCount,
      isEdited: isEdited ?? this.isEdited,
      editedAt: editedAt ?? this.editedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      replyToId: replyToId ?? this.replyToId,
      repostOfId: repostOfId ?? this.repostOfId,
      isDeleted: isDeleted ?? this.isDeleted,
      isPinned: isPinned ?? this.isPinned,
      isAIGenerated: isAIGenerated ?? this.isAIGenerated,
      aiMetadata: aiMetadata ?? this.aiMetadata,
      author: author ?? this.author,
      metadata: metadata ?? this.metadata,
    );
  }
  
  // Helper methods
  static List<String> _extractHashtags(String content) {
    final regex = RegExp(r'#[a-zA-Z0-9_]+');
    return regex.allMatches(content).map((match) => match.group(0)!).toList();
  }
  
  static List<String> _extractMentions(String content) {
    final regex = RegExp(r'@[a-zA-Z0-9_]+');
    return regex.allMatches(content).map((match) => match.group(0)!).toList();
  }
  
  // Helper getters
  bool get hasImages => imageUrls.isNotEmpty;
  bool get hasVideo => videoUrl != null && videoUrl!.isNotEmpty;
  bool get hasMedia => hasImages || hasVideo;
  bool get isReply => replyToId != null;
  bool get isRepost => repostOfId != null;
  bool get hasPoll => poll != null;
  
  String get shareUrl => '/post/$id';
  
  String get formattedLikes {
    if (likesCount >= 1000000) {
      return '${(likesCount / 1000000).toStringAsFixed(1)}M';
    } else if (likesCount >= 1000) {
      return '${(likesCount / 1000).toStringAsFixed(1)}K';
    }
    return likesCount.toString();
  }
  
  @override
  List<Object?> get props => [
    id,
    userId,
    content,
    type,
    visibility,
    imageUrls,
    videoUrl,
    linkUrl,
    linkPreview,
    poll,
    hashtags,
    mentions,
    likesCount,
    commentsCount,
    sharesCount,
    viewsCount,
    isEdited,
    editedAt,
    createdAt,
    updatedAt,
    replyToId,
    repostOfId,
    isDeleted,
    isPinned,
    isAIGenerated,
    aiMetadata,
    author,
    metadata,
  ];
}

// Poll data model
@JsonSerializable()
class PollData extends Equatable {
  final String question;
  final List<PollOption> options;
  final DateTime endsAt;
  final bool allowMultipleAnswers;
  final int totalVotes;
  
  const PollData({
    required this.question,
    required this.options,
    required this.endsAt,
    this.allowMultipleAnswers = false,
    this.totalVotes = 0,
  });
  
  // JSON serialization
  factory PollData.fromJson(Map<String, dynamic> json) => _$PollDataFromJson(json);
  Map<String, dynamic> toJson() => _$PollDataToJson(this);

  factory PollData.fromMap(Map<String, dynamic> map) {
    return PollData(
      question: map['question'],
      options: (map['options'] as List)
          .map((o) => PollOption.fromMap(o))
          .toList(),
      endsAt: DateTime.parse(map['endsAt']),
      allowMultipleAnswers: map['allowMultipleAnswers'] ?? false,
      totalVotes: map['totalVotes'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'question': question,
      'options': options.map((o) => o.toMap()).toList(),
      'endsAt': endsAt.toIso8601String(),
      'allowMultipleAnswers': allowMultipleAnswers,
      'totalVotes': totalVotes,
    };
  }
  
  @override
  List<Object?> get props => [
    question,
    options,
    endsAt,
    allowMultipleAnswers,
    totalVotes,
  ];
}

// Poll option model
@JsonSerializable()
class PollOption extends Equatable {
  final String id;
  final String text;
  final int votes;
  final List<String> voterIds;
  
  const PollOption({
    required this.id,
    required this.text,
    this.votes = 0,
    this.voterIds = const [],
  });
  
  // JSON serialization
  factory PollOption.fromJson(Map<String, dynamic> json) => _$PollOptionFromJson(json);
  Map<String, dynamic> toJson() => _$PollOptionToJson(this);

  factory PollOption.fromMap(Map<String, dynamic> map) {
    return PollOption(
      id: map['id'],
      text: map['text'],
      votes: map['votes'] ?? 0,
      voterIds: List<String>.from(map['voterIds'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'votes': votes,
      'voterIds': voterIds,
    };
  }
  
  // Note: This calculates percentage relative to this option's votes only.
  // To calculate percentage of total votes, you need to pass totalVotes from parent PollData
  double getPercentage(int totalVotes) {
    if (totalVotes == 0) return 0.0;
    return (votes / totalVotes) * 100;
  }
  
  @override
  List<Object?> get props => [id, text, votes, voterIds];
}
