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
    String? avatarUrl,
    int? coins,
    int? rankPoints,
    int? solvedCount,
    int? dailyStreak,
    int? reportsApproved,
    int? hintsUnlocked,
    int? profileViews,
    int? fastestSolveSeconds,
    String? firstSolveAt,
    bool? isAdmin,
    bool? publicProfile,
    bool? hideEmail,
    String? telegramChatId,
    bool? telegramNotifications,
    String? createdAt,
    String? updatedAt,
    int? notifyNewChallenges,
    int? notifyComments,
    int? notifyMentions,
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
    String? telegramFileId,
    int? pointsReward,
    int? solvedCount,
    String? status,
    bool? isCommunity,
    int? createdBy,
    int? commentsCount,
    bool? hasWalkthrough,
    String? createdAt,
    String? hint1,
    String? hint2,
    int? hint1Cost,
    int? hint2Cost,
    String? tags,
    String? solutionWalkthrough,
    bool? solvedByCurrentUser,
  }) = _CPChallenge;

  factory CPChallenge.fromJson(Map<String, dynamic> json) =>
      _$CPChallengeFromJson(json);
}

@freezed
class CPLeaderboardEntry with _$CPLeaderboardEntry {
  const factory CPLeaderboardEntry({
    required int rank,
    required int userId,
    required String username,
    int? rankPoints,
    int? coins,
    int? solvedCount,
    List<String>? badges,
    String? avatarUrl,
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
    int? pointsAwarded,
    int? newRankPoints,
    int? newCoins,
    int? newSolvedCount,
    List<String>? newBadges,
  }) = _CPFlagSubmitResponse;

  factory CPFlagSubmitResponse.fromJson(Map<String, dynamic> json) =>
      _$CPFlagSubmitResponseFromJson(json);
}

@freezed
class CPHintUnlockResponse with _$CPHintUnlockResponse {
  const factory CPHintUnlockResponse({
    required bool success,
    String? hint,
    int? cost,
    int? remainingCoins,
    String? message,
  }) = _CPHintUnlockResponse;

  factory CPHintUnlockResponse.fromJson(Map<String, dynamic> json) =>
      _$CPHintUnlockResponseFromJson(json);
}

@freezed
class CPIntelArticle with _$CPIntelArticle {
  const factory CPIntelArticle({
    required int id,
    required String title,
    required String category,
    String? summary,
    required String content,
    String? telegramFileId,
    int? authorId,
    String? authorUsername,
    String? createdAt,
    String? updatedAt,
    bool? isPublished,
  }) = _CPIntelArticle;

  factory CPIntelArticle.fromJson(Map<String, dynamic> json) =>
      _$CPIntelArticleFromJson(json);
}

@freezed
class CPComment with _$CPComment {
  const factory CPComment({
    required int id,
    required int challengeId,
    required int userId,
    required String username,
    String? avatarUrl,
    required String body,
    int? parentId,
    String? createdAt,
    String? updatedAt,
    List<CPComment>? replies,
  }) = _CPComment;

  factory CPComment.fromJson(Map<String, dynamic> json) =>
      _$CPCommentFromJson(json);
}

@freezed
class CPAuthResponse with _$CPAuthResponse {
  const factory CPAuthResponse({
    required String token,
    required CPUser user,
    String? refreshToken,
  }) = _CPAuthResponse;

  factory CPAuthResponse.fromJson(Map<String, dynamic> json) =>
      _$CPAuthResponseFromJson(json);
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
