import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    this.onTap,
    this.textColor = Colors.black87, // texto escuro
    this.iconImage, // nova propriedade para a imagem do ícone
  });

  final String buttonText;
  final VoidCallback? onTap;
  final Color textColor;
  final String? iconImage; // caminho da imagem do ícone

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 60,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Texto do botão
            Text(
              buttonText,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            // Ícone como imagem
            CircleAvatar(
              radius: 20, // tamanho do círculo
              backgroundColor: Colors.transparent, // fundo transparente
              child: iconImage != null
                  ? Image.asset(
                      iconImage!,
                      width: 24, // largura da imagem
                      height: 24, // altura da imagem
                      fit: BoxFit.contain,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}