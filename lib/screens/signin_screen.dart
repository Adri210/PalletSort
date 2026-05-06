import 'package:flutter/material.dart';
import 'package:palletsort/widgets/welcome_button.dart';

// Substitua GoogleFonts por fonte local ou use o pacote correto

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          // Fundo azul
          Container(
            width: double.infinity,
            height: size.height * 0.6,
            child: Image.asset(
              'lib/assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          // Logo centralizado
          Positioned(
            top: size.height * 0.15,
            left: 0,
            right: 0,
            child: Center(
              child: Image.asset(
                'lib/assets/images/logo.png',
                width: size.width * 0.5,
                fit: BoxFit.contain,
              ),
            ),
          ),
          // Parte branca com curva
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipPath(
              clipper: WaveClipper(),
              child: Container(
                width: double.infinity,
                height: size.height * 0.45,
                color: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end, // força o botão para baixo
                  children: [
                    Text(
                      'Bem-Vindo',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: const Color.fromARGB(186, 0, 0, 0),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Lorem ipsum dolor sit amet consectetur. Lorem id sit',
                      style: TextStyle(
                        fontFamily: 'Rubik',
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24), // espaço pequeno antes do botão
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // botão à direita
                      children: [
                        SizedBox(
                          width: 180,
                          child: WelcomeButton(
                            buttonText: 'Continue',
                            onTap: () {},
                            iconImage: 'lib/assets/images/Icon.png',
                            textColor: Colors.grey,
                          ),
                        ),
                      ],
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

// CLIPPER PARA CURVA INFERIOR
class WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, 40);
    var firstControlPoint = Offset(size.width / 4, 0);
    var firstEndPoint = Offset(size.width / 2, 40);
    var secondControlPoint = Offset(3 * size.width / 4, 80);
    var secondEndPoint = Offset(size.width, 40);

    path.quadraticBezierTo(
        firstControlPoint.dx, firstControlPoint.dy, firstEndPoint.dx, firstEndPoint.dy);
    path.quadraticBezierTo(
        secondControlPoint.dx, secondControlPoint.dy, secondEndPoint.dx, secondEndPoint.dy);

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}