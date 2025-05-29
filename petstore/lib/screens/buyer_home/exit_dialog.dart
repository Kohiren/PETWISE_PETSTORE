import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Future<bool> showExitDialog(BuildContext context) async {
  return await showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red, size: 50),
              SizedBox(height: 20),
              Text(
                'Are you sure you want to exit?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: Text('No', style: TextStyle(color: Colors.blue, fontSize: 16)),
                  ),
                  TextButton(
                    onPressed: () => SystemNavigator.pop(),
                    child: Text('Yes', style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  ) ?? false;
}
