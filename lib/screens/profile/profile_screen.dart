import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_profile.dart';
import '../../providers/history_provider.dart';
import '../../providers/user_profile_provider.dart';
import 'dart:io';

import 'package:image_picker/image_picker.dart';


class ProfileScreen extends ConsumerWidget {
const ProfileScreen({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
final profileState = ref.watch(userProfileProvider);
final historyState = ref.watch(diagnosisHistoryProvider);

return Scaffold(
  appBar: AppBar(
    title: const Text('Mon profil'),
    centerTitle: true,
  ),
  body: profileState.when(
    loading: () => const Center(
      child: CircularProgressIndicator(),
    ),
    error: (error, _) => Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Impossible de charger le profil : $error',
          textAlign: TextAlign.center,
        ),
      ),
    ),
    data: (profile) {
      final history = historyState.valueOrNull ?? [];

      final totalDiagnostics = history.length;
      final healthyPlants = history.where((item) => item.isHealthy).length;
      final detectedDiseases =
          history.where((item) => !item.isHealthy && !item.isUnknown).length;

      return ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 12),
          CircleAvatar(
                radius: 52,
                backgroundImage: profile.profileImagePath != null &&
                File(profile.profileImagePath!).existsSync()
                ? FileImage(File(profile.profileImagePath!))
                : null,
                child: profile.profileImagePath == null ||
                !File(profile.profileImagePath!).existsSync()
                ? Text(
                _initials(profile.fullName),
                style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                ),
                )
                : null,
                ),

          const SizedBox(height: 16),
          Center(
            child: Text(
              profile.fullName.trim().isEmpty
                  ? 'Utilisateur AgriSuccès'
                  : profile.fullName,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 6),
          const Center(
            child: Text(
              'Agriculteur / Utilisateur AgriSuccès',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 28),
          _ProfileInfoCard(
            icon: Icons.phone_outlined,
            title: 'Téléphone',
            value: profile.phone.trim().isEmpty
                ? 'Non renseigné'
                : profile.phone,
          ),
          const SizedBox(height: 12),
          _ProfileInfoCard(
            icon: Icons.location_on_outlined,
            title: 'Localisation',
            value: profile.location.trim().isEmpty
                ? 'Non renseignée'
                : profile.location,
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
          Row(
            children: [
              Expanded(
                child: _StatisticCard(
                  icon: Icons.document_scanner_outlined,
                  label: 'Diagnostics',
                  value: totalDiagnostics.toString(),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatisticCard(
                  icon: Icons.eco_outlined,
                  label: 'Plantes saines',
                  value: healthyPlants.toString(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _StatisticCard(
            icon: Icons.warning_amber_rounded,
            label: 'Maladies détectées',
            value: detectedDiseases.toString(),
          ),
          const SizedBox(height: 28),
          SizedBox(
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => EditProfileScreen(profile: profile),
                  ),
                );
              },
              icon: const Icon(Icons.edit_outlined),
              label: const Text('Modifier mon profil'),
            ),
          ),
        ],
      );
    },
  ),
);

}

String _initials(String fullName) {
final words = fullName
.trim()
.split(RegExp(r'\s+'))
.where((word) => word.isNotEmpty)
.toList();

if (words.isEmpty) return 'AS';

if (words.length == 1) {
  return words.first.substring(0, 1).toUpperCase();
}

return '${words.first.substring(0, 1)}${words.last.substring(0, 1)}'
    .toUpperCase();

}
}

class EditProfileScreen extends ConsumerStatefulWidget {
const EditProfileScreen({
super.key,
required this.profile,
});

final UserProfile profile;

@override
ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
final _formKey = GlobalKey<FormState>();

late final TextEditingController _nameController;
late final TextEditingController _phoneController;
late final TextEditingController _locationController;

bool _isSaving = false;
String? _selectedImagePath;


@override
void initState() {
super.initState();

_nameController = TextEditingController(
  text: widget.profile.fullName,
);
_phoneController = TextEditingController(
  text: widget.profile.phone,
);
_locationController = TextEditingController(
  text: widget.profile.location,
);
_selectedImagePath = widget.profile.profileImagePath;


}

@override
void dispose() {
_nameController.dispose();
_phoneController.dispose();
_locationController.dispose();
super.dispose();
}

Future<void> _pickProfileImage() async {
try {
final picker = ImagePicker();

final selectedImage = await picker.pickImage(
  source: ImageSource.gallery,
  imageQuality: 80,
);

if (selectedImage == null) return;

setState(() {
  _selectedImagePath = selectedImage.path;
});

} catch (_) {
if (!mounted) return;

ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(
    content: Text('Impossible de sélectionner cette image.'),
  ),
);

}
}


Future<void> _save() async {
if (!_formKey.currentState!.validate()) return;

setState(() {
  _isSaving = true;
});

final updatedProfile = widget.profile.copyWith(
  fullName: _nameController.text.trim(),
  phone: _phoneController.text.trim(),
  location: _locationController.text.trim(),
  profileImagePath: _selectedImagePath,
);

await ref.read(userProfileProvider.notifier).save(updatedProfile);

if (!mounted) return;

setState(() {
  _isSaving = false;
});

Navigator.of(context).pop();

}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text('Modifier mon profil'),
),
body: SafeArea(
child: Form(
key: _formKey,
child: ListView(
padding: const EdgeInsets.all(20),
children: [
  Center(
child: InkWell(
onTap: _pickProfileImage,
borderRadius: BorderRadius.circular(60),
child: CircleAvatar(
radius: 52,
backgroundImage: _selectedImagePath != null &&
File(_selectedImagePath!).existsSync()
? FileImage(File(_selectedImagePath!))
: null,
child: _selectedImagePath == null
? const Icon(Icons.camera_alt_outlined, size: 32)
: null,
),
),
),
const SizedBox(height: 10),
const Center(
child: Text('Appuyez sur la photo pour la modifier'),
),
const SizedBox(height: 24),

TextFormField(
controller: _nameController,
textCapitalization: TextCapitalization.words,
decoration: const InputDecoration(
labelText: 'Nom complet',
prefixIcon: Icon(Icons.person_outline),
border: OutlineInputBorder(),
),
validator: (value) {
if (value == null || value.trim().isEmpty) {
return 'Veuillez saisir votre nom.';
}
return null;
},
),
const SizedBox(height: 16),
TextFormField(
controller: _phoneController,
keyboardType: TextInputType.phone,
decoration: const InputDecoration(
labelText: 'Téléphone',
prefixIcon: Icon(Icons.phone_outlined),
border: OutlineInputBorder(),
),
),
const SizedBox(height: 16),
TextFormField(
controller: _locationController,
textCapitalization: TextCapitalization.words,
decoration: const InputDecoration(
labelText: 'Localisation',
hintText: 'Exemple : Kati, Mali',
prefixIcon: Icon(Icons.location_on_outlined),
border: OutlineInputBorder(),
),
),
const SizedBox(height: 28),
SizedBox(
height: 50,
child: ElevatedButton(
onPressed: _isSaving ? null : _save,
child: _isSaving
? const CircularProgressIndicator()
: const Text('Enregistrer'),
),
),
],
),
),
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
