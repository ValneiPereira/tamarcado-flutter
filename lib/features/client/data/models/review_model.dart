class ReviewModel {
  final String id;
  final String? clientId;
  final String? clientName;
  final int rating;
  final String? comment;
  final String? createdAt;

  const ReviewModel({
    required this.id,
    this.clientId,
    this.clientName,
    required this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      clientId: json['clientId'] as String?,
      clientName: json['clientName'] as String?,
      rating: json['rating'] as int,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'clientId': clientId,
        'clientName': clientName,
        'rating': rating,
        'comment': comment,
      };
}
