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

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String? _emailError;
  String? _usernameError;
  String? _passwordError;
  String? _confirmPasswordError;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_validatePasswords);
    _confirmPasswordController.addListener(_validatePasswords);
    _emailController.addListener(_validateEmail);
    _usernameController.addListener(_validateUsername);
  }

  void _validateEmail() async {
    final emailRegex = RegExp(
        r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");
    print('Email validation triggered: [${_emailController.text}]');

    if (!emailRegex.hasMatch(_emailController.text)) {
      setState(() {
        _emailError = 'Please enter a valid email address';
      });
    } else {
      // Check if email exists in the database
      final response = await supabase
          .from('profiles')
          .select('email')
          .ilike('email', _emailController.text)
          .maybeSingle();

      setState(() {
        if (response != null) {
          _emailError = 'Email already exists';
        } else {
          _emailError = null;
        }
      });
    }
  }

  void _validateUsername() async {
    final username = _usernameController.text;
    String? usernameError;

    if (username.isEmpty) {
      usernameError = 'Username is required';
    } else if (username.length < 3) {
      usernameError = 'Username must be at least 3 characters';
    } else if (username.length > 24) {
      usernameError = 'Username cannot exceed 24 characters';
    } else {
      const forbiddenChars = [
        '!',
        '@',
        '#',
        '\$',
        '%',
        '^',
        '&',
        '*',
        '(',
        ')',
        '+',
        '=',
        '-',
        '`',
        '~',
        '[',
        ']',
        '{',
        '}',
        '|',
        '\\',
        ';',
        ':',
        '"',
        ',',
        '<',
        '.',
        '>',
        '/',
        '?'
      ];
      final foundChar = forbiddenChars.firstWhere(
          (char) => username.contains(char),
          orElse: () => ''); // Use firstWhere with orElse
      if (foundChar.isNotEmpty) {
        usernameError = '[$foundChar] is invalid in usernames';
      } else {
        // Check if username exists in the database
        final response = await supabase
            .from('profiles')
            .select('username')
            .ilike('username', username)
            .maybeSingle();

        if (response != null) {
          usernameError = 'Username already exists';
        } else {
          usernameError = null;
        }
      }
    }

    setState(() {
      _usernameError = usernameError;
    });
  }

  void _validatePasswords() {
    setState(() {
      final password = _passwordController.text;
      final confirmPassword = _confirmPasswordController.text;

      if (password.isEmpty) {
        _passwordError = 'Password is required';
      } else if (password.length < 6) {
        _passwordError = 'Password must be at least 6 characters';
      } else {
        _passwordError = null;
      }

      if (confirmPassword.isEmpty) {
        _confirmPasswordError = 'Confirm Password is required';
      } else if (confirmPassword != password) {
        _confirmPasswordError = 'Passwords do not match';
      } else {
        _confirmPasswordError = null;
      }
    });
  }

  Future<void> _signUp() async {
    // Check if the form is valid before proceeding
    if (_isLoading) return; // Prevent multiple submissions
    /// Redundant validation calls
    _validateUsername();
    _validateEmail();
    _validatePasswords();
    if (!await _validateFormFields()) return;

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
      // Navigate back to the login page
      Navigator.of(context).pushAndRemoveUntil(
          LoginPage.route(username: username), (route) => false);
    } on AuthException catch (error) {
      print('AuthException: ${error.message}');
      if (error.message.contains('Error sending confirmation email')) {
        context.showSnackBarError(
            'There was an issue sending the confirmation email. Please check email adress or try again later.');
      } else {
        context.showSnackBarError(error.message);
      }
    } catch (error) {
      context.showSnackBarError(error.toString());
    }
    setState(() {
      _isLoading = false;
    });
  }

  bool _validateFormFields() {
    final errors = [
      _emailError,
      _usernameError,
      _passwordError,
      _confirmPasswordError
    ];

    if (errors.any((error) => error != null)) {
      context.showSnackBarError(errors.firstWhere((error) => error != null)!);
      return false;
    }
    return true;
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
        title: Text(
          'Please register to get your team !',
          style: TextStyle(fontSize: fontSizeLarge, fontWeight: FontWeight.bold),
        ),
      ),
      body: MaxWidthContainer(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: formPadding,
            children: [
              /// Email
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  labelStyle: TextStyle(fontSize: fontSizeMedium),
                  hintText: 'Enter your email address',
                  hintStyle: TextStyle(fontSize: fontSizeSmall),
                  prefixIcon: Icon(Icons.email, size: iconSizeMedium,
                      color: _emailError == null ? Colors.green : Colors.red),
                  errorText: _emailController.text.isEmpty ? null : _emailError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: fontSizeSmall),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                ),
                style: TextStyle(fontSize: fontSizeMedium),
                keyboardType: TextInputType.emailAddress,
              ),
              formSpacer6,

              /// Username
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(
                  labelText: 'Username',
                  labelStyle: TextStyle(fontSize: fontSizeMedium),
                  prefixIcon: Icon(iconUser, size: iconSizeMedium,
                      color:
                          _usernameError == null ? Colors.green : Colors.red),
                  hintText: 'Enter your username',
                  hintStyle: TextStyle(fontSize: fontSizeSmall),
                  errorText:
                      _usernameController.text.isEmpty ? null : _usernameError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: fontSizeSmall),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                ),
                style: TextStyle(fontSize: fontSizeMedium),
              ),
              formSpacer6,

              /// Password
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Password',
                  labelStyle: TextStyle(fontSize: fontSizeMedium),
                  hintText: 'Enter your password',
                  hintStyle: TextStyle(fontSize: fontSizeSmall),
                  prefixIcon: Icon(Icons.lock, size: iconSizeMedium,
                      color:
                          _passwordError == null ? Colors.green : Colors.red),
                  errorText:
                      _passwordController.text.isEmpty ? null : _passwordError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: fontSizeSmall),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                ),
                style: TextStyle(fontSize: fontSizeMedium),
                validator: (val) {
                  return null;
                },
              ),
              formSpacer6,

              /// Confirm Password
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: true,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  labelStyle: TextStyle(fontSize: fontSizeMedium),
                  hintText: 'Re-enter your password',
                  hintStyle: TextStyle(fontSize: fontSizeSmall),
                  prefixIcon: Icon(Icons.lock, size: iconSizeMedium,
                      color: _confirmPasswordError == null
                          ? Colors.green
                          : Colors.red),
                  errorText: _confirmPasswordController.text.isEmpty
                      ? null
                      : _confirmPasswordError,
                  errorStyle: TextStyle(color: Colors.red, fontSize: fontSizeSmall),
                  contentPadding: EdgeInsets.symmetric(vertical: 6, horizontal: 12),
                ),
                style: TextStyle(fontSize: fontSizeMedium),
                validator: (val) {
                  return null;
                },
                onFieldSubmitted: (value) {
                  if (!_isLoading) {
                    _signUp();
                  }
                },
              ),
              formSpacer12,
              if (_isLoading)
                ElevatedButton(
                  onPressed: null,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      formSpacer6,
                      Text(
                        'Creating account, please wait a few seconds...',
                        style: TextStyle(fontSize: fontSizeSmall),
                      ),
                    ],
                  ),
                ),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: (_isLoading ||
                          _emailError != null ||
                          _usernameError != null ||
                          _passwordError != null ||
                          _confirmPasswordError != null)
                      ? null
                      : _signUp,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.login,
                          color: Colors.green, size: iconSizeSmall),
                      formSpacer3,
                      Text('Register', style: TextStyle(fontSize: fontSizeMedium)),
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
                    Icon(Icons.arrow_back_rounded,
                        size: iconSizeSmall, color: Colors.orange),
                    formSpacer3,
                    Text('I already have an account', style: TextStyle(fontSize: fontSizeSmall)),
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
