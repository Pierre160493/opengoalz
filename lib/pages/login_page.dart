import 'package:flutter/material.dart';
import 'package:opengoalz/provider_user.dart';
import 'package:opengoalz/widgets/max_width_widget.dart';
import 'user_page.dart';
import 'register_page.dart';
import '../constants.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  bool _useEmail = true;
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });

    String email = _emailController.text;

    if (!_useEmail) {
      try {
        // Fetch email associated with the username
        Map<String, dynamic> response = await supabase
            .from('profiles')
            .select('email')
            .eq('username', _usernameController.text)
            .single();

        if (response['email'] == null) {
          context.showErrorSnackBar(
              message:
                  'ERROR: Email not found for the user: ${_usernameController.text}');
          setState(() {
            _isLoading = false;
          });
          return;
        } else {
          email = response['email'];
        }
      } on PostgrestException catch (error) {
        context.showErrorSnackBar(
            message:
                'POSTGRES ERROR: Failed to fetch email for the username ==> ${error.code}: ${error.message}');
        setState(() {
          _isLoading = false;
        });
        return;
      } catch (error) {
        context.showErrorSnackBar(
            message:
                'UNKNOWN ERROR: Failed to fetch email for the username, try the email directly');
        setState(() {
          _isLoading = false;
        });
        return;
      }
    }

    try {
      await supabase.auth.signInWithPassword(
        email: email,
        password: _passwordController.text,
      );
      Navigator.of(context)
          .pushAndRemoveUntil(UserPage.route(), (route) => false);
    } on AuthException catch (error) {
      context.showErrorSnackBar(message: error.message);
    } catch (_) {
      context.showErrorSnackBar(message: unexpectedErrorMessage);
    }
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _usernameController.dispose();
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
                  child: _useEmail
                      ? TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          keyboardType: TextInputType.emailAddress,
                        )
                      : TextFormField(
                          controller: _usernameController,
                          decoration:
                              const InputDecoration(labelText: 'Username'),
                        ),
                ),
                formSpacer,
                Text(_useEmail ? 'Use Email' : 'Use Username'),
                Switch(
                  value: _useEmail,
                  onChanged: (value) {
                    setState(() {
                      _useEmail = value;
                    });
                  },
                ),
              ],
            ),
            formSpacer,
            TextFormField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            formSpacer,
            ElevatedButton(
              onPressed: _isLoading ? null : _signIn,
              child: const Text('Login'),
            ),
            formSpacer,
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
