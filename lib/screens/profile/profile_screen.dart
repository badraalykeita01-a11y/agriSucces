import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
const ProfileScreen({super.key});

@override
Widget build(BuildContext context) {
const userName = 'Utilisateur';
const location = 'Mali';
const phone = 'Non renseigné';


return Scaffold(
  appBar: AppBar(
    title: const Text('Mon profil'),
    centerTitle: true,
  ),
  body: ListView(
    padding: const EdgeInsets.all(20),
    children: [
      const SizedBox(height: 12),
      const Center(
        child: CircleAvatar(
          radius: 52,
          child: Icon(
            Icons.person,
            size: 58,
          ),
        ),
      ),
      const SizedBox(height: 16),
      const Center(
        child: Text(
          userName,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      const SizedBox(height: 6),
      const Center(
        child: Text(
          'Agriculteur / Utilisateur AgriSuccès',
          style: TextStyle(
            color: Colors.grey,
          ),
        ),
      ),
      const SizedBox(height: 28),
      _ProfileInfoCard(
        icon: Icons.phone_outlined,
        title: 'Téléphone',
        value: phone,
      ),
      const SizedBox(height: 12),
      _ProfileInfoCard(
        icon: Icons.location_on_outlined,
        title: 'Localisation',
        value: location,
      ),
      const SizedBox(height: 28),
      const Text(
        'Statistiques',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      const SizedBox(height: 12),
      const Row(
        children: [
          Expanded(
            child: _StatisticCard(
              icon: Icons.document_scanner_outlined,
              label: 'Diagnostics',
              value: '0',
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _StatisticCard(
              icon: Icons.eco_outlined,
              label: 'Plantes saines',
              value: '0',
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      const _StatisticCard(
        icon: Icons.warning_amber_rounded,
        label: 'Maladies détectées',
        value: '0',
      ),
      const SizedBox(height: 28),
      SizedBox(
        height: 50,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('La modification du profil arrive bientôt.'),
              ),
            );
          },
          icon: const Icon(Icons.edit_outlined),
          label: const Text('Modifier mon profil'),
        ),
      ),
    ],
  ),
);


}
}

class _ProfileInfoCard extends StatelessWidget {
const _ProfileInfoCard({
required this.icon,
required this.title,
required this.value,
});

final IconData icon;
final String title;
final String value;

@override
Widget build(BuildContext context) {
return Card(
child: ListTile(
leading: Icon(icon),
title: Text(title),
subtitle: Text(value),
),
);
}
}

class _StatisticCard extends StatelessWidget {
const _StatisticCard({
required this.icon,
required this.label,
required this.value,
});

final IconData icon;
final String label;
final String value;

@override
Widget build(BuildContext context) {
return Card(
child: Padding(
padding: const EdgeInsets.symmetric(
horizontal: 14,
vertical: 18,
),
child: Column(
children: [
Icon(icon, size: 30),
const SizedBox(height: 10),
Text(
value,
style: const TextStyle(
fontSize: 24,
fontWeight: FontWeight.bold,
),
),
const SizedBox(height: 4),
Text(
label,
textAlign: TextAlign.center,
),
],
),
),
);
}
}
