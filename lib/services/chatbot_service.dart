import '../ai/model/disease_info.dart';
import '../repositories/disease_repository.dart';

class ChatbotService {
ChatbotService(this._diseaseRepository);

final DiseaseRepository _diseaseRepository;

Future<String> reply({
required String message,
DiseaseInfo? currentDisease,
}) async {
final question = _normalize(message);

if (question.isEmpty) {
  return 'Écrivez votre question afin que je puisse vous aider.';
}

if (_containsAny(question, [
  'bonjour',
  'salut',
  'bonsoir',
  'hello',
])) {
  return 'Bonjour ! Je peux vous aider à comprendre une maladie de plante, ses symptômes, les traitements et les moyens de prévention.';
}

if (_containsAny(question, [
  'merci',
  'thank',
])) {
  return 'Avec plaisir. Prenez soin de vos cultures et surveillez régulièrement les feuilles.';
}

final disease = currentDisease ?? await _findDisease(question);

if (disease == null) {
  return 'Je ne trouve pas encore cette maladie dans ma base de connaissances. Essayez de préciser la culture, par exemple : tomate, maïs, poivron ou pomme de terre.';
}

if (_containsAny(question, [
  'symptome',
  'symptômes',
  'signe',
  'signes',
  'reconnaitre',
  'reconnaître',
  'identifier',
])) {
  return _listResponse(
    title: 'Voici les symptômes possibles de ${disease.name} :',
    items: disease.symptoms,
    emptyMessage:
        'Les symptômes ne sont pas encore renseignés pour cette maladie.',
  );
}

if (_containsAny(question, [
  'cause',
  'causes',
  'pourquoi',
  'origine',
])) {
  return _listResponse(
    title: 'Les causes possibles de ${disease.name} sont :',
    items: disease.causes,
    emptyMessage:
        'Les causes ne sont pas encore renseignées pour cette maladie.',
  );
}

if (_containsAny(question, [
  'traitement',
  'traiter',
  'soigner',
  'solution',
  'que faire',
  'remede',
  'remède',
  'produit',
])) {
  final organic = disease.organicOptions;
  final chemical = disease.chemicalOptions;

  final lines = <String>[
    'Voici des options de traitement pour ${disease.name} :',
  ];

  if (disease.immediateActions.isNotEmpty) {
    lines.add('\nActions immédiates :');
    lines.addAll(
      disease.immediateActions.map((item) => '• $item'),
    );
  }

  if (organic.isNotEmpty) {
    lines.add('\nSolutions naturelles :');
    lines.addAll(organic.map((item) => '• $item'));
  }

  if (chemical.isNotEmpty) {
    lines.add('\nSolutions phytosanitaires :');
    lines.addAll(chemical.map((item) => '• $item'));
  }

  if (organic.isEmpty &&
      chemical.isEmpty &&
      disease.immediateActions.isEmpty) {
    return 'Aucun traitement n’est encore renseigné pour cette maladie.';
  }

  if (disease.needsReview) {
    lines.add(
      '\n⚠️ Ces conseils doivent être confirmés auprès d’un agent agricole ou d’un spécialiste local.',
    );
  }

  return lines.join('\n');
}

if (_containsAny(question, [
  'prevention',
  'prévention',
  'eviter',
  'éviter',
  'proteger',
  'protéger',
])) {
  return _listResponse(
    title: 'Pour prévenir ${disease.name} :',
    items: disease.prevention,
    emptyMessage:
        'Les conseils de prévention ne sont pas encore renseignés.',
  );
}

if (_containsAny(question, [
  'grave',
  'danger',
  'gravite',
  'gravité',
  'severite',
  'sévérité',
])) {
  return _severityResponse(disease);
}

if (_containsAny(question, [
  'aide',
  'specialiste',
  'spécialiste',
  'technicien',
  'agronome',
])) {
  return _listResponse(
    title: 'Demandez l’aide d’un spécialiste si :',
    items: disease.whenToSeekHelp,
    emptyMessage:
        'Consultez un agent agricole si les symptômes s’aggravent ou se propagent rapidement.',
  );
}

return _generalResponse(disease);

}

Future<DiseaseInfo?> _findDisease(String question) async {
final diseases = await _diseaseRepository.getAll();

for (final disease in diseases.values) {
  final name = _normalize(disease.name);
  final crop = _normalize(disease.crop);
  final key = _normalize(disease.diseaseKey.replaceAll('_', ' '));

  if (question.contains(name) ||
      question.contains(crop) ||
      question.contains(key)) {
    return disease;
  }
}

return null;

}

String _generalResponse(DiseaseInfo disease) {
final lines = <String>[
'${disease.name} concerne la culture : ${disease.crop}.',
];

if (disease.description.trim().isNotEmpty) {
  lines.add('\n${disease.description}');
}

lines.add('\nNiveau de gravité : ${_severityLabel(disease.severity)}.');

if (disease.immediateActions.isNotEmpty) {
  lines.add('\nPremières actions recommandées :');
  lines.addAll(
    disease.immediateActions.take(3).map((item) => '• $item'),
  );
}

lines.add(
  '\nVous pouvez me demander : symptômes, causes, traitement ou prévention.',
);

return lines.join('\n');

}

String _severityResponse(DiseaseInfo disease) {
final label = _severityLabel(disease.severity);

String advice;

switch (disease.severity.toLowerCase()) {
  case 'high':
    advice =
        'Agissez rapidement : isolez les plants atteints et demandez conseil à un technicien agricole si la maladie se propage.';
    break;
  case 'medium':
    advice =
        'Surveillez les plants et appliquez les mesures recommandées dès les premiers symptômes.';
    break;
  default:
    advice =
        'La situation est généralement contrôlable si vous surveillez régulièrement vos cultures.';
}

return 'Gravité de ${disease.name} : $label.\n\n$advice';

}

String _severityLabel(String severity) {
switch (severity.toLowerCase()) {
case 'high':
return 'élevée';
case 'medium':
return 'moyenne';
case 'low':
return 'faible';
default:
return 'non précisée';
}
}

String _listResponse({
required String title,
required List<String> items,
required String emptyMessage,
}) {
if (items.isEmpty) {
return emptyMessage;
}

return '$title\n\n${items.map((item) => '• $item').join('\n')}';

}

bool _containsAny(String text, List<String> words) {
return words.any((word) => text.contains(_normalize(word)));
}

String _normalize(String value) {
return value
.toLowerCase()
.trim()
.replaceAll('é', 'e')
.replaceAll('è', 'e')
.replaceAll('ê', 'e')
.replaceAll('à', 'a')
.replaceAll('â', 'a')
.replaceAll('î', 'i')
.replaceAll('ï', 'i')
.replaceAll('ô', 'o')
.replaceAll('ù', 'u')
.replaceAll('û', 'u')
.replaceAll('ç', 'c');
}
}
