import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'user_page.dart';
import 'register_page.dart';
import '../constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  static Route<void> route() {
    return MaterialPageRoute(builder: (context) => const LoginPage());
  }

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _inputController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedEmailOrUsername();
  }

  Future<void> _loadSavedEmailOrUsername() async {
    final prefs = await SharedPreferences.getInstance();
    final savedEmailOrUsername = prefs.getString('emailOrUsername');
    if (savedEmailOrUsername != null) {
      _inputController.text = savedEmailOrUsername;
    }
  }

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    String email = _inputController.text; // Email to be used for login
    String? postgresError;
    String? otherError;

    // If using email, check if it is not empty
    if (!email.contains('@')) {
      try {
        // Fetch email associated with the username
        Map<String, dynamic>? response = await supabase
            .from('profiles')
            .select('email')
            .eq('username', _inputController.text)
            .maybeSingle();

        if (response == null) {
          postgresError = 'Username not found: ${_inputController.text}';
        } else if (response['email'] == null) {
          postgresError =
              'Email not found for the user: ${_inputController.text}';
        } else {
          email = response['email'];
        }
      } on PostgrestException catch (error) {
        postgresError =
            'POSTGRES ERROR: Failed to fetch email for the username ==> ${error.code}: ${error.message}';
      } catch (error) {
        otherError =
            'UNKNOWN ERROR: Failed to fetch email for the username, try the email directly';
      }
    }

    // If there was an error, show it and exit the function
    if (otherError != null || postgresError != null) {
      if (postgresError != null) {
        context.showSnackBarPostgreSQLError(postgresError);
      } else if (otherError != null) {
        context.showSnackBarError(otherError);
      }
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: _passwordController.text,
      );

      // Save the email or username to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('emailOrUsername', _inputController.text);

      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showSnackBarError(error.message);
    } catch (error) {
      context.showSnackBarError('UNKNOWN ERROR: ${error}');
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _inputController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
            child: Text(
                'Welcome to $appName ! Login to manage your club and players')),
      ),
      body: MaxWidthContainer(
        child: ListView(
          padding: formPadding,
          children: [
            Row(
              children: [
                Expanded(
                    child: TextFormField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    labelText: 'Email or Username',
                  ),
                  keyboardType: TextInputType.emailAddress,
                )),
              ],
            ),
            formSpacer6,
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
              onFieldSubmitted: (value) {
                if (!_isLoading) {
                  _signIn();
                }
              },
            ),
            formSpacer6,
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: const Text('Login'),
            ),
            formSpacer6,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(RegisterPage.route());
              },
              child: const Text('I don\'t have an account'),
            )
          ],
        ),
      ),
    );
  }
}
