import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class AIService {
  // Replace with your actual AI API endpoint
  static const String baseUrl = 'https://your-ai-api.com/v1';
  
  // Add your API key or authentication token here
  static const String apiKey = 'YOUR_API_KEY';
  
  // Headers for API requests
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $apiKey',
  };
  
  /// Generate content based on a prompt
  /// Used for helping users create posts
  Future<String?> generateContent({
    required String prompt,
    int maxLength = 280,
    double temperature = 0.7,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/generate'),
        headers: headers,
        body: jsonEncode({
          'prompt': prompt,
          'max_length': maxLength,
          'temperature': temperature,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['generated_text'];
      } else {
        debugPrint('AI Generate Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Generate Exception: $e');
      return null;
    }
  }
  
  /// Improve or enhance user's post content
  Future<String?> improvePost({
    required String content,
    String style = 'professional',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/improve'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          'style': style,
          'platform': 'social_media',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['improved_content'];
      } else {
        debugPrint('AI Improve Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Improve Exception: $e');
      return null;
    }
  }
  
  /// Moderate content for policy compliance
  Future<ModerationResult> moderateContent({
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/moderate'),
        headers: headers,
        body: jsonEncode({
          'content': content,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ModerationResult.fromJson(data);
      } else {
        debugPrint('AI Moderation Error: ${response.body}');
        return ModerationResult(isAppropriate: true, confidence: 0.0);
      }
    } catch (e) {
      debugPrint('AI Moderation Exception: $e');
      return ModerationResult(isAppropriate: true, confidence: 0.0);
    }
  }
  
  /// Suggest relevant hashtags for a post
  Future<List<String>> suggestHashtags({
    required String content,
    int count = 5,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/hashtags'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          'count': count,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return List<String>.from(data['hashtags'] ?? []);
      } else {
        debugPrint('AI Hashtags Error: ${response.body}');
        return [];
      }
    } catch (e) {
      debugPrint('AI Hashtags Exception: $e');
      return [];
    }
  }
  
  /// Analyze sentiment of content
  Future<SentimentAnalysis?> analyzeSentiment({
    required String content,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/sentiment'),
        headers: headers,
        body: jsonEncode({
          'content': content,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return SentimentAnalysis.fromJson(data);
      } else {
        debugPrint('AI Sentiment Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Sentiment Exception: $e');
      return null;
    }
  }
  
  /// Generate a response to a comment
  Future<String?> generateReply({
    required String originalPost,
    required String comment,
    String tone = 'friendly',
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/reply'),
        headers: headers,
        body: jsonEncode({
          'original_post': originalPost,
          'comment': comment,
          'tone': tone,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['reply'];
      } else {
        debugPrint('AI Reply Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Reply Exception: $e');
      return null;
    }
  }
  
  /// Summarize long content
  Future<String?> summarizeContent({
    required String content,
    int maxLength = 100,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/summarize'),
        headers: headers,
        body: jsonEncode({
          'content': content,
          'max_length': maxLength,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['summary'];
      } else {
        debugPrint('AI Summarize Error: ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('AI Summarize Exception: $e');
      return null;
    }
  }
}

/// Model for content moderation results
class ModerationResult {
  final bool isAppropriate;
  final double confidence;
  final List<String> flaggedCategories;
  final String? reason;
  
  ModerationResult({
    required this.isAppropriate,
    required this.confidence,
    this.flaggedCategories = const [],
    this.reason,
  });
  
  factory ModerationResult.fromJson(Map<String, dynamic> json) {
    return ModerationResult(
      isAppropriate: json['is_appropriate'] ?? true,
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      flaggedCategories: List<String>.from(json['flagged_categories'] ?? []),
      reason: json['reason'],
    );
  }
}

/// Model for sentiment analysis results
class SentimentAnalysis {
  final String sentiment; // positive, negative, neutral
  final double confidence;
  final Map<String, double> scores;
  
  SentimentAnalysis({
    required this.sentiment,
    required this.confidence,
    required this.scores,
  });
  
  factory SentimentAnalysis.fromJson(Map<String, dynamic> json) {
    return SentimentAnalysis(
      sentiment: json['sentiment'] ?? 'neutral',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      scores: Map<String, double>.from(json['scores'] ?? {}),
    );
  }
}

// Example usage in a widget:
/*
class AIPostCreator extends StatefulWidget {
  @override
  _AIPostCreatorState createState() => _AIPostCreatorState();
}

class _AIPostCreatorState extends State<AIPostCreator> {
  final AIService _aiService = AIService();
  final TextEditingController _controller = TextEditingController();
  
  Future<void> _generatePost() async {
    final prompt = _controller.text;
    final generatedContent = await _aiService.generateContent(
      prompt: prompt,
      maxLength: 280,
    );
    
    if (generatedContent != null) {
      setState(() {
        _controller.text = generatedContent;
      });
    }
  }
  
  Future<void> _improvePost() async {
    final content = _controller.text;
    final improvedContent = await _aiService.improvePost(
      content: content,
      style: 'engaging',
    );
    
    if (improvedContent != null) {
      setState(() {
        _controller.text = improvedContent;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    // Your UI implementation here
    return Container();
  }
}
*/
