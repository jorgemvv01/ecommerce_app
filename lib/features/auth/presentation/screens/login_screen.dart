import 'package:ecommerce_app/features/auth/presentation/screens/register_screen.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = VillaColors(Theme.of(context).brightness);
    final typography = VillaTypography(colors);
    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return VillaFormTemplate(
      onPrimaryAction: isLoading ? null : (){
        ref.read(authViewModelProvider.notifier).login(
          _usernameController.text,
          _passwordController.text
        );
      },
      header: const VillaHeader(
        title: 'Login',
      ),
      onSecondaryAction: isLoading ? null : (){
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const RegisterScreen()),
        );
      },
      formFields: [
        SizedBox(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'Welcome to Ecommerce App',
                style: typography.h3,
              ),
              Text(
                'An ecommerce application',
                style: typography.body,
              ),
              const SizedBox(height: 36),
              VillaTextField(
                labelText: 'Username',
                controller: _usernameController,
              ),
              const SizedBox(height: 16),
              VillaTextField(
                labelText: 'Password',
                obscureText: true,
                controller: _passwordController,
              ),
            ],
          ),
        ),
      ],
      secondaryActionText: 'Sign up',
      primaryActionText: 'Login',
    );
  }
}