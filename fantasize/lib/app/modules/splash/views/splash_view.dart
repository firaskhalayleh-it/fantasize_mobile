import 'dart:math' as math;
import 'package:fantasize/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onVerticalDragUpdate: (details) => controller.updateOffset(details.delta.dy),
        onVerticalDragEnd: (details) {
          if (details.primaryVelocity!.abs() > 1000) {
            controller.navigateToHome();
          } else {
            controller.resetPosition();
            // The following line seems unused; consider removing or utilizing it
            // final IconData icon = Icons.circle;
          }
        },
        child: Stack(
          children: [
            // Simple gradient background
            const LuxuryBackground(),
            
            // Modified particles effect
            const ParticlesEffect(),

            // Main Content
            Obx(() => Center(
              child: Transform.translate(
                offset: Offset(0, controller.dragOffset.value),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Welcome Text
                    const FadeInText(
                      text: "WELCOME",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        letterSpacing: 8,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    
                    const SizedBox(height: 60),
                    
                    // Logo
                    const AnimatedLogo(),
                    
                    const SizedBox(height: 60),
                    
                    // Swipe text
                    Text(
                      "SWIPE UP",
                      style: TextStyle(
                        color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
                        fontSize: 16,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ],
                ),
              ),
            )),

            // Simple arrow indicator
            Positioned(
              bottom: 40,
              left: 0,
              right: 0,
              child: Obx(() => Opacity(
                opacity: (1 - (controller.dragOffset.value.abs() / 200)).clamp(0.0, 1.0),
                child: const SwipeIndicator(),
              )),
            ),
          ],
        ),
      ),
    );
  }
}

class LuxuryBackground extends StatelessWidget {
  const LuxuryBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 2,
          colors: [
            const Color.fromARGB(255, 238, 102, 102).withOpacity(0.7),
            Colors.black,
          ],
          stops: const [0.0, 0.6],
        ),
      ),
    );
  }
}

class ParticlesEffect extends StatefulWidget {
  const ParticlesEffect({super.key});

  @override
  State<ParticlesEffect> createState() => _ParticlesEffectState();
}

class _ParticlesEffectState extends State<ParticlesEffect>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 4),
    vsync: this,
  )..repeat();

  // Updated to generate 25 particles instead of 40
  final List<Particle> _particles = List.generate(25, (_) => Particle());

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Stack(
        children: _particles.map((particle) {
          return Positioned(
            left: particle.x * Get.width,
            top: ((particle.y + _controller.value * particle.speed) % 1.0) * Get.height,
            child: Transform.rotate(
              angle: particle.rotation + (_controller.value * math.pi * particle.rotationSpeed),
              child: Icon(
                particle.icon,
                size: particle.size,
                color: const Color.fromARGB(255, 250, 249, 249).withOpacity(
                  0.2 * (math.sin(_controller.value * 2 * math.pi + particle.x * 10) + 1) / 2,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class Particle {
  final double x = math.Random().nextDouble();
  final double y = math.Random().nextDouble();
  final double speed = math.Random().nextDouble() * 0.3 + 0.1;
  final double size = math.Random().nextDouble() * 15 + 43; // Updated size range
  final double rotation = math.Random().nextDouble() * math.pi * 2;
  final double rotationSpeed = (math.Random().nextDouble() - 0.5) * 5;
  final IconData icon;

  Particle() : icon = _getRandomIcon();

  static IconData _getRandomIcon() {
    final icons = [
      Icons.card_giftcard,
      Icons.redeem,
      Icons.shopping_bag,
      Icons.favorite,
      Icons.star,
      Icons.local_mall,
      Icons.wallet_giftcard,
      Icons.celebration,
    ];
    return icons[math.Random().nextInt(icons.length)];
  }
}

class AnimatedLogo extends StatefulWidget {
  const AnimatedLogo({super.key});

  @override
  State<AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 2),
    vsync: this,
  )..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) => Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          
        
        ),
        child: Transform.scale(
          scale: 0.95 + (0.05 * _controller.value),
          child: Image.asset(
            'assets/icons/fantasize_logo.png',
            width: 180,
            height: 180,
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class FadeInText extends StatefulWidget {
  final String text;
  final TextStyle style;

  const FadeInText({
    super.key,
    required this.text,
    required this.style,
  });

  @override
  State<FadeInText> createState() => _FadeInTextState();
}

class _FadeInTextState extends State<FadeInText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1000),
    vsync: this,
  )..forward();

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Text(
        widget.text,
        style: widget.style,
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class SwipeIndicator extends StatefulWidget {
  const SwipeIndicator({super.key});

  @override
  State<SwipeIndicator> createState() => _SwipeIndicatorState();
}

class _SwipeIndicatorState extends State<SwipeIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(seconds: 1),
    vsync: this,
  )..repeat(reverse: true);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) => Transform.translate(
        offset: Offset(0, -5 + (10 * _controller.value)),
        child: Icon(
          Icons.keyboard_arrow_up,
          color: const Color.fromARGB(255, 216, 202, 202).withOpacity(0.8),
          size: 36,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
