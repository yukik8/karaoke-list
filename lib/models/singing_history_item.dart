class SingingHistoryItem {
  final String id;
  final double score;
  final String? memo;
  final DateTime sungAt;

  SingingHistoryItem({
    required this.id,
    required this.score,
    this.memo,
    required this.sungAt,
  });

  factory SingingHistoryItem.fromJson(Map<String, dynamic> json) {
    return SingingHistoryItem(
      id: json['id'],
      score: (json['score'] as num).toDouble(),
      memo: json['memo'],
      sungAt: DateTime.parse(json['sung_at']),
    );
  }
}
