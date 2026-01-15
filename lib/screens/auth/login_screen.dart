import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  final String? role;

  const LoginScreen({super.key, this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  UserRole _getRoleFromString(String? role) {
    switch (role?.toLowerCase()) {
      case 'official':
        return UserRole.official;
      case 'admin':
        return UserRole.admin;
      default:
        return UserRole.citizen;
    }
  }

  String _getRoleName() {
    switch (widget.role?.toLowerCase()) {
      case 'official':
        return 'Official';
      case 'admin':
        return 'Administrator';
      default:
        return 'Citizen';
    }
  }

  Color _getRoleColor() {
    switch (widget.role?.toLowerCase()) {
      case 'official':
        return AppTheme.primaryColor;
      case 'admin':
        return AppTheme.mediumPriority;
      default:
        return AppTheme.primaryOrange;
    }
  }

  Future<void> _handleLogin() async {
    final role = _getRoleFromString(widget.role);
    
    // Citizens use Google Sign-In
    if (role == UserRole.citizen) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.signInWithGoogle();
      
      if (success && mounted) {
        context.go('/citizen-home');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Google Sign-In failed. Please ensure:\n'
                '1. SHA-1 fingerprint is added in Firebase Console\n'
                '2. Google Sign-In is enabled in Firebase Authentication\n'
                'For now, you can test with Official or Admin login.'),
            duration: const Duration(seconds: 6),
            backgroundColor: Colors.red.shade700,
            action: SnackBarAction(
              label: 'OK',
              textColor: Colors.white,
              onPressed: () {},
            ),
          ),
        );
      }
      return;
    }
    
    // Officials and Admins use email/password
    if (_formKey.currentState!.validate()) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.loginOfficial(
        _emailController.text,
        _passwordController.text,
        role,
      );

      if (success && mounted) {
        switch (widget.role?.toLowerCase()) {
          case 'official':
            context.go('/official-home');
            break;
          case 'admin':
            context.go('/admin-dashboard');
            break;
          default:
            context.go('/citizen-home');
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid credentials')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final roleColor = _getRoleColor();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/role-selection'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 20),
                // Role Badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: roleColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        widget.role?.toLowerCase() == 'official'
                            ? Icons.engineering
                            : widget.role?.toLowerCase() == 'admin'
                                ? Icons.admin_panel_settings
                                : Icons.person,
                        color: roleColor,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getRoleName(),
                        style: TextStyle(
                          color: roleColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Text(
                  'Welcome Back!',
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to continue',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                ),
                const SizedBox(height: 48),
                // Email Field (only for officials and admins)
                if (widget.role?.toLowerCase() != 'citizen') ...[
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
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
                  const SizedBox(height: 20),
                  // Password Field
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility_off
                              : Icons.visibility,
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
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // TODO: Implement forgot password
                      },
                      child: Text(
                        'Forgot Password?',
                        style: TextStyle(color: roleColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Google Sign-In button for citizens
                if (widget.role?.toLowerCase() == 'citizen') ...[
                  Text(
                    'Sign in with your Google account to continue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],
                
                // Login Button
                Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    return ElevatedButton(
                      onPressed: auth.isLoading ? null : _handleLogin,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: roleColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        minimumSize: const Size(double.infinity, 56),
                      ),
                      child: auth.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                if (widget.role?.toLowerCase() == 'citizen')
                                  Image.asset(
                                    'assets/images/google_logo.png',
                                    height: 24,
                                    width: 24,
                                    errorBuilder: (context, error, stackTrace) {
                                      return const Icon(Icons.login, color: Colors.white);
                                    },
                                  ),
                                if (widget.role?.toLowerCase() == 'citizen')
                                  const SizedBox(width: 12),
                                Text(
                                  widget.role?.toLowerCase() == 'citizen'
                                      ? 'Sign in with Google'
                                      : 'Sign In',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                // Demo Credentials Hint (only for officials/admins)
                if (widget.role?.toLowerCase() != 'citizen')
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.lightOrange,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Icon(
                              Icons.info_outline,
                              color: AppTheme.darkOrange,
                              size: 20,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'For Officials & Admins',
                              style: TextStyle(
                                color: AppTheme.darkOrange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Accounts are created by administrators. Contact your department for credentials.',
                          style: TextStyle(
                            color: AppTheme.darkOrange,
                            fontSize: 13,
                          ),
                        ),
                      ],
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