import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/user_profile_provider.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {
      final auth = ref.read(authServiceProvider);

      final user = await auth.register(
        fullName: _fullNameController.text,
        phone: _phoneController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      await ref.read(authSessionProvider.notifier).login(user);
      await ref.read(userProfileProvider.notifier).syncFromUser(user);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Compte créé avec succès. Bienvenue !'),
          ),
        );

        context.go(AppRoutes.home);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString().replaceFirst('Exception: ', ''),
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Créer un compte'),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(30, 20, 30, 32),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Image.asset(
                    AppConstants.logoPath,
                    width: 100,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Rejoignez Agri_Succès',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Créez votre compte pour enregistrer vos diagnostics agricoles.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),
                  CustomTextField(
                    controller: _fullNameController,
                    label: 'Nom complet',
                    hint: 'Exemple : Badra Aly Keita',
                    icon: Icons.person_outline,
                    textCapitalization: TextCapitalization.words,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez saisir votre nom complet';
                      }

                      if (value.trim().length < 3) {
                        return 'Le nom doit contenir au moins 3 caractères';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Téléphone',
                    hint: 'Exemple : 70 00 00 00',
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Veuillez saisir votre numéro de téléphone';
                      }

                      if (value.trim().length < 8) {
                        return 'Veuillez saisir un numéro valide';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Adresse e-mail',
                    hint: 'Exemple : nom@email.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      final email = value?.trim() ?? '';

                      if (email.isEmpty) {
                        return 'Veuillez saisir votre adresse e-mail';
                      }

                      if (!email.contains('@') || !email.contains('.')) {
                        return 'Veuillez saisir une adresse e-mail valide';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Mot de passe',
                    hint: 'Au moins 6 caractères',
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez saisir un mot de passe';
                      }

                      if (value.length < 6) {
                        return 'Le mot de passe doit contenir au moins 6 caractères';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmer le mot de passe',
                    hint: 'Répétez votre mot de passe',
                    icon: Icons.lock_reset_outlined,
                    obscureText: _obscureConfirmPassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword =
                              !_obscureConfirmPassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez confirmer votre mot de passe';
                      }

                      if (value != _passwordController.text) {
                        return 'Les mots de passe ne correspondent pas';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 30),
                  CustomButton(
                    text: 'Créer mon compte',
                    icon: Icons.person_add_alt_1,
                    loading: _loading,
                    onPressed: _register,
                  ),
                  const SizedBox(height: 18),
                  TextButton(
                    onPressed: () => context.pop(),
                    child: const Text('J’ai déjà un compte'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}