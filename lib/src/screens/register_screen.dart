// lib/src/screens/register_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameCtrl     = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _phoneCtrl    = TextEditingController();
  final _passCtrl     = TextEditingController();
  final _confirmCtrl  = TextEditingController();

  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _register() async {
    if (_passCtrl.text != _confirmCtrl.text) {
      setState(() => _errorMessage = 'Parolele nu se potrivesc.');
      return;
    }
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _errorMessage = 'Completează numele complet.');
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final ok = await AuthService.register(
      fullName: _nameCtrl.text.trim(),
      email:    _emailCtrl.text.trim(),
      phone:    _phoneCtrl.text.trim(),
      password: _passCtrl.text,
    );

    setState(() => _isLoading = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      setState(() => _errorMessage = 'Înregistrare eșuată. Încearcă din nou.');
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // same palette as login
    const primary   = Color(0xFF4A90E2);
    const secondary = Color(0xFF50E3C2);
    final radius = BorderRadius.circular(16);

    return Scaffold(
      body: Stack(
        children: [
          // 1) Background
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),
          // 2) Dark overlay
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          // 3) Form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      // top circle icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [secondary, primary],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: Offset(0,4),
                            )
                          ],
                        ),
                        child: const Icon(
                          Icons.person_add,
                          size: 60,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // registration card
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: radius),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: secondary.withOpacity(0.2),
                                    child: Icon(Icons.person, color: secondary),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Înregistrează-te',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),

                              // full name
                              CustomTextField(
                                controller: _nameCtrl,
                                hintText: 'Nume complet',
                                icon: Icons.person_outline,
                              ),
                              const SizedBox(height: 16),

                              // email
                              CustomTextField(
                                controller: _emailCtrl,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 16),

                              // phone
                              CustomTextField(
                                controller: _phoneCtrl,
                                hintText: 'Telefon',
                                icon: Icons.phone_outlined,
                              ),
                              const SizedBox(height: 16),

                              // password
                              CustomTextField(
                                controller: _passCtrl,
                                hintText: 'Parolă',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 16),

                              // confirm password
                              CustomTextField(
                                controller: _confirmCtrl,
                                hintText: 'Confirmă parola',
                                icon: Icons.lock,
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),

                              // error
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: secondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              // register button
                              _isLoading
                                  ? const Center(child: CircularProgressIndicator())
                                  : CustomButton(
                                      text: 'Sign up',
                                      onPressed: _register,
                                    ),

                              const SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    'Ai deja cont?',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.pushReplacementNamed(
                                            context, '/login'),
                                    child: const Text(
                                      'Login',
                                      style: TextStyle(
                                          color: Colors.white,
                                          decoration: TextDecoration.underline),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
