import 'package:me_mpr/screens/Auth/forgot_password_page.dart';
import 'package:me_mpr/screens/Home/home_page.dart';
import 'package:me_mpr/screens/Auth/signup_page.dart';
import 'package:me_mpr/services/Auth/auth_service.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/Auth/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool isObscure = true;
  final formKey = GlobalKey<FormState>();
  final _auth = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),
              child: IntrinsicHeight(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Center(
                    child: Column(
                      children: [
                        SizedBox(height: height * 0.1),
                        Image.asset(
                          "assets/images/car_login_page_icon.png",
                          height: height * 0.2,
                          fit: BoxFit.fitHeight,
                        ),
                        SizedBox(height: height * 0.01),
                        Text(
                          "me_mpr",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 30,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: height * 0.05),
                        Form(
                          key: formKey,
                          child: Column(
                            children: [
                              CustomTextField(
                                controller: _emailController,
                                hintText: "Email",
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              SizedBox(height: height * 0.015),
                              CustomTextField(
                                controller: _passwordController,
                                hintText: "Password",
                                prefixIcon: Icons.lock_outline,
                                isObscure: isObscure,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscure
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isObscure = !isObscure;
                                    });
                                  },
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10,
                                  horizontal: 10,
                                ),
                                child: SizedBox(
                                  width: width,
                                  child: RichText(
                                    textAlign: TextAlign.right,
                                    text: TextSpan(
                                      text: "Forgot Password?",
                                      style: TextStyle(
                                        color: Color(0xFF3852df),
                                        fontWeight: FontWeight.w500,
                                      ),
                                      recognizer: TapGestureRecognizer()
                                        ..onTap = () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  ForgotPasswordPage(),
                                            ),
                                          );
                                        },
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(height: height * 0.015),
                              Container(
                                width: width * 0.85,
                                padding: EdgeInsets.symmetric(vertical: 5),
                                decoration: BoxDecoration(
                                  color: Color(0xFF3852df),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(15),
                                  ),
                                ),

                                child: TextButton(
                                  onPressed: () async {
                                    if (formKey.currentState!.validate()) {
                                      final result = await _auth
                                          .signInWithEmail(
                                            _emailController.text,
                                            _passwordController.text,
                                          );

                                      result.fold(
                                        (failure) {
                                          showSnackBar(
                                            context,
                                            failure.message,
                                          );
                                        },
                                        (authResult) {
                                          final user = authResult.user;
                                          final isNewUser =
                                              authResult.isNewUser;

                                          showSnackBar(
                                            context,
                                            "Welcome ${user.displayName ?? user.email}",
                                          );

                                          if (isNewUser) {
                                            showSnackBar(context, "hi");
                                          } else {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    HomePage(),
                                              ),
                                            );
                                          }
                                        },
                                      );
                                    } else {
                                      showSnackBar(context, "Missing Fields");
                                    }
                                  },
                                  child: Text(
                                    "Log In",
                                    style: TextStyle(
                                      fontFamily: "Inter",
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: height * 0.035),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 25),
                          child: RichText(
                            text: TextSpan(
                              text: "Don't have an account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign Up",
                                  style: TextStyle(
                                    color: Color(0xFF3852df),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SignupPage(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
