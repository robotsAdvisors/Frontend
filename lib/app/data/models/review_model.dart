class ReviewModel {
  final String id;
  final String authorName;
  final String? authorAvatarUrl;
  final int rating;              // 1–5, 0 si anónima/oculta
  final String text;
  final DateTime createdAt;
  final String status;           // 'pending' | 'replied' | 'hidden' | 'in_review'
  final bool isAnonymous;
  final String? replyText;
  final DateTime? repliedAt;
  final String? referenceCode;   // e.g. "Code-8829-0009"
  final String? badge;           // e.g. "Perfecto"

  ReviewModel({
    required this.id,
    required this.authorName,
    this.authorAvatarUrl,
    required this.rating,
    required this.text,
    required this.createdAt,
    this.status = 'pending',
    this.isAnonymous = false,
    this.isHidden = false,
    this.replyText,
    this.repliedAt,
    this.referenceCode,
    this.badge,
  });

  final bool isHidden;   // BooleanField del backend (migración 0016)

  bool get isReplied   => status == 'replied' || (replyText?.isNotEmpty == true);
  bool get isInReview  => status == 'in_review';
  bool get isPending   => status == 'pending' && !isReplied;

  String get initials {
    if (isAnonymous) return '?';
    return authorName.trim().split(' ').where((w) => w.isNotEmpty)
        .take(2).map((w) => w[0].toUpperCase()).join();
  }

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userRaw = json['user'] ?? json['author'];
    final String name;
    final String? avatar;
    final bool anon = json['is_anonymous'] as bool? ?? false;

    if (anon) {
      name   = 'Usuario Anónimo';
      avatar = null;
    } else if (userRaw is Map) {
      final fn = (userRaw['first_name'] ?? '').toString().trim();
      final ln = (userRaw['last_name']  ?? '').toString().trim();
      final full = (userRaw['full_name'] ?? userRaw['name'] ?? '').toString().trim();
      name   = full.isNotEmpty ? full : [fn, ln].where((s) => s.isNotEmpty).join(' ');
      avatar = userRaw['avatar']?.toString() ?? userRaw['photo']?.toString();
    } else {
      name   = (json['author_name'] ?? json['user_name'] ?? 'Anónimo').toString();
      avatar = json['author_avatar']?.toString();
    }

    final replyRaw = json['reply'];
    final String? replyText;
    final DateTime? repliedAt;
    if (replyRaw is Map) {
      replyText  = replyRaw['text']?.toString();
      repliedAt  = DateTime.tryParse((replyRaw['created_at'] ?? '').toString());
    } else {
      replyText  = json['reply_text']?.toString();
      repliedAt  = DateTime.tryParse((json['replied_at'] ?? '').toString());
    }

    return ReviewModel(
      id:              (json['id'] ?? '').toString(),
      authorName:      name,
      authorAvatarUrl: avatar,
      rating:          json['rating'] is int ? json['rating'] as int
                       : int.tryParse('${json['rating'] ?? 0}') ?? 0,
      text:            (json['text'] ?? json['content'] ?? json['comment'] ?? '').toString(),
      createdAt:       DateTime.tryParse(
                           (json['created_at'] ?? json['date'] ?? '').toString()) ??
                       DateTime.now(),
      status:      (json['status'] ?? 'pending').toString(),
      isAnonymous: anon,
      isHidden:    json['is_hidden'] as bool? ?? false,
      replyText:   replyText?.isNotEmpty == true ? replyText : null,
      repliedAt:       repliedAt,
      referenceCode:   json['reference_code']?.toString(),
      badge:           json['badge']?.toString(),
    );
  }
}

class ReviewsStats {
  final double avgRating;
  final int totalReviews;
  final double positivePct;
  final double positiveChangePct;
  final int newReviewsCount;
  final int? newReviewsRanking;
  final int daysWithoutAccumulation;

  const ReviewsStats({
    this.avgRating = 0,
    this.totalReviews = 0,
    this.positivePct = 0,
    this.positiveChangePct = 0,
    this.newReviewsCount = 0,
    this.newReviewsRanking,
    this.daysWithoutAccumulation = 0,
  });

  factory ReviewsStats.fromJson(Map<String, dynamic> json) {
    return ReviewsStats(
      avgRating:                _d(json['avg_rating'] ?? json['average_rating']),
      totalReviews:             _i(json['total_reviews'] ?? json['total']),
      positivePct:              _d(json['positive_pct'] ?? json['positive_percent']),
      positiveChangePct:        _d(json['positive_change_pct'] ?? json['sentiment_change']),
      newReviewsCount:          _i(json['new_reviews_count'] ?? json['new_reviews']),
      newReviewsRanking:        json['ranking'] is int ? json['ranking'] as int : null,
      daysWithoutAccumulation:  _i(json['days_without_accumulation'] ?? json['days_inactive']),
    );
  }

  static int    _i(dynamic v) => v is int ? v : int.tryParse('${v ?? 0}') ?? 0;
  static double _d(dynamic v) => v is num ? v.toDouble() : double.tryParse('${v ?? 0}') ?? 0;
}
