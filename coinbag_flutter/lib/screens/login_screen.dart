import 'package:flutter/material.dart';
import '../domain/repositories/auth/auth_repository.dart';
import '../domain/auth/auth_failures.dart';
import '../core/service_locator.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;
  final bool allowSkip;
  const LoginScreen({Key? key, required this.onLogin, this.allowSkip = false})
    : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  String? _error;

  late AuthRepository _authRepository;

  @override
  void initState() {
    super.initState();
    _authRepository = getIt<AuthRepository>();
  }

  Future<void> _skip() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authRepository.signInMock('demo@example.com');
      widget.onLogin();
    } on AuthFailure catch (f) {
      if (mounted) {
        setState(() => _error = f.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authRepository.signIn(
        _emailController.text,
        _passwordController.text,
      );
      widget.onLogin();
    } on AuthFailure catch (f) {
      if (mounted) {
        setState(() => _error = f.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'An unexpected error occurred.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _signUp() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authRepository.signUp(
        _emailController.text,
        _passwordController.text,
      );
      widget.onLogin();
    } on AuthFailure catch (f) {
      if (mounted) {
        setState(() => _error = f.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'An unexpected error occurred during sign up.');
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _resetPassword() async {
    if (_emailController.text.isEmpty) {
      if (mounted) {
        setState(() => _error = 'Please enter your email to reset password.');
      }
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authRepository.resetPassword(_emailController.text);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset email sent. Please check your inbox.'),
        ),
      );
    } on AuthFailure catch (f) {
      if (mounted) {
        setState(() => _error = f.message);
      }
    } catch (e) {
      if (mounted) {
        setState(
          () =>
              _error = 'An unexpected error occurred while resetting password.',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: AutofillGroup(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'CoinBag Login',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 24),
                    TextField(
                      key: const Key('emailField'),
                      controller: _emailController,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      key: const Key('passwordField'),
                      controller: _passwordController,
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      autofillHints: const [AutofillHints.password],
                    ),
                    if (_error != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 4),
                        child: Text(
                          _error!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _loading ? null : _signIn,
                      child: _loading && _emailController.text.isNotEmpty
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign In'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      onPressed: _loading ? null : _signUp,
                      child: _loading && _emailController.text.isNotEmpty
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Sign Up'),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: _loading ? null : _resetPassword,
                      child: const Text('Forgot Password?'),
                    ),
                    if (widget.allowSkip) ...[
                      const SizedBox(height: 16),
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        onPressed: _loading ? null : _skip,
                        child: const Text('Skip Login (Demo)'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
