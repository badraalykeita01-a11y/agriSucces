import '../ai/model/prediction.dart';

class DiagnosisHistoryItem {
  const DiagnosisHistoryItem({
    required this.id,
    required this.imagePath,
    required this.prediction,
    required this.createdAt,
  });

  final String id;
  final String imagePath;
  final Prediction prediction;
  final DateTime createdAt;

  bool get isUnknown => prediction.isUnknown;

  bool get isHealthy => prediction.isHealthy;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'imagePath': imagePath,
      'prediction': prediction.toJson(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory DiagnosisHistoryItem.fromJson(Map<String, dynamic> json) {
    return DiagnosisHistoryItem(
      id: json['id'] as String,
      imagePath: json['imagePath'] as String,
      prediction: Prediction.fromJson(
        Map<String, dynamic>.from(json['prediction'] as Map),
      ),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}