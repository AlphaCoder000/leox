import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sizer/sizer.dart';

class AnimatedSplashScreen extends StatefulWidget {
  final Widget child;
  final Duration duration;

  const AnimatedSplashScreen({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 3800),
  });

  @override
  State<AnimatedSplashScreen> createState() => _AnimatedSplashScreenState();
}

class _AnimatedSplashScreenState extends State<AnimatedSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  // Staggered animation elements
  late Animation<double> _engineersScale;
  late Animation<double> _engineersOpacity;

  late Animation<double> _bringsOpacity;
  late Animation<double> _bringsSlide;

  late Animation<double> _opusScale;
  late Animation<double> _opusOpacity;

  late Animation<double> _textSlide;
  late Animation<double> _textFade;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 2600),
      vsync: this,
    );

    // 1. Leo Engineers (scales/fades in from 0.0 to 0.4)
    _engineersScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOutBack),
      ),
    );
    _engineersOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
      ),
    );

    // 2. Brings transition (fades/slides in from 0.35 to 0.65)
    _bringsOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.6, curve: Curves.easeIn),
      ),
    );
    _bringsSlide = Tween<double>(begin: 15.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.65, curve: Curves.easeOut),
      ),
    );

    // 3. Leo Opus (scales/fades in from 0.55 to 0.85)
    _opusScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.85, curve: Curves.easeOutBack),
      ),
    );
    _opusOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.55, 0.8, curve: Curves.easeIn),
      ),
    );

    // 4. Subtitle / Heading (slides/fades in from 0.75 to 1.0)
    _textSlide = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 1.0, curve: Curves.easeOut),
      ),
    );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.75, 0.95, curve: Curves.easeIn),
      ),
    );

    // Start sequence execution
    _startSequence();
  }

  void _startSequence() async {
    _controller.forward();
    
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Background color: Pure white in light mode, ultra-premium Slate dark grey in dark mode
    final backgroundColor = isDark ? const Color(0xFF0F172A) : Colors.white; 
    
    // Logo Names Darker in light mode (pure solid black) and pure white in dark mode
    final subtitleColor = isDark ? Colors.grey[300] : const Color(0xFF334155); // Darker slate grey for subtitle



    // Shared clean bold corporate typography (Syncopate matches the modern geometric engineering logo style perfectly)
    final customFontFamily = GoogleFonts.syncopate().fontFamily;

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // 1. LEO ENGINEERS
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, -3.h),
                        child: Transform.scale(
                          scale: _engineersScale.value,
                          child: Opacity(
                            opacity: _engineersOpacity.value,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(2.w),
                                  decoration: BoxDecoration(
                                    color: isDark ? Colors.white.withValues(alpha: 0.03) : Colors.transparent,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Image.asset(
                                    'assets/icons/leo_engineers_logo.png',
                                    height: 18.h, // Bigger logo size
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                

                  // 2. BRINGS Transition text
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _bringsSlide.value),
                        child: Opacity(
                          opacity: _bringsOpacity.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 5.w),
                                child: Text(
                                  "BRINGS",
                                  style: TextStyle(
                                    fontSize: 15.sp, // Crisp size
                                    fontWeight: FontWeight.w300, // Faint weight
                                    fontStyle: FontStyle.italic,
                                    fontFamily: GoogleFonts.playfairDisplay().fontFamily,
                                    color: isDark ? Colors.white30 : const Color(0xFF94A3B8), // Faint and grey
                                    letterSpacing: 4.0,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 2.5.h),

                  // 3. LEO OPUS
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _opusScale.value,
                        child: Opacity(
                          opacity: _opusOpacity.value,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.08),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(24),
                                  child: Image.asset(
                                    'assets/icons/leo_Opus_logo.jpeg',
                                    height: 33.h, // Bigger logo size and centered
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                              SizedBox(height: 2.5.h),
                              RichText(
                                textAlign: TextAlign.center,
                                text: TextSpan(
                                  style: TextStyle(
                                    fontSize: 25.sp, // Premium big title
                                    fontWeight: FontWeight.bold,
                                    fontFamily: customFontFamily,
                                    letterSpacing: 3.5,
                                  ),
                                  children: const [
                                    TextSpan(
                                      text: "LEO",
                                      style: TextStyle(color: Color.fromARGB(255, 4, 44, 130)), // Premium blue color of L
                                    ),
                                    TextSpan(
                                      text: " ",
                                    ),
                                    TextSpan(
                                      text: "OPUS",
                                      style: TextStyle(color: Color.fromARGB(255, 16, 69, 182)), // Premium blue color of E
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: 2.h),

                  // 4. Subtitle / Heading
                  AnimatedBuilder(
                    animation: _controller,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _textSlide.value),
                        child: Opacity(
                          opacity: _textFade.value,
                          child: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 2.w),
                            child: Text(
                              "Hiring | Servicing",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17.sp, // Bigger font size
                                fontWeight: FontWeight.w600, // Slightly bolder for premium crisp readability
                                color: subtitleColor,
                                letterSpacing: 0.6,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
