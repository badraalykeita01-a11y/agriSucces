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

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();

  final _passwordController = TextEditingController();

  bool _loading = false;

  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _loading = true;
    });

    try {

      final auth = ref.read(authServiceProvider);

      final user = await auth.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await ref.read(authSessionProvider.notifier).login(user);
      await ref.read(userProfileProvider.notifier).syncFromUser(user);

      if (mounted) {
        context.go(AppRoutes.home);
      }

    } catch (e) {

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString().replaceFirst("Exception: ", "")),
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

      body: SafeArea(

        child: Center(

          child: SingleChildScrollView(

            padding: const EdgeInsets.symmetric(horizontal: 30),

            child: Form(

              key: _formKey,

              child: Column(

                children: [

                  Image.asset(
                    AppConstants.logoPath,
                    width: 130,
                  ),

                  const SizedBox(height: 25),

                  Text(
                    AppConstants.appName,
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.darkGreen,
                        ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    AppConstants.appSlogan,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey.shade700,
                    ),
                  ),

                  const SizedBox(height: 45),

                  CustomTextField(
                    controller: _emailController,
                    label: "Adresse e-mail",
                    hint: "Entrez votre e-mail",
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {

                      if (value == null || value.isEmpty) {
                        return "Veuillez saisir votre e-mail";
                      }

                      return null;

                    },
                  ),

                  const SizedBox(height: 20),

                  CustomTextField(
                    controller: _passwordController,
                    label: "Mot de passe",
                    hint: "Entrez votre mot de passe",
                    icon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {

                      if (value == null || value.isEmpty) {
                        return "Veuillez saisir votre mot de passe";
                      }

                      return null;

                    },
                  ),

                  const SizedBox(height: 30),

                  CustomButton(
                    text: "Se connecter",
                    icon: Icons.login,
                    loading: _loading,
                    onPressed: _login,
                  ),

                  const SizedBox(height: 25),

                  TextButton(

                    onPressed: () {

                      context.push(AppRoutes.register);

                    },

                    child: const Text(
                      "Créer un compte",
                    ),

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