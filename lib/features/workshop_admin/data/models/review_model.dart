class ReviewModel {
  final String id;
  final String workshopId;
  final String userId;
  final String userName;
  final String? userPhotoUrl;
  final String appointmentId;
  final ReviewRating rating;
  final String comment;
  final String? response;
  final String? responseDate;
  final int helpfulCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  ReviewModel({
    required this.id,
    required this.workshopId,
    required this.userId,
    required this.userName,
    this.userPhotoUrl,
    required this.appointmentId,
    required this.rating,
    required this.comment,
    this.response,
    this.responseDate,
    required this.helpfulCount,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'],
      workshopId: json['workshopId'],
      userId: json['userId'],
      userName: json['userName'],
      userPhotoUrl: json['userPhotoUrl'],
      appointmentId: json['appointmentId'],
      rating: ReviewRating.fromJson(json['rating']),
      comment: json['comment'],
      response: json['response'],
      responseDate: json['responseDate'],
      helpfulCount: json['helpfulCount'] ?? 0,
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'workshopId': workshopId,
      'userId': userId,
      'userName': userName,
      'userPhotoUrl': userPhotoUrl,
      'appointmentId': appointmentId,
      'rating': rating.toJson(),
      'comment': comment,
      'response': response,
      'responseDate': responseDate,
      'helpfulCount': helpfulCount,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class ReviewRating {
  final int overall;
  final int quality;
  final int price;
  final int timeCompliance;
  final int customerService;

  ReviewRating({
    required this.overall,
    required this.quality,
    required this.price,
    required this.timeCompliance,
    required this.customerService,
  });

  factory ReviewRating.fromJson(Map<String, dynamic> json) {
    return ReviewRating(
      overall: json['overall'],
      quality: json['quality'],
      price: json['price'],
      timeCompliance: json['timeCompliance'],
      customerService: json['customerService'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall,
      'quality': quality,
      'price': price,
      'timeCompliance': timeCompliance,
      'customerService': customerService,
    };
  }

  double get average {
    return (overall + quality + price + timeCompliance + customerService) / 5.0;
  }
}

class PaginatedReviewsModel {
  final List<ReviewModel> reviews;
  final PaginationModel pagination;

  PaginatedReviewsModel({
    required this.reviews,
    required this.pagination,
  });

  factory PaginatedReviewsModel.fromJson(Map<String, dynamic> json) {
    return PaginatedReviewsModel(
      reviews: (json['reviews'] as List)
          .map((review) => ReviewModel.fromJson(review))
          .toList(),
      pagination: PaginationModel.fromJson(json['pagination']),
    );
  }
}

class PaginationModel {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;

  PaginationModel({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      currentPage: json['currentPage'],
      totalPages: json['totalPages'],
      totalItems: json['totalItems'],
      itemsPerPage: json['itemsPerPage'],
    );
  }
}

class ReviewStatisticsModel {
  final double averageOverall;
  final double averageQuality;
  final double averagePrice;
  final double averageTimeCompliance;
  final double averageCustomerService;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  ReviewStatisticsModel({
    required this.averageOverall,
    required this.averageQuality,
    required this.averagePrice,
    required this.averageTimeCompliance,
    required this.averageCustomerService,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory ReviewStatisticsModel.fromJson(Map<String, dynamic> json) {
    return ReviewStatisticsModel(
      averageOverall: (json['averageOverall'] ?? 0).toDouble(),
      averageQuality: (json['averageQuality'] ?? 0).toDouble(),
      averagePrice: (json['averagePrice'] ?? 0).toDouble(),
      averageTimeCompliance: (json['averageTimeCompliance'] ?? 0).toDouble(),
      averageCustomerService: (json['averageCustomerService'] ?? 0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      ratingDistribution: Map<int, int>.from(json['ratingDistribution'] ?? {}),
    );
  }
}
