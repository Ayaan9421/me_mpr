import 'package:me_mpr/screens/login_page.dart';
import 'package:me_mpr/services/auth_service.dart';
import 'package:me_mpr/widgets/custom_text_field.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  TextEditingController _emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();
  final _auth = AuthService();

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
                    child: Form(
                      key: formKey,
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
                          SizedBox(height: height * 0.035),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 0),
                            child: Text(
                              "Don't worry it happens. Please enter the address associate with your account",
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          SizedBox(height: height * 0.04),
                          CustomTextField(
                            controller: _emailController,
                            hintText: "Email",
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                          ),
                          SizedBox(height: height * 0.025),
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
                                      .resetPasswordUsingEmail(
                                        _emailController.text,
                                      );

                                  result.fold(
                                    (failure) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(failure.message),
                                        ),
                                      );
                                    },
                                    (successMsg) {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(content: Text(successMsg)),
                                      );
                                      if (!mounted) {
                                        return null;
                                      }
                                      Future.delayed(Duration(seconds: 2), () {
                                        Navigator.pop(context);
                                      });
                                    },
                                  );
                                }
                              },
                              child: Text(
                                "Send Email",
                                style: TextStyle(
                                  fontFamily: "Inter",
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  fontSize: 18,
                                ),
                              ),
                            ),
                          ),
                          Spacer(),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 25),
                            child: RichText(
                              text: TextSpan(
                                text: "You remember your password? ",
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
            ),
          );
        },
      ),
    );
  }
}
