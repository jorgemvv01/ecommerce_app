import 'package:ecommerce_app/core/widgets/custom_loading.dart';
import 'package:ecommerce_app/features/auth/presentation/viewmodels/auth_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:villa_design/villa_design.dart';

import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitRegister() {
    ref.read(authViewModelProvider.notifier).register(
      email: _emailController.text,
      username: _usernameController.text,
      password: _passwordController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authViewModelProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        Navigator.of(context).pop();
      }
    });

    final authState = ref.watch(authViewModelProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return VillaFormTemplate(
      header: const VillaHeader(title: 'Create an account'),
      primaryActionText: 'Create',
      secondaryActionText: 'Already have an account? log in',
      onPrimaryAction: isLoading ? null : _submitRegister,
      onSecondaryAction: isLoading ? null : () => Navigator.of(context).pop(),
      formFields: [
        Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: isLoading
            ? const Center(
                child: Column(
                  children: [
                    SizedBox(height: 200),
                    CustomLoading(),
                  ],
                )
              )
            : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                VillaTextField(
                  controller: _emailController,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                VillaTextField(
                  controller: _usernameController,
                  hintText: 'Username',
                ),
                const SizedBox(height: 16),
                VillaTextField(
                  controller: _passwordController,
                  obscureText: true,
                  hintText: 'Password',
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        )
      ],
    );
  }
}