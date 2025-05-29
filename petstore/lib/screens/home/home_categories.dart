import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../login.dart';
import '../category_button.dart';

class HomeCategories extends StatelessWidget {
  const HomeCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            FontAwesomeIcons.dog,
            FontAwesomeIcons.cat,
            FontAwesomeIcons.fish,
            FontAwesomeIcons.dove,
            FontAwesomeIcons.tshirt,
            FontAwesomeIcons.medkit,
          ]
              .map((icon) => Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => LoginPage()),
                        ),
                        child: CategoryButton(icon: icon, label: ""),
                      ),
                      SizedBox(width: 15),
                    ],
                  ))
              .toList(),
        ),
      ),
    );
  }
}
