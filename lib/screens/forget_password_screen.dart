import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palletsort/theme/theme.dart';
import 'package:palletsort/widgets/app_chrome.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key, this.initialEmail = ''});

  final String initialEmail;

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _emailController;
  bool _sent = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _sent = true);
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
                isDesktop ? 680.0 : 650.0,
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
                            child: _buildDesktop(context),
                          )
                        : ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: math.max(
                                constraints.maxHeight - (verticalPadding * 2),
                                0,
                              ),
                            ),
                            child: Center(
                              child: _buildCard(
                                context,
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

  Widget _buildDesktop(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Expanded(
          child: AuthVisualPanel(
            title: 'Recupere o acesso sem parar a operação.',
            description:
                'Um processo simples e seguro para você voltar rapidamente ao controle dos seus pallets.',
            features: [
              (
                Icons.mark_email_read_outlined,
                'Instruções enviadas por e-mail',
              ),
              (Icons.timer_outlined, 'Link temporário e protegido'),
              (Icons.support_agent_rounded, 'Suporte quando você precisar'),
            ],
          ),
        ),
        const SizedBox(width: 28),
        SizedBox(
          width: 470,
          child: Center(
            child: _buildCard(context, true, isCompactWidth: false),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(
    BuildContext context,
    bool isDesktop, {
    required bool isCompactWidth,
  }) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: GlassPanel(
        padding: EdgeInsets.all(
          isDesktop
              ? 40
              : isCompactWidth
              ? 18
              : 24,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          child: _sent
              ? _SuccessContent(
                  key: const ValueKey('success'),
                  email: _emailController.text.trim(),
                )
              : _RequestContent(
                  key: const ValueKey('request'),
                  formKey: _formKey,
                  controller: _emailController,
                  isDesktop: isDesktop,
                  isCompactWidth: isCompactWidth,
                  onSubmit: _submit,
                ),
        ),
      ),
    );
  }
}

class _RequestContent extends StatelessWidget {
  const _RequestContent({
    super.key,
    required this.formKey,
    required this.controller,
    required this.isDesktop,
    required this.isCompactWidth,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final bool isDesktop;
  final bool isCompactWidth;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const AppBackButton(),
              if (!isDesktop) ...[
                const SizedBox(width: 12),
                Flexible(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: PalletSortLogo(width: isCompactWidth ? 104 : 138),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(
            height: isDesktop
                ? 34
                : isCompactWidth
                ? 24
                : 30,
          ),
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: AppColors.cyan.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: AppColors.cyan.withValues(alpha: 0.2)),
            ),
            child: const Icon(
              Icons.lock_reset_rounded,
              color: AppColors.cyan,
              size: 29,
            ),
          ),
          SizedBox(height: isCompactWidth ? 18 : 22),
          Text(
            'Recuperar senha',
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              color: AppColors.white,
              fontSize: isCompactWidth ? 28 : 32,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Informe o e-mail da sua conta. Enviaremos as instruções para criar uma nova senha.',
            style: TextStyle(
              color: AppColors.slate400,
              fontSize: 15,
              height: 1.5,
            ),
          ),
          SizedBox(height: isCompactWidth ? 24 : 30),
          const Text(
            'E-mail',
            style: TextStyle(
              color: AppColors.slate200,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 9),
          TextFormField(
            key: const Key('recoveryEmailField'),
            controller: controller,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            autofillHints: const [AutofillHints.email],
            onFieldSubmitted: (_) => onSubmit(),
            style: const TextStyle(color: AppColors.white),
            decoration: const InputDecoration(
              hintText: 'nome@empresa.com',
              prefixIcon: Icon(Icons.alternate_email_rounded),
            ),
            validator: (value) {
              final email = value?.trim() ?? '';
              if (email.isEmpty) return 'Informe seu e-mail';
              final isValid = RegExp(
                r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
              ).hasMatch(email);
              if (!isValid) return 'Digite um e-mail válido';
              return null;
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: PrimaryActionButton(
              label: 'Enviar instruções',
              icon: Icons.send_rounded,
              onPressed: onSubmit,
            ),
          ),
          const SizedBox(height: 22),
          const _PrivacyNote(),
        ],
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({super.key, required this.email});

  final String email;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            color: AppColors.success.withValues(alpha: 0.12),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppColors.success.withValues(alpha: 0.24),
            ),
          ),
          child: const Icon(
            Icons.mark_email_read_rounded,
            color: AppColors.success,
            size: 36,
          ),
        ),
        const SizedBox(height: 26),
        Text(
          'Confira seu e-mail',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
            color: AppColors.white,
            fontSize: 31,
          ),
        ),
        const SizedBox(height: 14),
        Text(
          'Se houver uma conta vinculada a $email, você receberá as instruções em alguns instantes.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.slate400,
            fontSize: 15,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 30),
        SizedBox(
          width: double.infinity,
          child: PrimaryActionButton(
            label: 'Voltar ao login',
            icon: Icons.arrow_back_rounded,
            onPressed: () => Navigator.pop(context),
          ),
        ),
        const SizedBox(height: 22),
        const _PrivacyNote(),
      ],
    );
  }
}

class _PrivacyNote extends StatelessWidget {
  const _PrivacyNote();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.shield_outlined, color: AppColors.slate400, size: 16),
        SizedBox(width: 7),
        Flexible(
          child: Text(
            'Nunca solicitaremos sua senha por e-mail',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.slate400, fontSize: 12),
          ),
        ),
      ],
    );
  }
}
