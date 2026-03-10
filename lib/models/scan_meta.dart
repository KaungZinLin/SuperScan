class ScanMeta {
  final String name;
  final DateTime createdAt;

  ScanMeta({
    required this.name,
    required this.createdAt,
  });

  factory ScanMeta.fromJson(Map<String, dynamic> json) {
    return ScanMeta(
      name: json['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
    };
  }

  ScanMeta copyWith({
    String? name,
    DateTime? createdAt,
  }) {
    return ScanMeta(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}