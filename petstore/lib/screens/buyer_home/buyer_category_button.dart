import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';

class BuyerCategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const BuyerCategoryButton({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Color(0xFFE03E0B),
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            child: Center(
              child: Icon(icon, color: Colors.white, size: 40),
            ),
          ),
          SizedBox(height: 5),
          SizedBox(
            width: 80,
            child: AutoSizeText(
              label,
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              minFontSize: 8,
              stepGranularity: 1,
              maxFontSize: 16,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}
