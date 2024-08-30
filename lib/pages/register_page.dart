import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'user_page.dart';
import 'login_page.dart';
import '../constants.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.isRegistering}) : super(key: key);

  static Route<void> route({bool isRegistering = false}) {
    return MaterialPageRoute(
      builder: (context) => RegisterPage(isRegistering: isRegistering),
    );
  }

  final bool isRegistering;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final bool _isLoading = false;
  bool _passwordsMatch = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
  }

  void _validatePasswords() {
    setState(() {
      _passwordsMatch =
          _passwordController.text == _confirmPasswordController.text;
    });
  }

  Future<void> _signUp() async {
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    final email = _emailController.text;
    final password = _passwordController.text;
    final username = _usernameController.text;
    try {
      await supabase.auth.signUp(
          email: email, password: password, data: {'username': username});
      context.showConfirmationDialog(
          'Please check your email to verify your account and start playing !');
      context.showSnackBarSuccess(
          'Please check your email to verify your account and start playing !');
      // Navigate back to the login page
      Navigator.of(context)
          .pushAndRemoveUntil(LoginPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showSnackBarError(error.message);
    } catch (error) {
      context.showSnackBarError(error.toString());
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Using Row widget to display widgets in a row
        title: Text('Please register to get your team !'),
      ),
      body: MaxWidthContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: formPadding,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  label: Text('Email'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  return null;
                },
                keyboardType: TextInputType.emailAddress,
              ),
              formSpacer6,
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  label: Text('Password'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if (val.length < 6) {
                    return '6 characters minimum';
                  }
                  return null;
                },
              ),
              formSpacer6,
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  label: Text('Confirm Password'),
                  errorText: _confirmPasswordController.text.isEmpty
                      ? null
                      : (_passwordsMatch ? null : 'Passwords do not match'),
                  errorStyle: TextStyle(color: Colors.red),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  if (val != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
              ),
              formSpacer6,
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  label: Text('Username'),
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) {
                    return 'Required';
                  }
                  final isValid = RegExp(r'^[A-Za-z0-9_]{3,24}$').hasMatch(val);
                  if (!isValid) {
                    return '3-24 long with alphanumeric or underscore';
                  }
                  return null;
                },
              ),
              formSpacer6,
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                child: const Text('Register'),
              ),
              formSpacer6,
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: const Text('I already have an account'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
