import 'package:me_mpr/screens/home_page.dart';
import 'package:me_mpr/services/auth_service.dart';
import 'package:me_mpr/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class OtherSignin extends StatefulWidget {
  const OtherSignin({super.key});

  @override
  State<OtherSignin> createState() => _OtherSigninState();
}

class _OtherSigninState extends State<OtherSignin> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final height = MediaQuery.sizeOf(context).height;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
                endIndent: 10,
                indent: 30,
              ),
            ),
            Text("Or Continue with", style: TextStyle(color: Colors.grey)),
            Expanded(
              child: Divider(
                color: Colors.grey,
                thickness: 1,
                endIndent: 30,
                indent: 10,
              ),
            ),
          ],
        ),
        SizedBox(height: height * 0.02),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: InkWell(
                onTap: () async {
                  final result = await _auth.signInWithGoogle();
                  result.fold(
                    (failure) {
                      showSnackBar(context, failure.message);
                    },
                    (authResult) {
                      final user = authResult.user;
                      final isNewUser = authResult.isNewUser;

                      showSnackBar(
                        context,
                        "Welcome ${user.displayName ?? user.email}",
                      );

                      if (isNewUser) {
                        showSnackBar(context, "hi");
                      } else {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }
                    },
                  );
                },
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/google.svg",
                      semanticsLabel: 'Google Logo',
                      height: height * 0.025,
                    ),
                    SizedBox(width: width * 0.02),
                    Text("Google"),
                  ],
                ),
              ),
            ),
            SizedBox(width: width * 0.05),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.all(Radius.circular(15)),
              ),
              child: InkWell(
                onTap: () async {},
                child: Row(
                  children: [
                    SvgPicture.asset(
                      "assets/images/facebook.svg",
                      semanticsLabel: 'Facebook Logo',
                      height: height * 0.025,
                    ),
                    SizedBox(width: width * 0.02),
                    Text("Facebook"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
