import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palletsort/screens/forget_password_screen.dart';
import 'package:palletsort/theme/theme.dart';
import 'package:palletsort/widgets/app_chrome.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _rememberMe = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    HapticFeedback.lightImpact();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Credenciais validadas. Conectando à sua operação...'),
      ),
    );
  }

  void _openForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) =>
            ForgetPasswordScreen(initialEmail: _emailController.text.trim()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: BrandBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 1100;
              final isCompactWidth = constraints.maxWidth < 360;
              final isCompactHeight = constraints.maxHeight < 600;
              final horizontalPadding = isDesktop
                  ? 32.0
                  : isCompactWidth
                  ? 12.0
                  : 20.0;
              final verticalPadding = isCompactHeight ? 12.0 : 24.0;
              final contentHeight = math.max(
                constraints.maxHeight - (verticalPadding * 2),
                isDesktop ? 680.0 : 720.0,
              );

              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1160),
                    child: isDesktop
                        ? SizedBox(
                            height: contentHeight,
                            child: _DesktopSignIn(
                              form: _buildForm(true, isCompactWidth: false),
                            ),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: math.max(
                                constraints.maxHeight - (verticalPadding * 2),
                                0,
                              ),
                            ),
                            child: _MobileSignIn(
                              form: _buildForm(
                                false,
                                isCompactWidth: isCompactWidth,
                              ),
                            ),
                          ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildForm(bool isDesktop, {required bool isCompactWidth}) {
    return GlassPanel(
      padding: EdgeInsets.all(
        isDesktop
            ? 40
            : isCompactWidth
            ? 18
            : 24,
      ),
      child: Form(
        key: _formKey,
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!isDesktop) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const AppBackButton(),
                    const SizedBox(width: 12),
                    Flexible(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: PalletSortLogo(
                          width: isCompactWidth ? 104 : 138,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: isCompactWidth ? 26 : 34),
              ],
              const SectionLabel(
                text: 'Acesso seguro',
                icon: Icons.lock_outline_rounded,
              ),
              SizedBox(height: isCompactWidth ? 16 : 20),
              Text(
                'Bem-vindo de volta',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                  color: AppColors.white,
                  fontSize: isDesktop
                      ? 34
                      : isCompactWidth
                      ? 27
                      : 30,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Entre com suas credenciais para acessar sua operação.',
                style: TextStyle(color: AppColors.slate400, fontSize: 15),
              ),
              SizedBox(height: isCompactWidth ? 24 : 30),
              _FieldLabel(label: 'E-mail'),
              const SizedBox(height: 9),
              TextFormField(
                key: const Key('emailField'),
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                autofillHints: const [
                  AutofillHints.username,
                  AutofillHints.email,
                ],
                style: const TextStyle(color: AppColors.white),
                decoration: const InputDecoration(
                  hintText: 'nome@empresa.com',
                  prefixIcon: Icon(Icons.alternate_email_rounded),
                ),
                validator: _validateEmail,
              ),
              const SizedBox(height: 20),
              _FieldLabel(label: 'Senha'),
              const SizedBox(height: 9),
              TextFormField(
                key: const Key('passwordField'),
                controller: _passwordController,
                obscureText: _obscurePassword,
                textInputAction: TextInputAction.done,
                autofillHints: const [AutofillHints.password],
                onFieldSubmitted: (_) => _submit(),
                style: const TextStyle(color: AppColors.white),
                decoration: InputDecoration(
                  hintText: 'Digite sua senha',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    tooltip: _obscurePassword
                        ? 'Mostrar senha'
                        : 'Ocultar senha',
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                    ),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Informe sua senha';
                  }
                  if (value.length < 6) {
                    return 'A senha deve ter pelo menos 6 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                crossAxisAlignment: WrapCrossAlignment.center,
                runSpacing: 4,
                children: [
                  InkWell(
                    onTap: () => setState(() => _rememberMe = !_rememberMe),
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (value) =>
                                setState(() => _rememberMe = value ?? false),
                          ),
                          const Flexible(
                            child: Text(
                              'Manter conectado',
                              style: TextStyle(color: AppColors.slate200),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  TextButton(
                    key: const Key('forgotPasswordButton'),
                    onPressed: _openForgotPassword,
                    child: const Text('Esqueceu a senha?'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: PrimaryActionButton(
                  label: 'Entrar',
                  icon: Icons.login_rounded,
                  onPressed: _submit,
                ),
              ),
              const SizedBox(height: 22),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shield_outlined,
                    size: 16,
                    color: AppColors.slate400,
                  ),
                  SizedBox(width: 7),
                  Flexible(
                    child: Text(
                      'Seus dados são protegidos e criptografados',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.slate400, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Informe seu e-mail';
    final looksLikeEmail = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(email);
    if (!looksLikeEmail) return 'Digite um e-mail válido';
    return null;
  }
}

class _DesktopSignIn extends StatelessWidget {
  const _DesktopSignIn({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          child: AuthVisualPanel(
            title: 'Sua operação começa com uma visão clara.',
            description:
                'Centralize a identificação e o acompanhamento dos pallets em uma experiência rápida e segura.',
            features: [
              (Icons.qr_code_scanner_rounded, 'Identificação sem complicação'),
              (Icons.route_rounded, 'Histórico sempre acessível'),
              (Icons.devices_rounded, 'Pronto para qualquer dispositivo'),
            ],
          ),
        ),
        SizedBox(width: 28),
        SizedBox(width: 470, child: Center(child: form)),
      ],
    );
  }
}

class _MobileSignIn extends StatelessWidget {
  const _MobileSignIn({required this.form});

  final Widget form;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: form,
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  const _FieldLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: AppColors.slate200,
        fontSize: 13,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}
