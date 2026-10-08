import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:palletsort/screens/signin_screen.dart';
import 'package:palletsort/theme/theme.dart';
import 'package:palletsort/widgets/app_chrome.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final PageController _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  static const _features = [
    _Feature(
      title: 'Identificação em segundos',
      description:
          'Escaneie, reconheça e valide cada pallet com um fluxo simples e confiável.',
      eyebrow: 'Leitura inteligente',
      icon: Icons.qr_code_scanner_rounded,
      accent: AppColors.cyan,
    ),
    _Feature(
      title: 'Movimentação sob controle',
      description:
          'Acompanhe o histórico e saiba onde cada unidade está durante toda a operação.',
      eyebrow: 'Rastreabilidade',
      icon: Icons.route_rounded,
      accent: AppColors.blue,
    ),
    _Feature(
      title: 'Decisões mais rápidas',
      description:
          'Tenha uma operação organizada, com menos retrabalho e mais produtividade.',
      eyebrow: 'Alta performance',
      icon: Icons.bolt_rounded,
      accent: Color(0xFFFBBF24),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!_pageController.hasClients) return;
      final nextPage = (_currentPage + 1) % _features.length;
      _pageController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _openSignIn() {
    Navigator.push(
      context,
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BrandBackground(
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isDesktop = constraints.maxWidth >= 900;
              final isCompactWidth = constraints.maxWidth < 360;
              final isCompactHeight = constraints.maxHeight < 600;
              final horizontalPadding = isDesktop
                  ? 40.0
                  : isCompactWidth
                  ? 12.0
                  : 20.0;
              final verticalPadding = isCompactHeight ? 12.0 : 24.0;
              final availableHeight = math.max(
                constraints.maxHeight - (verticalPadding * 2),
                isDesktop ? 680.0 : 720.0,
              );

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  verticalPadding,
                  horizontalPadding,
                  verticalPadding,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1180),
                    child: isDesktop
                        ? SizedBox(
                            height: availableHeight,
                            child: _buildDesktopLayout(context),
                          )
                        : Align(
                            alignment: Alignment.topCenter,
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                maxWidth: 620,
                                minHeight: math.max(
                                  constraints.maxHeight - (verticalPadding * 2),
                                  0,
                                ),
                              ),
                              child: _buildMobileLayout(
                                context,
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

  Widget _buildDesktopLayout(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: const [
            PalletSortLogo(width: 174),
            SectionLabel(
              text: 'Gestão inteligente de pallets',
              icon: Icons.auto_awesome_rounded,
            ),
          ],
        ),
        const SizedBox(height: 38),
        Expanded(
          child: Row(
            children: [
              Expanded(
                flex: 10,
                child: Padding(
                  padding: const EdgeInsets.only(right: 52),
                  child: _HeroContent(onPressed: _openSignIn, isDesktop: true),
                ),
              ),
              Expanded(
                flex: 9,
                child: Column(
                  children: [
                    Expanded(child: _buildCarousel()),
                    const SizedBox(height: 22),
                    _PageIndicator(
                      count: _features.length,
                      currentPage: _currentPage,
                      onSelected: _goToPage,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
    BuildContext context, {
    required bool isCompactWidth,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Flexible(
              child: Align(
                alignment: Alignment.centerLeft,
                child: PalletSortLogo(width: isCompactWidth ? 118 : 148),
              ),
            ),
            const SizedBox(width: 12),
            _LiveBadge(compact: isCompactWidth),
          ],
        ),
        SizedBox(height: isCompactWidth ? 28 : 36),
        _HeroContent(
          onPressed: _openSignIn,
          isDesktop: false,
          isCompactWidth: isCompactWidth,
        ),
        SizedBox(height: isCompactWidth ? 24 : 30),
        SizedBox(height: 400, child: _buildCarousel()),
        const SizedBox(height: 20),
        Center(
          child: _PageIndicator(
            count: _features.length,
            currentPage: _currentPage,
            onSelected: _goToPage,
          ),
        ),
      ],
    );
  }

  Widget _buildCarousel() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _features.length,
      onPageChanged: (page) => setState(() => _currentPage = page),
      itemBuilder: (_, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: _FeatureCard(feature: _features[index], index: index),
      ),
    );
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
    );
  }
}

class _HeroContent extends StatelessWidget {
  const _HeroContent({
    required this.onPressed,
    required this.isDesktop,
    this.isCompactWidth = false,
  });

  final VoidCallback onPressed;
  final bool isDesktop;
  final bool isCompactWidth;

  @override
  Widget build(BuildContext context) {
    final titleSize = isDesktop
        ? 58.0
        : isCompactWidth
        ? 31.0
        : 36.0;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isDesktop) ...[
          const SectionLabel(text: 'Gestão inteligente'),
          SizedBox(height: isCompactWidth ? 16 : 20),
        ],
        Text(
          'Pallets organizados.\nOperação em movimento.',
          style: Theme.of(context).textTheme.displayLarge?.copyWith(
            color: AppColors.white,
            fontSize: titleSize,
          ),
        ),
        SizedBox(height: isCompactWidth ? 16 : 20),
        Text(
          'Identifique, rastreie e gerencie seus pallets com precisão — do recebimento à expedição.',
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: AppColors.slate400,
            fontSize: isDesktop ? 18 : 15,
          ),
        ),
        SizedBox(
          height: isDesktop
              ? 34
              : isCompactWidth
              ? 20
              : 26,
        ),
        SizedBox(
          width: isDesktop ? 280 : double.infinity,
          child: PrimaryActionButton(
            label: 'Começar agora',
            onPressed: onPressed,
          ),
        ),
        if (isDesktop) ...[
          const SizedBox(height: 34),
          const Wrap(
            spacing: 20,
            runSpacing: 12,
            children: [
              _TrustItem(icon: Icons.speed_rounded, label: 'Fluxo ágil'),
              _TrustItem(
                icon: Icons.verified_user_outlined,
                label: 'Dados seguros',
              ),
              _TrustItem(
                icon: Icons.devices_rounded,
                label: 'Em qualquer tela',
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.feature, required this.index});

  final _Feature feature;
  final int index;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isCompact = constraints.maxWidth < 320;
        return GlassPanel(
          padding: EdgeInsets.all(isCompact ? 20 : 28),
          child: LayoutBuilder(
            builder: (context, innerConstraints) {
              return SingleChildScrollView(
                primary: false,
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: innerConstraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: isCompact ? 48 : 54,
                              height: isCompact ? 48 : 54,
                              decoration: BoxDecoration(
                                color: feature.accent.withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(17),
                                border: Border.all(
                                  color: feature.accent.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Icon(
                                feature.icon,
                                color: feature.accent,
                                size: isCompact ? 24 : 27,
                              ),
                            ),
                            Text(
                              '0${index + 1}',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.18),
                                fontSize: isCompact ? 28 : 32,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Text(
                          feature.eyebrow.toUpperCase(),
                          style: TextStyle(
                            color: feature.accent,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: isCompact ? 0.8 : 1.2,
                          ),
                        ),
                        const SizedBox(height: 11),
                        Text(
                          feature.title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: AppColors.white,
                                fontSize: isCompact ? 21 : 24,
                              ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          feature.description,
                          style: TextStyle(
                            color: AppColors.slate400,
                            height: 1.45,
                            fontSize: isCompact ? 13 : 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({
    required this.count,
    required this.currentPage,
    required this.onSelected,
  });

  final int count;
  final int currentPage;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (index) {
        final selected = currentPage == index;
        return Semantics(
          button: true,
          selected: selected,
          label: 'Ver destaque ${index + 1}',
          child: InkWell(
            onTap: () => onSelected(index),
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: selected ? 34 : 10,
              height: 8,
              margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.cyan : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 9 : 10, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, color: AppColors.success, size: 8),
          if (!compact) ...[
            const SizedBox(width: 7),
            const Text(
              'ONLINE',
              style: TextStyle(
                color: AppColors.slate200,
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrustItem extends StatelessWidget {
  const _TrustItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.cyan, size: 18),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(color: AppColors.slate400)),
      ],
    );
  }
}

class _Feature {
  const _Feature({
    required this.title,
    required this.description,
    required this.eyebrow,
    required this.icon,
    required this.accent,
  });

  final String title;
  final String description;
  final String eyebrow;
  final IconData icon;
  final Color accent;
}
