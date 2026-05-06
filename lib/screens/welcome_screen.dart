import 'package:flutter/material.dart';
import 'package:palletsort/widgets/welcome_button.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> with SingleTickerProviderStateMixin {
  // Para controlar a animação de entrada do card branco
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Inicia a animação após o primeiro frame
    Future.delayed(const Duration(milliseconds: 300), () {
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fundo com leve Zoom (Parallax effect manual)
          AnimatedContainer(
            duration: const Duration(seconds: 2),
            curve: Curves.easeOut,
            width: double.infinity,
            height: size.height,
            transform: Matrix4.identity()..scale(_visible ? 1.05 : 1.15),
            child: Image.asset(
              'lib/assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2. Logo com animação de flutuação (Floating)
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: TweenAnimationBuilder(
              tween: Tween<double>(begin: 0, end: 10),
              duration: const Duration(seconds: 2),
              builder: (context, double value, child) {
                return Transform.translate(
                  offset: Offset(0, value), // Faz o logo subir e descer
                  child: child,
                );
              },
              onEnd: () {
                // Loop da animação de flutuação (opcional, mas legal)
              },
              child: Center(
                child: Image.asset(
                  'lib/assets/images/logo.png',
                  width: size.width * 0.55,
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // 3. Parte branca com curva e animação de subida
          AnimatedPositioned(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutQuart,
            bottom: _visible ? 0 : -size.height * 0.5, // Começa escondido embaixo
            left: 0,
            right: 0,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                width: double.infinity,
                height: size.height * 0.47,
                color: Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60), // Espaço para a curva
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30),
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 1000),
                        opacity: _visible ? 1 : 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Bem-Vindo',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Organize seus paletes de forma inteligente e rápida. Comece agora sua jornada.',
                              style: TextStyle(
                                fontFamily: 'Rubik',
                                fontSize: 16,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    // Botão com Padding e alinhamento
                    Padding(
                      padding: const EdgeInsets.only(right: 20, bottom: 30),
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: AnimatedScale(
                          duration: const Duration(milliseconds: 500),
                          scale: _visible ? 1 : 0.8,
                          child: SizedBox(
                            width: 180,
                            child: WelcomeButton(
                              buttonText: 'Continuar',
                              onTap: () {
                                // Adicione um feedback tátil ou navegação aqui
                              },
                              iconImage: 'lib/assets/images/Icon.png',
                              textColor: Colors.blueAccent, // Cor mais viva
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// O seu WaveClipper permanece o mesmo, ele já é ótimo!
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 40);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 40);
    var secondControlPoint = Offset(3 * size.width / 4, 80);
    var secondEndPoint = Offset(size.width, 40);

    path.quadraticBezierTo(firstControlPoint.dx, firstControlPoint.dy,
        firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(secondControlPoint.dx, secondControlPoint.dy,
        secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}