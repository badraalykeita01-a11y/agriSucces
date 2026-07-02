import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/model/disease_info.dart';
import '../../ai/model/prediction.dart';
import '../../ai/providers/ai_providers.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';

class DiagnosisResultScreen extends ConsumerWidget {
  final Prediction prediction;
  final File imageFile;

  const DiagnosisResultScreen({
    super.key,
    required this.prediction,
    required this.imageFile,
  });

  double get _confidencePercent => prediction.confidence * 100;

  String get _confidenceText => '${_confidencePercent.toStringAsFixed(1)} %';

  bool get _isReliable => prediction.confidence >= 0.60;

  bool get _isHealthy {
    return prediction.diseaseKey.toLowerCase().contains('healthy');
  }

  Color get _confidenceColor {
    if (prediction.confidence >= 0.80) return Colors.green;
    if (prediction.confidence >= 0.60) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!_isReliable) {
      return _LowConfidenceScreen(
        imageFile: imageFile,
        confidenceText: _confidenceText,
        confidenceColor: _confidenceColor,
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
        error: (error, stackTrace) => _ResultErrorView(
          message: error.toString().replaceFirst('Exception: ', ''),
        ),
        data: (diseaseInfo) => _ResultContent(
          prediction: prediction,
          imageFile: imageFile,
          diseaseInfo: diseaseInfo,
          confidenceText: _confidenceText,
          confidenceColor: _confidenceColor,
          isHealthy: _isHealthy,
        ),
      ),
    );
  }
}

/// Ajoute ce provider dans `lib/ai/providers/ai_providers.dart`.
///
/// final diseaseInfoProvider = FutureProvider.family<DiseaseInfo, String>(
///   (ref, diseaseKey) async {
///     return ref.read(diseaseRepositoryProvider).getByKey(diseaseKey);
///   },
/// );
class _ResultContent extends StatelessWidget {
  final Prediction prediction;
  final File imageFile;
  final DiseaseInfo diseaseInfo;
  final String confidenceText;
  final Color confidenceColor;
  final bool isHealthy;

  const _ResultContent({
    required this.prediction,
    required this.imageFile,
    required this.diseaseInfo,
    required this.confidenceText,
    required this.confidenceColor,
    required this.isHealthy,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(
                imageFile,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            isHealthy ? 'Plante en bonne santé' : 'Diagnostic terminé',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkGreen,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            isHealthy
                ? 'Aucun symptôme important n’a été détecté sur cette photo.'
                : 'Voici le résultat proposé par l’intelligence artificielle.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          _DiseaseHeaderCard(
            crop: diseaseInfo.crop,
            diseaseName: diseaseInfo.name,
            severity: diseaseInfo.severity,
            isHealthy: isHealthy,
          ),
          const SizedBox(height: 16),
          _ConfidenceCard(
            confidenceText: confidenceText,
            confidenceColor: confidenceColor,
          ),
          const SizedBox(height: 16),
          _InfoSection(
            icon: Icons.description_outlined,
            title: 'Description',
            child: Text(
              diseaseInfo.description,
              style: const TextStyle(height: 1.5),
            ),
          ),
          if (!isHealthy && diseaseInfo.causes.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoSection(
              icon: Icons.help_outline,
              title: 'Causes possibles',
              child: _BulletList(items: diseaseInfo.causes),
            ),
          ],
          if (!isHealthy && diseaseInfo.treatment.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoSection(
              icon: Icons.medical_services_outlined,
              title: 'Actions recommandées',
              child: _BulletList(items: diseaseInfo.treatment),
            ),
          ],
          if (diseaseInfo.prevention.isNotEmpty) ...[
            const SizedBox(height: 14),
            _InfoSection(
              icon: Icons.shield_outlined,
              title: isHealthy ? 'Conseils pour garder la plante saine' : 'Prévention',
              child: _BulletList(items: diseaseInfo.prevention),
            ),
          ],
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Colors.amber.withValues(alpha: 0.10),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Ce résultat est une aide à la décision. Vérifiez toujours l’état réel de la plante et respectez les recommandations locales avant tout traitement.',
                      style: TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 54,
            child: FilledButton.icon(
              onPressed: () => context.go(AppRoutes.diagnosis),
              icon: const Icon(Icons.camera_alt_outlined),
              label: const Text('Faire un nouveau diagnostic'),
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
    );
  }
}

class _LowConfidenceScreen extends StatelessWidget {
  final File imageFile;
  final String confidenceText;
  final Color confidenceColor;

  const _LowConfidenceScreen({
    required this.imageFile,
    required this.confidenceText,
    required this.confidenceColor,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résultat du diagnostic'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AspectRatio(
                aspectRatio: 4 / 3,
                child: Image.file(
                  imageFile,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Icon(
              Icons.photo_camera_back_outlined,
              size: 58,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Diagnostic non fiable',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'La photo ne permet pas d’identifier la plante ou la maladie avec suffisamment de certitude.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 22),
            _ConfidenceCard(
              confidenceText: confidenceText,
              confidenceColor: confidenceColor,
            ),
            const SizedBox(height: 16),
            _InfoSection(
              icon: Icons.tips_and_updates_outlined,
              title: 'Comment prendre une meilleure photo ?',
              child: const _BulletList(
                items: [
                  'Photographiez une seule feuille ou une zone malade de près.',
                  'Utilisez une bonne lumière naturelle.',
                  'Évitez les photos floues, sombres ou trop éloignées.',
                  'Placez la feuille sur un fond simple si possible.',
                  'Évitez de mélanger plusieurs cultures sur la même photo.',
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              height: 54,
              child: FilledButton.icon(
                onPressed: () => context.go(AppRoutes.diagnosis),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Reprendre une photo'),
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

class _DiseaseHeaderCard extends StatelessWidget {
  final String crop;
  final String diseaseName;
  final String severity;
  final bool isHealthy;

  const _DiseaseHeaderCard({
    required this.crop,
    required this.diseaseName,
    required this.severity,
    required this.isHealthy,
  });

  Color get _severityColor {
    final value = severity.toLowerCase();

    if (value.contains('élevée') || value.contains('elevee')) {
      return Colors.red;
    }

    if (value.contains('modérée') || value.contains('moderee')) {
      return Colors.orange;
    }

    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: AppColors.primaryGreen.withValues(alpha: 0.08),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(
              isHealthy
                  ? Icons.health_and_safety_outlined
                  : Icons.eco_outlined,
              size: 42,
              color: AppColors.primaryGreen,
            ),
            const SizedBox(height: 12),
            Text(
              crop,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              diseaseName,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppColors.darkGreen,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 7,
              ),
              decoration: BoxDecoration(
                color: _severityColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Text(
                'Gravité : $severity',
                style: TextStyle(
                  color: _severityColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceCard extends StatelessWidget {
  final String confidenceText;
  final Color confidenceColor;

  const _ConfidenceCard({
    required this.confidenceText,
    required this.confidenceColor,
  });

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
              backgroundColor: confidenceColor.withValues(alpha: 0.12),
              child: Icon(
                Icons.analytics_outlined,
                color: confidenceColor,
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
                          color: confidenceColor,
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

class _InfoSection extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _InfoSection({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
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
                          color: AppColors.darkGreen,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            child,
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  final List<String> items;

  const _BulletList({
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Icon(
                      Icons.check_circle_outline,
                      size: 18,
                      color: AppColors.primaryGreen,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      item,
                      style: const TextStyle(height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

class _ResultErrorView extends StatelessWidget {
  final String message;

  const _ResultErrorView({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              size: 56,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Impossible d’afficher les informations',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go(AppRoutes.diagnosis),
              child: const Text('Reprendre le diagnostic'),
            ),
          ],
        ),
      ),
    );
  }
}