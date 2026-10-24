class Review {
  final String name;
  final String text;
  final int rating;
  final String date;

  const Review({
    required this.name,
    required this.text,
    required this.rating,
    required this.date,
  });

  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      name: json['name'] as String? ?? 'Patient',
      text: json['text'] as String? ?? '',
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'text': text,
      'rating': rating,
      'date': date,
    };
  }
}
