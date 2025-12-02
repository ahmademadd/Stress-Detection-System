import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../widgets/GradientScaffold.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool _loading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthService>(context, listen: false);
    return GradientScaffold(
      child: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/desktop-cloud-background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Text(
                    _error!,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              Image.asset(
                'images/logo.png',
                width: 120,
                height: 120,
              ),
              Container(
                padding: const EdgeInsets.all(16.0),
                constraints: const BoxConstraints(maxWidth: 390),
                decoration: BoxDecoration(
                  shape: BoxShape.rectangle,
                  border: Border.all(color: Colors.grey, width: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                ),
                child: buildForm(auth, context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Form buildForm(AuthService auth, BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          Align(
            alignment: Alignment.bottomLeft,
            child: const Text(
              'Sign In',
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Enter your email and password to sign in to your account.",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.bottomLeft,
            child: Text(
              "Email",
              textAlign: TextAlign.start,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 0.1),
              color: Colors.grey.shade100,
            ),
            child: TextFormField(
              cursorHeight: 20,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 12),
                hintText: 'example@email.com',
                hintStyle: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                border: InputBorder.none,
              ),
              autofocus: true,
              keyboardType: TextInputType.emailAddress,
              onSaved: (v) => _email = v!.trim(),
              validator: (v) =>
                  v != null && v.contains('@') ? null : 'Enter a valid email',
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Password",
                textAlign: TextAlign.start,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              InkWell(
                onTap: () {
                  // navigate to forget password page
                },
                child: Text(
                  "Forgot password?",
                  style: TextStyle(fontSize: 14, color: Colors.blue),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            height: 45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey, width: 0.1),
              color: Colors.grey.shade100,
            ),
            child: TextFormField(
              cursorHeight: 20,
              cursorColor: Colors.black,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.only(left: 12),
                border: InputBorder.none,
              ),
              obscureText: true,
              onSaved: (v) => _password = v!.trim(),
              validator: (v) =>
                  (v != null && v.length >= 6) ? null : 'Min 6 chars',
            ),
          ),
          const SizedBox(height: 16),
          _loading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    backgroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) return;
                    _formKey.currentState!.save();
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    final res = await auth.signIn(
                      email: _email,
                      password: _password,
                    );
                    setState(() {
                      _loading = false;
                    });
                    if (res != null) {
                      setState(() => _error = res);
                    } else {
                      // AuthGate will redirect automatically on authStateChanges
                    }
                  },
                  child: const Text(
                    'Sign In',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
          const SizedBox(height: 12),
          RichText(
            text: TextSpan(
              text: "Don't have an account? ",
              style: TextStyle(
                color: Colors.black, // normal text color
                fontSize: 14,
              ),
              children: [
                TextSpan(
                  text: "Sign up",
                  style: TextStyle(color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      Navigator.pushNamed(context, '/signup');
                    },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
