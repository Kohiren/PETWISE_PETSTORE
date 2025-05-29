import 'package:flutter/material.dart';
import '../login.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: Color(0xFF220F01),
      child: Padding(
        padding: EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Icons.home,
            Icons.category,
            Icons.notifications,
            Icons.person,
          ]
              .map((icon) => IconButton(
                    icon: Icon(icon, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()),
                      );
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}
