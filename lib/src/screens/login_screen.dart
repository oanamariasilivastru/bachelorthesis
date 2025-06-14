// lib/src/screens/login_screen.dart

import 'package:flutter/material.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/custom_button.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController    = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  String _errorMessage = '';

  Future<void> _login() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final token = await AuthService.login(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );

    setState(() => _isLoading = false);

    if (token != null) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() => _errorMessage = 'Autentificare eșuată. Verifică datele.');
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // same accent palette as document screen
    const primary   = Color(0xFF4A90E2);
    const secondary = Color(0xFF50E3C2);
    final radius = BorderRadius.circular(16);

    return Scaffold(
      body: Stack(
        children: [
          // 1) Full-screen background image
          Positioned.fill(
            child: Image.asset(
              'assets/images/login.png',
              fit: BoxFit.cover,
            ),
          ),

          // 2) Optional translucent overlay for contrast
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),

          // 3) Login form
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 400),
                  child: Column(
                    children: [
                      // logo
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.lock_outline, size: 60, color: primary),
                      ),
                      const SizedBox(height: 24),

                      // Card formular login
                      Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(borderRadius: radius),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // header
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 18,
                                    backgroundColor: secondary.withOpacity(0.2),
                                    child: Icon(Icons.person, color: secondary, size: 20),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    'Autentificare',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 24),

                              // email
                              CustomTextField(
                                controller: _emailController,
                                hintText: 'Email',
                                icon: Icons.email_outlined,
                              ),
                              const SizedBox(height: 16),

                              // parolă
                              CustomTextField(
                                controller: _passwordController,
                                hintText: 'Parolă',
                                icon: Icons.lock_outline,
                                obscureText: true,
                              ),
                              const SizedBox(height: 24),

                              // error message
                              if (_errorMessage.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: Text(
                                    _errorMessage,
                                    style: TextStyle(color: secondary),
                                    textAlign: TextAlign.center,
                                  ),
                                ),

                              // buton login
                              ElevatedButton.icon(
                                icon: _isLoading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(Icons.login),
                                label: Text(_isLoading ? 'Se încarcă...' : 'Login'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primary,
                                  shape: RoundedRectangleBorder(borderRadius: radius),
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: _isLoading ? null : _login,
                              ),

                              const SizedBox(height: 16),

                              // link register
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('Nu ai cont?', style: TextStyle(color: Colors.black54)),
                                  TextButton(
                                    onPressed: () => Navigator.pushReplacementNamed(context, '/register'),
                                    child: const Text('Înscrie-te'),
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
