import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _isLoading = false;
  bool _passwordsMatch = false;

  final _formKey = GlobalKey<FormState>();

  final _emailController = TextEditingController(text: 'opengoalz@pm.com');
  final _usernameController = TextEditingController(text: 'testAccount');
  final _passwordController = TextEditingController(text: 'defaultPassword');
  final _confirmPasswordController =
      TextEditingController(text: 'defaultPassword');

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
    // context.showSnackBar(
    //   'Creating account, please wait a few seconds...',
    //   icon: Icon(Icons.hourglass_top),
    // );
    setState(() {
      _isLoading = true;
    });
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      setState(() {
        _isLoading = false;
      });
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
      Navigator.of(context).pushAndRemoveUntil(
          LoginPage.route(username: username), (route) => false);
    } on AuthException catch (error) {
      context.showSnackBarError(error.message);
    } catch (error) {
      context.showSnackBarError(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
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
                onFieldSubmitted: (value) {
                  if (!_isLoading) {
                    _signUp();
                  }
                },
              ),
              formSpacer6,
              if (_isLoading)
                ElevatedButton(
                  onPressed: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // const SizedBox(
                      //   width: 24,
                      //   height: 24,
                      //   child: CircularProgressIndicator(),
                      // ),
                      CircularProgressIndicator(),
                      formSpacer6,
                      const Text(
                          'Creating account, please wait a few seconds...'),
                    ],
                  ),
                ),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: _isLoading ? null : _signUp,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.login),
                      formSpacer6,
                      const Text('Register'),
                    ],
                  ),
                ),
              formSpacer6,
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(LoginPage.route());
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.arrow_back_rounded),
                    formSpacer6,
                    const Text('I already have an account'),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
