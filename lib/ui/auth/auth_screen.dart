import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:to_do_app/bloc/auth_bloc/auth_bloc.dart';
import 'package:to_do_app/bloc/auth_bloc/auth_event.dart';
import 'package:to_do_app/bloc/auth_bloc/auth_state.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_bloc.dart';
import 'package:to_do_app/bloc/locale_bloc/locale_event.dart';
import 'package:to_do_app/generated/l10n.dart';
import 'package:to_do_app/ui/todo/todo_page.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  AuthScreenState createState() => AuthScreenState();
}

class AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true; // Toggle between login and signup
  String _email = '';
  String _password = '';

  void _toggleAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
    });
  }

  void _submitAuthForm(BuildContext context) {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    if (_isLogin) {
      context.read<AuthBloc>().add(LoginEvent(_email, _password));
    } else {
      context.read<AuthBloc>().add(SignUpEvent(_email, _password));
    }
  }

  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckLoginStatusEvent()); // Check if logged in
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isLogin ? S.of(context).login : S.of(context).sign_up),
        actions: [
          PopupMenuButton<String>(
            onSelected: (String languageCode) {
              Locale newLocale = Locale(languageCode);
              BlocProvider.of<LocaleBloc>(context)
                  .add(ChangeLocaleEvent(newLocale));
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem(value: 'en', child: Text('English')),
              const PopupMenuItem(value: 'ar', child: Text('العربية')),
            ],
          ),
        ],
      ),
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthSuccess || state is AuthLoggedIn) {
            Navigator.pushReplacementNamed(context, '/todo');
          } else if (state is AuthFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.error)),
            );
          }
        },
        builder: (context, state) {
          if (state is AuthLoading) {
            return const Center(
              child: SizedBox(
                  height: 50, width: 50, child: CircularProgressIndicator()),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    key: const ValueKey('email'),
                    decoration: InputDecoration(labelText: S.of(context).email),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          !value.contains('@')) {
                        return 'Please enter a valid email';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _email = value!;
                    },
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    decoration:
                        InputDecoration(labelText: S.of(context).password),
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty || value.length < 6) {
                        return 'Password must be at least 6 characters long';
                      }
                      return null;
                    },
                    onSaved: (value) {
                      _password = value!;
                    },
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => _submitAuthForm(context),
                    child: Text(
                        _isLogin ? S.of(context).login : S.of(context).sign_up),
                  ),
                  TextButton(
                    onPressed: _toggleAuthMode,
                    child: Text(_isLogin
                        ? S.of(context).create_account
                        : S.of(context).already_have_account),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
