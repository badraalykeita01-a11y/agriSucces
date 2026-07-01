/// Exception de base pour toutes les erreurs du module IA.
sealed class AiException implements Exception {
  const AiException(this.message, [this.cause]);

  /// Message d'erreur lisible par l'utilisateur ou les logs.
  final String message;

  /// Cause sous-jacente optionnelle (exception originale, stack trace, etc.).
  final Object? cause;

  @override
  String toString() {
    if (cause != null) {
      return '$runtimeType: $message (cause: $cause)';
    }
    return '$runtimeType: $message';
  }
}

/// Levée lorsque le fichier `.tflite` est introuvable ou illisible.
final class ModelNotFoundException extends AiException {
  const ModelNotFoundException(super.message, [super.cause]);
}

/// Levée lorsque le fichier `labels.txt` est introuvable ou vide.
final class LabelsNotFoundException extends AiException {
  const LabelsNotFoundException(super.message, [super.cause]);
}

/// Levée lorsque l'image fournie est invalide ou ne peut pas être décodée.
final class InvalidImageException extends AiException {
  const InvalidImageException(super.message, [super.cause]);
}

/// Levée lors d'une erreur d'inférence ou d'initialisation TensorFlow Lite.
final class TensorFlowException extends AiException {
  const TensorFlowException(super.message, [super.cause]);
}

/// Levée lors d'une erreur de lecture ou de parsing du JSON des maladies.
final class DiseaseDataException extends AiException {
  const DiseaseDataException(super.message, [super.cause]);
}
