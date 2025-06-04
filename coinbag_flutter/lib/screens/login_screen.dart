import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;
  final VoidCallback onLogin;
  final bool allowSkip;
  const LoginScreen({
    Key? key,
    required this.authService,
    required this.onLogin,
    this.allowSkip = false,
  }) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _skip() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    await widget.authService.signInMock('demo@example.com');
    widget.onLogin();
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signIn(_emailController.text, _passwordController.text);
      widget.onLogin();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await widget.authService.signUp(_emailController.text, _passwordController.text);
      widget.onLogin();
    } on AuthException catch (e) {
      setState(() => _error = e.message);
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final form = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            key: const Key('emailField'),
            controller: _emailController,
            decoration: const InputDecoration(labelText: 'Email'),
          ),
          TextField(
            key: const Key('passwordField'),
            controller: _passwordController,
            decoration: const InputDecoration(labelText: 'Password'),
            obscureText: true,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                _error!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          const SizedBox(height: 12),
          ElevatedButton(
            key: const Key('loginButton'),
            onPressed: _loading ? null : _signIn,
            child: const Text('Login'),
          ),
          TextButton(
            key: const Key('signupButton'),
            onPressed: _loading ? null : _signUp,
            child: const Text('Sign Up'),
          ),
          if (widget.allowSkip)
            TextButton(
              onPressed: _loading ? null : _skip,
              child: const Text('Skip'),
            )
        ],
      ),
      );
    return Stack(
      children: [
        form,
        if (_loading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }
}
