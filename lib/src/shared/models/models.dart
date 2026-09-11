// CipherPoint Models
// Matches backend API responses exactly

import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../core/theme/cipherpoint_theme.dart';

part 'models.freezed.dart';
part 'models.g.dart';

@freezed
class CPUser with _$CPUser {
  const factory CPUser({
    required int id,
    required String username,
    required String email,
    String? bio,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    int? coins,
    @JsonKey(name: 'rank_points') int? rankPoints,
    @JsonKey(name: 'solved_count') int? solvedCount,
    @JsonKey(name: 'daily_streak') int? dailyStreak,
    @JsonKey(name: 'reports_approved') int? reportsApproved,
    @JsonKey(name: 'hints_unlocked') int? hintsUnlocked,
    @JsonKey(name: 'profile_views') int? profileViews,
    @JsonKey(name: 'fastest_solve_seconds') int? fastestSolveSeconds,
    @JsonKey(name: 'first_solve_at') String? firstSolveAt,
    @JsonKey(name: 'is_admin') bool? isAdmin,
    @JsonKey(name: 'public_profile') bool? publicProfile,
    @JsonKey(name: 'hide_email') bool? hideEmail,
    @JsonKey(name: 'telegram_chat_id') String? telegramChatId,
    @JsonKey(name: 'telegram_notifications') bool? telegramNotifications,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'notify_new_challenges') int? notifyNewChallenges,
    @JsonKey(name: 'notify_comments') int? notifyComments,
    @JsonKey(name: 'notify_mentions') int? notifyMentions,
  }) = _CPUser;

  factory CPUser.fromJson(Map<String, dynamic> json) => _$CPUserFromJson(json);
}

@freezed
class CPChallenge with _$CPChallenge {
  const factory CPChallenge({
    required int id,
    required String title,
    required String category,
    required String difficulty,
    required String description,
    @JsonKey(name: 'telegram_file_id') String? telegramFileId,
    @JsonKey(name: 'points_reward') int? pointsReward,
    @JsonKey(name: 'solved_count') int? solvedCount,
    String? status,
    @JsonKey(name: 'is_community') bool? isCommunity,
    @JsonKey(name: 'created_by') int? createdBy,
    @JsonKey(name: 'comments_count') int? commentsCount,
    @JsonKey(name: 'has_walkthrough') bool? hasWalkthrough,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'hint_1') String? hint1,
    @JsonKey(name: 'hint_2') String? hint2,
    @JsonKey(name: 'hint_1_cost') int? hint1Cost,
    @JsonKey(name: 'hint_2_cost') int? hint2Cost,
    String? tags,
    @JsonKey(name: 'solution_walkthrough') String? solutionWalkthrough,
    @JsonKey(name: 'solved_by_current_user') bool? solvedByCurrentUser,
  }) = _CPChallenge;

  factory CPChallenge.fromJson(Map<String, dynamic> json) =>
      _$CPChallengeFromJson(json);
}

@freezed
class CPLeaderboardEntry with _$CPLeaderboardEntry {
  const factory CPLeaderboardEntry({
    required int rank,
    @JsonKey(name: 'user_id') required int userId,
    required String username,
    @JsonKey(name: 'rank_points') int? rankPoints,
    int? coins,
    @JsonKey(name: 'solved_count') int? solvedCount,
    List<String>? badges,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'is_admin') bool? isAdmin,
    bool? isCurrentUser,
  }) = _CPLeaderboardEntry;

  factory CPLeaderboardEntry.fromJson(Map<String, dynamic> json) =>
      _$CPLeaderboardEntryFromJson(json);
}

@freezed
class CPLeaderboardResponse with _$CPLeaderboardResponse {
  const factory CPLeaderboardResponse({
    required List<CPLeaderboardEntry> users,
    CPLeaderboardEntry? currentUser,
  }) = _CPLeaderboardResponse;

  factory CPLeaderboardResponse.fromJson(Map<String, dynamic> json) =>
      _$CPLeaderboardResponseFromJson(json);
}

@freezed
class CPFlagSubmitResponse with _$CPFlagSubmitResponse {
  const factory CPFlagSubmitResponse({
    required bool success,
    required String message,
    @JsonKey(name: 'coins_earned') int? pointsAwarded,
    @JsonKey(name: 'rank_points') int? newRankPoints,
    @JsonKey(name: 'total_coins') int? newCoins,
    @JsonKey(name: 'solved_count') int? newSolvedCount,
    @JsonKey(name: 'new_badges') List<String>? newBadges,
  }) = _CPFlagSubmitResponse;

  factory CPFlagSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$CPFlagSubmitResponseFromJson(json);
}

@freezed
class CPHintUnlockResponse with _$CPHintUnlockResponse {
  const CPHintUnlockResponse._();
  const factory CPHintUnlockResponse({
    // Backend returns hint_text, not hint
    @JsonKey(name: 'hint_text') String? hint,
    int? cost,
    @JsonKey(name: 'remaining_coins') int? remainingCoins,
    String? message,
    @JsonKey(name: 'hint_number') int? hintNumber,
  }) = _CPHintUnlockResponse;

  // success field doesn't exist in backend response — derive it from hint presence
  bool get success => hint != null;

  factory CPHintUnlockResponse.fromJson(Map<String, dynamic> json) =>
      _$CPHintUnlockResponseFromJson(json);
}

@freezed
class CPIntelArticle with _$CPIntelArticle {
  const factory CPIntelArticle({
    required int id,
    required String title,
    required String category,
    required String content,
    String? summary,
    @JsonKey(name: 'telegram_file_id') String? telegramFileId,
    @JsonKey(name: 'author_id') int? authorId,
    @JsonKey(name: 'author_username') String? authorUsername,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'is_published') bool? isPublished,
  }) = _CPIntelArticle;

  factory CPIntelArticle.fromJson(Map<String, dynamic> json) =>
      _$CPIntelArticleFromJson(json);
}

@freezed
class CPComment with _$CPComment {
  const factory CPComment({
    required int id,
    @JsonKey(name: 'challenge_id') required int challengeId,
    @JsonKey(name: 'user_id') required int userId,
    required String username,
    required String body,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'parent_id') int? parentId,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    List<CPComment>? replies,
  }) = _CPComment;

  factory CPComment.fromJson(Map<String, dynamic> json) =>
      _$CPCommentFromJson(json);
}

// CPAuthResponse is NOT a freezed class because the backend returns
// user fields flat (not nested under a 'user' key).
class CPAuthResponse {
  final String token;
  final String? refreshToken;
  final CPUser user;

  const CPAuthResponse({
    required this.token,
    required this.user,
    this.refreshToken,
  });

  factory CPAuthResponse.fromJson(Map<String, dynamic> json) {
    return CPAuthResponse(
      token: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      // User fields are returned flat in the same response object
      user: CPUser.fromJson(json),
    );
  }
}

@freezed
class CPNotification with _$CPNotification {
  const factory CPNotification({
    required int id,
    required String type,
    required String title,
    required String body,
    bool? read,
    String? createdAt,
    Map<String, dynamic>? data,
  }) = _CPNotification;

  factory CPNotification.fromJson(Map<String, dynamic> json) =>
      _$CPNotificationFromJson(json);
}

@freezed
class CPMedia with _$CPMedia {
  const factory CPMedia({
    required String id,
    required String fileId,
    required String type,
    String? url,
    String? thumbnailUrl,
    int? width,
    int? height,
    int? size,
    String? createdAt,
  }) = _CPMedia;

  factory CPMedia.fromJson(Map<String, dynamic> json) =>
      _$CPMediaFromJson(json);
}

@freezed
class CPStats with _$CPStats {
  const factory CPStats({
    required int totalUsers,
    required int totalChallenges,
    required int totalSolves,
    required int totalReports,
    required int flaggedUsers,
  }) = _CPStats;

  factory CPStats.fromJson(Map<String, dynamic> json) =>
      _$CPStatsFromJson(json);
}

// Category constants matching website
class CPCategories {
  static const List<String> challengeCategories = [
    'Web',
    'Crypto',
    'Forensics',
    'Reverse Engineering',
    'PWN',
    'OSINT',
    'Misc',
    'Networking',
    'Linux',
    'Bug Bounty',
  ];

  static const List<String> intelCategories = [
    'Networking',
    'Linux',
    'OSINT',
    'Forensics',
    'Bug Bounty',
    'Web',
    'Reverse Engineering',
  ];

  static const Map<String, Color> categoryColors = {
    'Web': Color(0xFF5BB3FF),
    'Crypto': Color(0xFFB7A5FF),
    'Forensics': Color(0xFF6DE0D0),
    'Reverse Engineering': Color(0xFFF3C37A),
    'PWN': Color(0xFFFF756F),
    'OSINT': Color(0xFF6CE3A6),
    'Misc': Color(0xFFA5ADBA),
    'Networking': Color(0xFF5BB3FF),
    'Linux': Color(0xFFF6D37D),
    'Bug Bounty': Color(0xFFFF756F),
  };
}

extension CPChallengeX on CPChallenge {
  Color get categoryColor =>
      CPCategories.categoryColors[category] ?? CPColors.muted;

  String get difficultyLabel {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return 'Easy';
      case 'medium':
        return 'Medium';
      case 'hard':
        return 'Hard';
      default:
        return difficulty;
    }
  }

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return CPColors.success;
      case 'medium':
        return CPColors.amber;
      case 'hard':
        return CPColors.danger;
      default:
        return CPColors.muted;
    }
  }

  String get categoryPrefix => 'lab/$category';
}

extension CPIntelArticleX on CPIntelArticle {
  String get categoryPrefix => 'lab/$category';
}
