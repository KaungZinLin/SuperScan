class ScanMeta {
  final String name;
  final DateTime createdAt;
  final String driveFolderId;

  ScanMeta({
    required this.name,
    required this.createdAt,
    required this.driveFolderId,
  });

  factory ScanMeta.fromJson(Map<String, dynamic> json) {
    return ScanMeta(
      name: json['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        json['createdAt'] as int,
      ),
      driveFolderId: json['driveFolderId'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'driveFolderId': driveFolderId,
    };
  }

  ScanMeta copyWith({
    String? name,
    DateTime? createdAt,
    String? driveFolderId,
  }) {
    return ScanMeta(
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      driveFolderId: driveFolderId ?? this.driveFolderId,
    );
  }
}