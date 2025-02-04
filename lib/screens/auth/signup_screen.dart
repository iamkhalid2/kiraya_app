import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import '../../providers/auth_provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!mounted) return;
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        setState(() => _errorMessage = 'Passwords do not match');
        return;
      }

      try {
        if (!mounted) return;
        setState(() => _errorMessage = null);
        final authProvider = context.read<AuthProvider>();
        
        try {
          await authProvider.signUpWithEmail(
            _emailController.text.trim(),
            _passwordController.text,
          );
          // Pop back to login screen after successful registration
          if (!mounted) return;
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          }
        } on FirebaseAuthException catch (e) {
          print('Firebase Auth Error: ${e.code} - ${e.message}');
          if (!mounted) return;
          
          String message;
          switch (e.code) {
            case 'weak-password':
              message = 'Password is too weak. Please use a stronger password.';
              break;
            case 'email-already-in-use':
              message = 'An account already exists with this email.';
              break;
            case 'invalid-email':
              message = 'Please enter a valid email address.';
              break;
            case 'operation-not-allowed':
              message = 'Email/password sign up is not enabled.';
              break;
            default:
              message = e.message ?? 'An error occurred during sign up';
          }
          setState(() => _errorMessage = message);
        }
      } catch (e) {
        print('Unexpected error: $e');
        if (!mounted) return;
        setState(() => _errorMessage = 'An unexpected error occurred');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Up'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Create Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 32),
                if (_errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!value.contains('@')) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_isPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isPasswordVisible = !_isPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: !_isConfirmPasswordVisible,
                  decoration: InputDecoration(
                    labelText: 'Confirm Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isConfirmPasswordVisible
                            ? Icons.visibility
                            : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your password';
                    }
                    if (value != _passwordController.text) {
                      return 'Passwords do not match';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: authProvider.isLoading ? null : _signUp,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: authProvider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Sign Up'),
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Already have an account? Sign In'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
