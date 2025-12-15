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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
            // Lottie Animation con manejo de errores robusto
            SizedBox(
              width: 250,
              height: 250,
              child: Lottie.asset(
                'assets/lottie/Cooking.json',
                fit: BoxFit.contain,
                repeat: true,
                animate: true,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback si la animación falla - usar icono directamente
                  return const Icon(
                    Icons.restaurant_menu,
                    size: 120,
                    color: Color(0xFFFF91A4),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // App Title
            Text(
              '౨ৎMi Álbum de Recetas౨ৎ',
              style: GoogleFonts.playfairDisplay(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: const Color(0xFFFF91A4),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              '౨ৎMi diario de recetas౨ৎ',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF8B7355),
                fontStyle: FontStyle.italic,
              ),
            ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

