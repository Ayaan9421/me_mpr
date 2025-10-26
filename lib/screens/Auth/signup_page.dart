import 'package:me_mpr/screens/Home/home_page.dart';
import 'package:me_mpr/screens/Auth/login_page.dart';
import 'package:me_mpr/services/Auth/auth_service.dart';
import 'package:me_mpr/utils/utils.dart';
import 'package:me_mpr/widgets/Auth/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _auth = AuthService();
  bool isObscurePassword = true;
  bool isObscureConfirm = true;

  final formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Scaffold(
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
                                isObscure: isObscurePassword,
                                textInputAction: TextInputAction.next,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscurePassword
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isObscurePassword = !isObscurePassword;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.015),
                              CustomTextField(
                                controller: _confirmPasswordController,
                                hintText: "Confirm Password",
                                prefixIcon: Icons.lock_outline,
                                isObscure: isObscureConfirm,
                                textInputAction: TextInputAction.done,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    isObscureConfirm
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      isObscureConfirm = !isObscureConfirm;
                                    });
                                  },
                                ),
                              ),
                              SizedBox(height: height * 0.02),
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
                                      if (_passwordController.text ==
                                          _confirmPasswordController.text) {
                                        final result = await _auth
                                            .registerWithEmail(
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
                                        showSnackBar(
                                          context,
                                          "Passwords don't match",
                                        );
                                      }
                                    }
                                  },
                                  child: Text(
                                    "Create Account",
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
                              text: "Already have an Account? ",
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "Sign In",
                                  style: TextStyle(
                                    color: Color(0xFF3852df),
                                    fontWeight: FontWeight.w500,
                                  ),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => LoginPage(),
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
