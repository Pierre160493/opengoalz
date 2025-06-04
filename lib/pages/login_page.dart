import 'package:flutter/material.dart';
import 'package:opengoalz/extensionBuildContext.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'package:provider/provider.dart';
import 'user_page/user_page.dart';
import 'register_page.dart';
import '../constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, this.username}) : super(key: key);

  static Route<void> route({String? username}) {
    return MaterialPageRoute(
        builder: (context) => LoginPage(username: username));
  }

  final String? username;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _isLoading = false;
  final _inputController = TextEditingController();
  // final _passwordController = TextEditingController(text: 'defaultPassword');
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.username != null) {
      // If username is passed as argument, prewrite it
      _inputController.text = widget.username!;
    } else {
      // Otherwise we check if there is a saved email or username in the shared preferences
      _loadSavedEmailOrUsername();
    }
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

      // Fetch user data and initialize UserSessionProvider
      final userSessionProvider =
          Provider.of<UserSessionProvider>(context, listen: false);
      await userSessionProvider.providerFetchUser(context,
          userId: supabase.auth.currentUser!.id);

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

  Future<void> _resetPassword() async {
    final email = _inputController.text;
    if (email.isEmpty) {
      context.showSnackBarError('Please enter your email');
      return;
    }

    try {
      await supabase.auth.resetPasswordForEmail(email);
      context.showSnackBar('Password reset email sent');
    } on AuthException catch (error) {
      context.showSnackBarError(error.message);
    } catch (error) {
      context.showSnackBarError('UNKNOWN ERROR: ${error}');
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
            if (_isLoading) const LinearProgressIndicator(),
            if (!_isLoading)
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.login),
                    formSpacer6,
                    const Text('Login'),
                  ],
                ),
              ),
            formSpacer6,
            TextButton(
              onPressed: () {
                Navigator.of(context).push(RegisterPage.route());
              },
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_add),
                  formSpacer6,
                  const Text('I don\'t have an account'),
                ],
              ),
            ),
            formSpacer6,
            TextButton(
              onPressed: _resetPassword,
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_open),
                  formSpacer6,
                  const Text('Forgot Password ?'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
