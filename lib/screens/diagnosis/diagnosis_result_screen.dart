import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../ai/model/disease_info.dart';
import '../../../ai/model/prediction.dart';
import '../../../ai/providers/ai_providers.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/history_provider.dart';

final diseaseInfoProvider =
    FutureProvider.family<DiseaseInfo, String>((ref, diseaseKey) async {
  return ref.read(diseaseRepositoryProvider).getByKey(diseaseKey);
});

class DiagnosisResultScreen extends ConsumerWidget {
  const DiagnosisResultScreen({
    super.key,
    required this.prediction,
    required this.imageFile,
  });

  final Prediction prediction;
  final File imageFile;

  String get _confidenceText =>
      '${(prediction.confidence * 100).toStringAsFixed(1)} %';

  Color _confidenceColor() {
    if (prediction.confidence >= 0.85) return Colors.green;
    if (prediction.confidence >= 0.70) return Colors.orange;
    return Colors.red;
  }

  Color _severityColor(String severity) {
    return switch (severity.toLowerCase()) {
      'high' => Colors.red,
      'medium' => Colors.orange,
      'low' => Colors.green,
      _ => Colors.grey,
    };
  }

  String _severityLabel(String severity) {
    return switch (severity.toLowerCase()) {
      'high' => 'Élevée',
      'medium' => 'Modérée',
      'low' => 'Faible',
      _ => 'Non précisée',
    };
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!prediction.isReliable) {
      return _UnknownResultScreen(
        prediction: prediction,
        imageFile: imageFile,
      );
    }

    final diseaseInfoAsync = ref.watch(
      diseaseInfoProvider(prediction.diseaseKey),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du diagnostic'),
        centerTitle: true,
      ),
      body: diseaseInfoAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _DataErrorScreen(
          prediction: prediction,
          imageFile: imageFile,
          error: error.toString(),
        ),
        data: (info) => SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
            children: [
              _ImagePreview(imageFile: imageFile),
              const SizedBox(height: 22),
              Text(
                'Diagnostic terminé',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkGreen,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Résultat proposé par l’intelligence artificielle.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 22),
              _DiagnosisHeader(
                prediction: prediction,
                info: info,
                severityColor: _severityColor(info.severity),
                severityLabel: _severityLabel(info.severity),
              ),
              const SizedBox(height: 16),
              _ConfidenceCard(
                confidenceText: _confidenceText,
                color: _confidenceColor(),
              ),
              const SizedBox(height: 18),
              if (info.description.isNotEmpty)
                _InfoCard(
                  icon: Icons.description_outlined,
                  title: 'Description',
                  items: [info.description],
                ),
              if (info.causes.isNotEmpty)
                _InfoCard(
                  icon: Icons.help_outline,
                  title: 'Causes possibles',
                  items: info.causes,
                ),
              _InfoCard(
                icon: Icons.visibility_outlined,
                title: 'Symptômes à observer',
                items: info.symptoms,
              ),
              _InfoCard(
                icon: Icons.flash_on_outlined,
                title: 'Actions immédiates',
                items: info.immediateActions,
              ),
              _InfoCard(
                icon: Icons.eco_outlined,
                title: 'Options naturelles',
                items: info.organicOptions,
              ),
              _InfoCard(
                icon: Icons.science_outlined,
                title: 'Options avec produit homologué',
                items: info.chemicalOptions,
                color: Colors.orange.withValues(alpha: 0.10),
              ),
              _InfoCard(
                icon: Icons.shield_outlined,
                title: 'Prévention',
                items: info.prevention,
              ),
              _InfoCard(
                icon: Icons.support_agent_outlined,
                title: 'Quand demander de l’aide',
                items: info.whenToSeekHelp,
                color: Colors.red.withValues(alpha: 0.08),
              ),
              if (info.needsReview)
                Card(
                  elevation: 0,
                  color: Colors.amber.withValues(alpha: 0.12),
                  child: const Padding(
                    padding: EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Ces conseils sont fournis à titre indicatif. '
                            'Avant tout traitement, vérifiez l’état réel de la plante '
                            'et demandez conseil à un technicien agricole si nécessaire.',
                            style: TextStyle(height: 1.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 26),
              SizedBox(
                height: 54,
                child: FilledButton.icon(
                  onPressed: () => context.go(AppRoutes.diagnosis),
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Faire un nouveau diagnostic'),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                    onPressed: () {
                      context.push(
                        AppRoutes.chatbot,
                        extra: info,
                      );
                    },
                    icon: const Icon(Icons.chat_outlined),
                    label: const Text('Demander conseil au chatbot'),
                  ),
              const SizedBox(height: 12),
              SizedBox(
                height: 54,
                child: OutlinedButton.icon(
                  onPressed: () => context.go(AppRoutes.home),
                  icon: const Icon(Icons.home_outlined),
                  label: const Text('Retour à l’accueil'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ImagePreview extends StatelessWidget {
  const _ImagePreview({required this.imageFile});

  final File imageFile;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AspectRatio(
        aspectRatio: 4 / 3,
        child: Image.file(
          imageFile,
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _DiagnosisHeader extends StatelessWidget {
  const _DiagnosisHeader({
    required this.prediction,
    required this.info,
    required this.severityColor,
    required this.severityLabel,
  });

  final Prediction prediction;
  final DiseaseInfo info;
  final Color severityColor;
  final String severityLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primaryGreen.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.eco_outlined,
              size: 42,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            Text(
              prediction.crop,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              info.name,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Chip(
              label: Text('Gravité : $severityLabel'),
              avatar: Icon(
                Icons.warning_amber_rounded,
                color: severityColor,
              ),
              side: BorderSide.none,
              backgroundColor: severityColor.withValues(alpha: 0.12),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  const _ConfidenceCard({
    required this.confidenceText,
    required this.color,
  });

  final String confidenceText;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(
                Icons.analytics_outlined,
                color: color,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Niveau de confiance',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    confidenceText,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.items,
    this.color,
  });

  final IconData icon;
  final String title;
  final List<String> items;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Card(
        elevation: 0,
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, color: AppColors.primaryGreen),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('•  '),
                      Expanded(
                        child: Text(
                          item,
                          style: const TextStyle(height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnknownResultScreen extends StatelessWidget {
  const _UnknownResultScreen({
    required this.prediction,
    required this.imageFile,
  });

  final Prediction prediction;
  final File imageFile;

  @override
  Widget build(BuildContext context) {
    final confidence =
        '${(prediction.confidence * 100).toStringAsFixed(1)} %';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du diagnostic'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            _ImagePreview(imageFile: imageFile),
            const SizedBox(height: 26),
            const Icon(
              Icons.search_off_outlined,
              size: 72,
              color: Colors.orange,
            ),
            const SizedBox(height: 18),
            Text(
              'Image non reconnue avec assez de certitude',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'L’application n’a pas pu identifier clairement la plante ou la maladie. '
              'Le meilleur résultat obtenu avait une confiance de $confidence.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            const _InfoCard(
              icon: Icons.camera_alt_outlined,
              title: 'Conseils pour une meilleure photo',
              items: [
                'Prenez la feuille ou la plante de près.',
                'Utilisez une bonne lumière naturelle.',
                'Évitez les images floues ou trop sombres.',
                'Photographiez les taches, feuilles ou fruits concernés.',
                'Essayez une autre photo sous un autre angle.',
              ],
            ),
            const SizedBox(height: 22),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.diagnosis),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Réessayer avec une autre photo'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              child: OutlinedButton.icon(
                onPressed: () => context.go(AppRoutes.home),
                icon: const Icon(Icons.home_outlined),
                label: const Text('Retour à l’accueil'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataErrorScreen extends ConsumerWidget {
  const _DataErrorScreen({
    required this.prediction,
    required this.imageFile,
    required this.error,
  });

  final Prediction prediction;
  final File imageFile;
  final String error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _ImagePreview(imageFile: imageFile),
            const SizedBox(height: 28),
            const Icon(
              Icons.error_outline,
              size: 70,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Informations de traitement indisponibles',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              'Le diagnostic a été effectué, mais les informations complémentaires '
              'n’ont pas pu être chargées. Vérifie que la clé du diagnostic existe '
              'dans assets/data/diseases.json.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            ExpansionTile(
              title: const Text('Détails techniques'),
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(error),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.diagnosis),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Faire un nouveau diagnostic'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 54,
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  final messenger = ScaffoldMessenger.of(context);

                  

                  ref.invalidate(diagnosisHistoryProvider);

                  if (context.mounted) {
                    messenger.showSnackBar(
                      const SnackBar(
                        content: Text('Diagnostic enregistré dans l’historique.'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.bookmark_add_outlined),
                label: const Text('Enregistrer dans l’historique'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}