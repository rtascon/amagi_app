import 'package:flutter/material.dart';
import 'dart:async';

class LoadingScreen extends StatefulWidget {
  @override
  _LoadingScreenState createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400), // Duración de la animación de escala
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _startAnimation();
  }

  void _startAnimation() {
    _controller.forward().then((_) {
      _timer = Timer(Duration(milliseconds: 320), () { // Ajustar el tiempo de espera
        _controller.reverse().then((_) {
          _timer = Timer(Duration(milliseconds: 320), () {
            _startAnimation();
          });
        });
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF005586), Color(0xFF005586)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Image.asset(
                  'assets/a de Amagi Blanca.png',
                  width: 100,
                  height: 100,
                ),
              ),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height / 2 - 50 - 20, // Ajuste para que el círculo esté en la esquina superior derecha de la imagen
            left: MediaQuery.of(context).size.width / 2 + 25, // Ajuste para que el círculo esté en la esquina superior derecha de la imagen
            child: CircleAvatar(
              radius: 6, // Tamaño más pequeño del círculo
              backgroundColor: Color(0xFFE98300),
            ),
          ),
        ],
      ),
    );
  }
}