import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../models/diagnosis_history_item.dart';
import '../../providers/history_provider.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd’hui à '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    if (difference.inDays == 1) {
      return 'Hier à '
          '${date.hour.toString().padLeft(2, '0')}:'
          '${date.minute.toString().padLeft(2, '0')}';
    }

    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} à '
        '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  Color _confidenceColor(double confidence) {
    if (confidence >= 0.85) return Colors.green;
    if (confidence >= 0.70) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(diagnosisHistoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Historique'),
        centerTitle: true,
        actions: [
          historyAsync.when(
            data: (items) {
              if (items.isEmpty) {
                return const SizedBox.shrink();
              }

              return IconButton(
                tooltip: 'Supprimer tout l’historique',
                icon: const Icon(Icons.delete_outline),
                onPressed: () {
                  _showClearDialog(context, ref);
                },
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => _HistoryError(
          error: error.toString(),
          onRetry: () {
            ref.invalidate(diagnosisHistoryProvider);
          },
        ),
        data: (items) {
          if (items.isEmpty) {
            return const _EmptyHistory();
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(diagnosisHistoryProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final item = items[index];

                return _HistoryCard(
                  item: item,
                  formattedDate: _formatDate(item.createdAt),
                  confidenceColor: _confidenceColor(
                    item.prediction.confidence,
                  ),
                  onTap: () {
                    final imageFile = File(item.imagePath);

                    if (!imageFile.existsSync()) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'La photo de ce diagnostic n’est plus disponible.',
                          ),
                        ),
                      );
                      return;
                    }

                    context.push(
                      AppRoutes.diagnosisResult,
                      extra: {
                        'prediction': item.prediction,
                        'imageFile': imageFile,
                      },
                    );
                  },
                  onDelete: () {
                    _showDeleteDialog(
                      context,
                      ref,
                      item.id,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(AppRoutes.diagnosis),
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Nouveau diagnostic'),
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    String itemId,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Supprimer ce diagnostic ?'),
          content: const Text(
            'Cette action supprimera ce diagnostic de votre historique.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref
                    .read(diagnosisHistoryProvider.notifier)
                    .remove(itemId);
              },
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _showClearDialog(
    BuildContext context,
    WidgetRef ref,
  ) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Vider l’historique ?'),
          content: const Text(
            'Tous les diagnostics enregistrés seront supprimés définitivement.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () async {
                Navigator.pop(dialogContext);

                await ref
                    .read(diagnosisHistoryProvider.notifier)
                    .clear();
              },
              child: const Text('Tout supprimer'),
            ),
          ],
        );
      },
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.item,
    required this.formattedDate,
    required this.confidenceColor,
    required this.onTap,
    required this.onDelete,
  });

  final DiagnosisHistoryItem item;
  final String formattedDate;
  final Color confidenceColor;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final prediction = item.prediction;
    final imageFile = File(item.imagePath);
    final imageExists = imageFile.existsSync();

    final confidence =
        '${(prediction.confidence * 100).toStringAsFixed(1)} %';

    final resultName = prediction.isUnknown
        ? 'Diagnostic incertain'
        : prediction.disease;

    return Card(
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            SizedBox(
              width: 112,
              height: 128,
              child: imageExists
                  ? Image.file(
                      imageFile,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      color: Colors.grey.shade200,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      prediction.crop,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryGreen,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      resultName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.darkGreen,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          prediction.isUnknown
                              ? Icons.help_outline
                              : Icons.analytics_outlined,
                          size: 17,
                          color: confidenceColor,
                        ),
                        const SizedBox(width: 5),
                        Text(
                          prediction.isUnknown
                              ? 'Confiance : $confidence'
                              : 'Confiance : $confidence',
                          style: TextStyle(
                            color: confidenceColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            IconButton(
              tooltip: 'Supprimer',
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHistory extends StatelessWidget {
  const _EmptyHistory();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.history_outlined,
                size: 82,
                color: AppColors.primaryGreen.withValues(alpha: 0.75),
              ),
              const SizedBox(height: 20),
              Text(
                'Aucun diagnostic enregistré',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
              ),
              const SizedBox(height: 10),
              Text(
                'Vos diagnostics apparaîtront ici après l’analyse d’une plante.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade700,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.go(AppRoutes.diagnosis),
                icon: const Icon(Icons.camera_alt_outlined),
                label: const Text('Faire un diagnostic'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryError extends StatelessWidget {
  const _HistoryError({
    required this.error,
    required this.onRetry,
  });

  final String error;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 72,
              color: Colors.red,
            ),
            const SizedBox(height: 18),
            Text(
              'Impossible de charger l’historique',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              error,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}