import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Esperar 3 segundos y luego navegar
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        context.go('/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0), // Rosa pálido coquette
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Lottie Animation
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/lottie/cooking.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
              ),
            ),
            const SizedBox(height: 32),
            // App Title
            Text(
              'Mi Álbum de Recetas',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF91A4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Recetas coquette para tu cocina',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF8B7355),
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

