import 'package:flutter/material.dart';
import 'package:palletsort/theme/theme.dart';

class BrandBackground extends StatelessWidget {
  const BrandBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navy800, AppColors.navy950, Color(0xFF050B14)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -170,
          right: -110,
          child: _GlowOrb(
            size: 440,
            color: AppColors.cyan.withValues(alpha: 0.13),
          ),
        ),
        Positioned(
          bottom: -220,
          left: -160,
          child: _GlowOrb(
            size: 520,
            color: AppColors.blue.withValues(alpha: 0.11),
          ),
        ),
        Positioned.fill(
          child: IgnorePointer(child: CustomPaint(painter: _GridPainter())),
        ),
        child,
      ],
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)]),
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.025)
      ..strokeWidth = 1;
    const spacing = 72.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class PalletSortLogo extends StatelessWidget {
  const PalletSortLogo({super.key, this.width = 164});

  final double width;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'PalletSort',
      image: true,
      child: Image.asset(
        'lib/assets/images/logo.png',
        width: width,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}

class GlassPanel extends StatelessWidget {
  const GlassPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(32),
    this.radius = 28,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.055),
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 40,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: child,
    );
  }
}

class SectionLabel extends StatelessWidget {
  const SectionLabel({super.key, required this.text, this.icon});

  final String text;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.cyan.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cyan.withValues(alpha: 0.22)),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 15, color: AppColors.cyan),
              const SizedBox(width: 7),
            ],
            Text(
              text.toUpperCase(),
              maxLines: 1,
              style: const TextStyle(
                color: AppColors.cyan,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PrimaryActionButton extends StatelessWidget {
  const PrimaryActionButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward_rounded,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [AppColors.cyanDark, AppColors.blue],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.cyan.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          elevation: 0,
          shadowColor: Colors.transparent,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.white,
          disabledBackgroundColor: Colors.transparent,
          disabledForegroundColor: Colors.white54,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: 10),
              Icon(icon, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class AppBackButton extends StatelessWidget {
  const AppBackButton({super.key, this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Voltar',
      onPressed: onPressed ?? () => Navigator.maybePop(context),
      icon: const Icon(Icons.arrow_back_rounded),
      color: AppColors.white,
      style: IconButton.styleFrom(
        backgroundColor: Colors.white.withValues(alpha: 0.07),
        side: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
      ),
    );
  }
}

class AuthVisualPanel extends StatelessWidget {
  const AuthVisualPanel({
    super.key,
    required this.title,
    required this.description,
    required this.features,
  });

  final String title;
  final String description;
  final List<(IconData, String)> features;

  @override
  Widget build(BuildContext context) {
    return GlassPanel(
      padding: const EdgeInsets.all(48),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const PalletSortLogo(width: 180),
          const SizedBox(height: 52),
          const SectionLabel(
            text: 'Operação conectada',
            icon: Icons.hub_outlined,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              color: AppColors.white,
              fontSize: 46,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            description,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: AppColors.slate400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 38),
          ...features.map(
            (feature) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.cyan.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(feature.$1, color: AppColors.cyan, size: 19),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(
                      feature.$2,
                      style: const TextStyle(
                        color: AppColors.slate200,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
