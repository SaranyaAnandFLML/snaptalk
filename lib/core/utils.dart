import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message,Color color){
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
        SnackBar(
          backgroundColor: color,
            content:Text(message.toString(),
              style: const TextStyle(color: Colors.white),
            )
        )
    );
}
