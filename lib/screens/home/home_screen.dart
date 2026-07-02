import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  String _firstName(String fullName) {
    final names = fullName.trim().split(' ');
    return names.isNotEmpty ? names.first : 'Agriculteur';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final firstName = user == null ? 'Agriculteur' : _firstName(user.fullName);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agri_Succès'),
        centerTitle: false,
        actions: [
          IconButton(
            tooltip: 'Mon profil',
            onPressed: () => context.go(AppRoutes.profile),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Bonjour, $firstName 👋',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkGreen,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Prenez soin de vos cultures grâce au diagnostic intelligent.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 24),
            _DiagnosticBanner(
              onStart: () => context.go(AppRoutes.diagnosis),
            ),
            const SizedBox(height: 24),
            Text(
              'Accès rapide',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.document_scanner_outlined,
                    title: 'Diagnostiquer',
                    subtitle: 'Analyser une plante',
                    onTap: () => context.go(AppRoutes.diagnosis),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: _QuickActionCard(
                    icon: Icons.history_outlined,
                    title: 'Historique',
                    subtitle: 'Voir mes analyses',
                    onTap: () => context.go(AppRoutes.history),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Cultures prises en charge',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            const Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _CropChip(label: 'Tomate', icon: Icons.eco_outlined),
                _CropChip(label: 'Pomme de terre', icon: Icons.spa_outlined),
                _CropChip(label: 'Piment', icon: Icons.local_florist_outlined),
                _CropChip(label: 'Poivron', icon: Icons.grass_outlined),
                _CropChip(label: 'Maïs', icon: Icons.agriculture_outlined),
              ],
            ),
            const SizedBox(height: 28),
            Text(
              'Comment ça marche ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 14),
            const _StepCard(
              number: '1',
              title: 'Prenez une photo',
              description: 'Photographiez la feuille ou la partie malade de la plante.',
              icon: Icons.camera_alt_outlined,
            ),
            const SizedBox(height: 12),
            const _StepCard(
              number: '2',
              title: 'Laissez l’IA analyser',
              description: 'Le modèle reconnaît la culture et la maladie détectée.',
              icon: Icons.psychology_outlined,
            ),
            const SizedBox(height: 12),
            const _StepCard(
              number: '3',
              title: 'Appliquez les conseils',
              description: 'Consultez les solutions et mesures de prévention proposées.',
              icon: Icons.health_and_safety_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _DiagnosticBanner extends StatelessWidget {
  final VoidCallback onStart;

  const _DiagnosticBanner({
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.document_scanner_outlined,
            color: Colors.white,
            size: 34,
          ),
          const SizedBox(height: 14),
          Text(
            'Une plante semble malade ?',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'Prenez une photo et obtenez un diagnostic en quelques secondes.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.88),
                  height: 1.4,
                ),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: onStart,
            style: FilledButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.darkGreen,
            ),
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Commencer un diagnostic'),
          ),
        ],
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.18),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: AppColors.primaryGreen, size: 30),
              const SizedBox(height: 18),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CropChip extends StatelessWidget {
  final String label;
  final IconData icon;

  const _CropChip({
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(
        icon,
        size: 18,
        color: AppColors.primaryGreen,
      ),
      label: Text(label),
      side: BorderSide(
        color: AppColors.primaryGreen.withValues(alpha: 0.25),
      ),
      backgroundColor: AppColors.primaryGreen.withValues(alpha: 0.06),
    );
  }
}

class _StepCard extends StatelessWidget {
  final String number;
  final String title;
  final String description;
  final IconData icon;

  const _StepCard({
    required this.number,
    required this.title,
    required this.description,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              child: Text(
                number,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Icon(icon, color: AppColors.primaryGreen),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade700,
                          height: 1.35,
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