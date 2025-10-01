import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/constants.dart';
import '../../../core/global/variables.dart';
import '../../../theme/pallete.dart';
import '../controller/auth_controller.dart';



class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState createState() => _SplashState();
}

class _SplashState extends ConsumerState<SplashScreen> {
  keepLogin() async {
    await Future.delayed(const Duration(milliseconds: 500));
    ref.watch(authControllerProvider.notifier).keepLogin(ref, context);
  }

  @override
  void initState() {
    super.initState();
    keepLogin();
  }
  @override
  Widget build(BuildContext context) {
    w=MediaQuery.of(context).size.width;
    h=MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Palette.whiteColor,
      body:  Center(
          child: Padding(
            padding: EdgeInsets.all(w*0.1),
            child: Image.asset(Constants.logoPath),
          )
      ),
    );
  }
}