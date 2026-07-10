import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/disease_repository.dart';
import '../services/chatbot_service.dart';

final diseaseRepositoryProvider = Provider<DiseaseRepository>((ref) {
return DiseaseRepository();
});

final chatbotServiceProvider = Provider<ChatbotService>((ref) {
final diseaseRepository = ref.watch(diseaseRepositoryProvider);

return ChatbotService(diseaseRepository);
});
