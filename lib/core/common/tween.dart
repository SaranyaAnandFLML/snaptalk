import 'package:flutter/material.dart';

class ScreenTitle extends StatefulWidget {
  final String text;
  const ScreenTitle({Key? key, required this.text}): super(key: key);

  @override
  State<ScreenTitle> createState() => _ScreenTitleState();
}

class _ScreenTitleState extends State<ScreenTitle> {
  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
        tween: Tween<double>(begin: 0, end: 1),
        duration: const Duration(seconds: 3),
        curve: Curves.easeIn,
        builder: (BuildContext context, double val, Widget? child) {
          return Opacity(
              opacity: val,
              child: Padding(
                padding:  EdgeInsets.only(top: val*50),
                child: Text(widget.text, style: const TextStyle(
                    fontSize: 36, color: Colors.black,
                    fontWeight: FontWeight.bold),
                ),
              )
          );
        },

    );
  }
}