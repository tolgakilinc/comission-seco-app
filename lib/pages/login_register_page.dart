import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:seco_app/service/auth.dart';
import 'package:fluttertoast/fluttertoast.dart'; // Toast package

class LoginRegisterPage extends StatefulWidget {
  const LoginRegisterPage({super.key});

  @override
  State<LoginRegisterPage> createState() => _LoginRegisterPageState();
}

class _LoginRegisterPageState extends State<LoginRegisterPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool islogin = true;
  String? errorMessage;
  bool rememberMe = false; // "Beni Hatırla" için flag
  bool isPasswordVisible = false; // Add this to manage password visibility

  // Kayıt işlemi
  Future<void> createUser() async {
    try {
      await Auth().createUser(email: emailController.text, password: passwordController.text);
      // Başarılı kayıt sonrası toast mesajı gösteriliyor
      Fluttertoast.showToast(
        msg: "Kayıt başarılı!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Giriş işlemi
  Future<void> signIn() async {
    try {
      await Auth().signIn(email: emailController.text, password: passwordController.text);
      // Başarılı giriş sonrası toast mesajı gösteriliyor
      Fluttertoast.showToast(
        msg: "Giriş başarılı!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  // Google ile giriş işlemi
  Future<void> signInWithGoogle() async {
    try {
      await Auth().signInWithGoogle();
      // Google ile başarılı giriş sonrası toast mesajı gösteriliyor
      Fluttertoast.showToast(
        msg: "Google ile giriş başarılı!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.green,
        textColor: Colors.white,
      );
      Navigator.pushReplacementNamed(context, '/home');
    } on FirebaseAuthException catch (e) {
      setState(() {
        errorMessage = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start, // Align to the left
          children: [
            // Logo image added above the Welcome text
            Center(
              child: Image.asset(
                'assets/images/seco.png', // Add your logo here
                height: 300, // Adjust as needed
              ),
            ),
            
            const Text(
              "Hoşgeldin!",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Colors.redAccent,
              ),
              textAlign: TextAlign.left, // Align Welcome to the left
            ),
            const SizedBox(height: 40), // Remove the subtext section here
            TextField(
              controller: emailController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.email_outlined),
                labelText: 'Email',
                hintText: 'Enter your email',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.lock_outline),
                labelText: 'Password',
                hintText: 'Enter your password',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                suffixIcon: IconButton(
                  icon: Icon(
                    isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !isPasswordVisible, // Toggle the obscure text based on the flag
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (bool? value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    const Text("Remember me"),
                  ],
                ),
                TextButton(
                  onPressed: () {
                    // Şifremi unuttum işlevi
                  },
                  child: const Text("Forgot password?"),
                ),
              ],
            ),
            const SizedBox(height: 20),
            errorMessage != null
                ? Text(
                    errorMessage!,
                    style: const TextStyle(color: Colors.red),
                  )
                : const SizedBox.shrink(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (islogin) {
                  signIn();
                } else {
                  createUser();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.redAccent,
              ),
              child: Center(
                child: Text(
                  islogin ? "Sign In" : "Register",
                  style: const TextStyle(fontSize: 18),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Row(
              children: [
                Expanded(child: Divider(thickness: 1)),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Text("Or"),
                ),
                Expanded(child: Divider(thickness: 1)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: signInWithGoogle,
              icon: Image.asset(
                'assets/images/google.jpg', // Replace Google icon with the image
                height: 24, // Adjust as needed
              ),
              label: const Text("Continue with Google"),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 15),
                minimumSize: const Size(double.infinity, 50), // Make button full width
                backgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                setState(() {
                  islogin = !islogin;
                });
              },
              child: Center(
                child: Text(islogin ? "Don't have an account? Create an account" : "Already have an account? Sign In",
                style: const TextStyle(
                  color: Colors.redAccent,)
                
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
