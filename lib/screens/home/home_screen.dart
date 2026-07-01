import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/routes/app_routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Accueil')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _HomeTile(
            icon: Icons.eco,
            title: 'Diagnostic',
            onTap: () => context.push(AppRoutes.diagnosis),
          ),
          _HomeTile(
            icon: Icons.history,
            title: 'Historique',
            onTap: () => context.push(AppRoutes.history),
          ),
          _HomeTile(
            icon: Icons.person,
            title: 'Profil',
            onTap: () => context.push(AppRoutes.profile),
          ),
          _HomeTile(
            icon: Icons.info_outline,
            title: 'À propos',
            onTap: () => context.push(AppRoutes.about),
          ),
        ],
      ),
    );
  }
}

class _HomeTile extends StatelessWidget {
  const _HomeTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(title),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
