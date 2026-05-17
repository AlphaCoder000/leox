import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedSplashScreen({
    super.key,
    required this.child,
    this.duration = const Duration(seconds: 3),
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  //late AnimationController _particleController;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;

  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    // Logo animations
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // Logo animations
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );

    // Text animations
    _textSlide = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutBack),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _textController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );

    // Start animations
    _startAnimations();
  }

  void _startAnimations() async {
    // Start logo animation immediately
    _logoController.forward();

    // Wait a bit, then start text animation
    await Future.delayed(const Duration(milliseconds: 300));
    _textController.forward();

    // Navigate to main app after duration
    await Future.delayed(widget.duration);
    if (mounted) {
      _navigateToMain();
    }
  }

  void _navigateToMain() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => widget.child,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _logoController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF1A237E),
                  const Color(0xFF0D47A1),
                  const Color(0xFF1565C0),
                  const Color(0xFF1976D2),
                ],
                stops: const [0.0, 0.5, 0.7, 1.0],
              ),
            ),
            child: Stack(
              children: [
                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo with animation
                      AnimatedBuilder(
                        animation: _logoController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _logoScale.value,
                            child: Opacity(
                              opacity: _logoOpacity.value,
                              child: Image.asset(
                                'assets/icons/leo_Opus_logo.jpeg',
                                width: 80.w, // Bigger size without white box
                                fit: BoxFit.contain,
                              ),
                            ),
                          );
                        },
                      ),

                      SizedBox(height: 3.h),

                      // App name with animation
                      AnimatedBuilder(
                        animation: _textController,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, _textSlide.value),
                            child: Opacity(
                              opacity: _textFade.value,
                              child: Column(
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 28.sp,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                        letterSpacing: 1.2,
                                        shadows: [
                                          Shadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.3,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 2),
                                          ),
                                        ],
                                      ),
                                      children: const [
                                        TextSpan(
                                          text: 'LEO',
                                          style: TextStyle(
                                            color: Color.fromARGB(255, 37, 84, 223),
                                          ),
                                        ),
                                        TextSpan(text: ' '),
                                        TextSpan(
                                          text: 'Opus',
                                          style: TextStyle(
                                            color: Color(0xFF3374D9),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(height: 3.h),
                                  Center(
                                    child: Text(
                                      'Hiring platform along with maintenance contracts',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontSize: 17.sp,
                                        fontWeight: FontWeight.w300,
                                        color: Colors.white.withValues(
                                          alpha: 0.8,
                                        ),
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

}
