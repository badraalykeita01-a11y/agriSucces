import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../core/theme/app_colors.dart';
import '../../widgets/custom_button.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../ai/providers/ai_providers.dart';
import '../../core/routes/app_routes.dart';

class DiagnosisScreen extends ConsumerStatefulWidget {
  const DiagnosisScreen({super.key});

  @override
  ConsumerState<DiagnosisScreen> createState() => _DiagnosisScreenState();
}

class _DiagnosisScreenState extends ConsumerState<DiagnosisScreen> {
  bool _isAnalyzing = false;
  final ImagePicker _imagePicker = ImagePicker();

  final List<_CropOption> _crops = const [
    _CropOption(
      name: 'Tomate',
      icon: Icons.eco_outlined,
    ),
    _CropOption(
      name: 'Pomme de terre',
      icon: Icons.spa_outlined,
    ),
    _CropOption(
      name: 'Piment',
      icon: Icons.local_florist_outlined,
    ),
    _CropOption(
      name: 'Poivron',
      icon: Icons.grass_outlined,
    ),
    _CropOption(
      name: 'Maïs',
      icon: Icons.agriculture_outlined,
    ),
  ];

  String? _selectedCrop;
  File? _selectedImage;
  bool _isPickingImage = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _isPickingImage = true;
    });

    try {
      final image = await _imagePicker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1600,
      );

      if (image == null) return;

      setState(() {
        _selectedImage = File(image.path);
      });
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Impossible d’ouvrir la caméra ou la galerie.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPickingImage = false;
        });
      }
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Ajouter une photo',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Photographiez de préférence une feuille bien visible et éclairée.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade700),
                ),
                const SizedBox(height: 20),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt_outlined),
                  ),
                  title: const Text('Prendre une photo'),
                  subtitle: const Text('Utiliser la caméra'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.photo_library_outlined),
                  ),
                  title: const Text('Choisir depuis la galerie'),
                  subtitle: const Text('Utiliser une image existante'),
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _startAnalysis() async {
  if (_selectedCrop == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez d’abord sélectionner une culture.'),
      ),
    );
    return;
  }

  if (_selectedImage == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veuillez ajouter une photo de votre plante.'),
      ),
    );
    return;
  }

  setState(() {
    _isAnalyzing = true;
  });

  try {
    await ref.read(aiInitializationProvider.future);

    final classifier = ref.read(plantClassifierProvider);

    final prediction = await classifier.classifyFromFile(_selectedImage!);

    if (!mounted) return;

    context.push(
      AppRoutes.diagnosisResult,
      extra: {
        'prediction': prediction,
        'imageFile': _selectedImage!,
      },
    );
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur pendant l’analyse : ${e.toString().replaceFirst('Exception: ', '')}',
          ),
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau diagnostic'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
          children: [
            Text(
              'Quelle culture souhaitez-vous analyser ?',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Sélectionnez la culture concernée afin d’améliorer la pertinence du diagnostic.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 18),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _crops.map((crop) {
                final isSelected = _selectedCrop == crop.name;

                return ChoiceChip(
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      _selectedCrop = crop.name;
                    });
                  },
                  avatar: Icon(
                    crop.icon,
                    size: 18,
                    color: isSelected ? Colors.white : AppColors.primaryGreen,
                  ),
                  label: Text(crop.name),
                  selectedColor: AppColors.primaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : null,
                    fontWeight: isSelected ? FontWeight.w600 : null,
                  ),
                  side: BorderSide(
                    color: isSelected
                        ? AppColors.primaryGreen
                        : AppColors.primaryGreen.withValues(alpha: 0.25),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 30),
            Text(
              'Photo de la plante',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Cadrez la partie malade : feuilles, tiges ou fruits présentant des symptômes.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
            ),
            const SizedBox(height: 16),
            _PhotoArea(
              image: _selectedImage,
              isLoading: _isPickingImage,
              onTap: _isPickingImage ? null : _showImageSourceSheet,
              onRemove: _selectedImage == null
                  ? null
                  : () {
                      setState(() {
                        _selectedImage = null;
                      });
                    },
            ),
            const SizedBox(height: 18),
            _AdviceCard(),
            const SizedBox(height: 28),
            CustomButton(
  text: _isAnalyzing ? 'Analyse en cours...' : 'Analyser la plante',
  icon: Icons.psychology_outlined,
  loading: _isAnalyzing,
  onPressed: _isAnalyzing ? () {} : _startAnalysis,
),
          ],
        ),
      ),
    );
  }
}

class _CropOption {
  final String name;
  final IconData icon;

  const _CropOption({
    required this.name,
    required this.icon,
  });
}

class _PhotoArea extends StatelessWidget {
  final File? image;
  final bool isLoading;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const _PhotoArea({
    required this.image,
    required this.isLoading,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    if (image != null) {
      return Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: 4 / 3,
              child: Image.file(
                image!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black54,
              shape: const CircleBorder(),
              child: IconButton(
                tooltip: 'Supprimer la photo',
                onPressed: onRemove,
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      );
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          height: 230,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.primaryGreen.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Center(
            child: isLoading
                ? const CircularProgressIndicator()
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_a_photo_outlined,
                        color: AppColors.primaryGreen,
                        size: 48,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Ajouter une photo',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.darkGreen,
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Caméra ou galerie',
                        style: TextStyle(color: Colors.grey.shade700),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _AdviceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.amber.withValues(alpha: 0.10),
      child: const Padding(
        padding: EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_outline),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'Conseil : évitez les photos floues, trop sombres ou prises de trop loin. Une photo nette améliore le diagnostic.',
              ),
            ),
          ],
        ),
      ),
    );
  }
}