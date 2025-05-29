import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'buyer_category_button.dart';
import 'dogfood.dart'; // <-- Make sure this path is correct
import 'catacc.dart';
import 'aquafish.dart';
import 'birdfeed.dart';
import 'petgrooming.dart';
import 'pethealth.dart';

class CategoryRow extends StatelessWidget {
  const CategoryRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            BuyerCategoryButton(
              icon: FontAwesomeIcons.dog,
              label: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DogFoodPage()),
                );
              },
            ),
            SizedBox(width: 15),
            BuyerCategoryButton(
              icon: FontAwesomeIcons.cat,
              label: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CatAccPage()),
                );
              },
            ),
            SizedBox(width: 15),
            BuyerCategoryButton(
              icon: FontAwesomeIcons.fish,
              label: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AquaFishPage()),
                );
              },
            ),
            SizedBox(width: 15),
            BuyerCategoryButton(
              icon: FontAwesomeIcons.dove,
              label: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => BirdFeedPage()),
                );
              },
            ),
            SizedBox(width: 15),
            BuyerCategoryButton(
              icon: FontAwesomeIcons.tshirt,
              label: '',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetGroomingPage()),
                );
              },
            ),
            SizedBox(width: 15),
            BuyerCategoryButton(
              icon: FontAwesomeIcons.medkit,
              label: '',
             onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PetHealthPage()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
