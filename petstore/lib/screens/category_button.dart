import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';  // Import AutoSizeText package

// CategoryButton widget
class CategoryButton extends StatelessWidget {
  final IconData icon;
  final String label;

  const CategoryButton({
    super.key,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,  // Set a fixed width for the icon button
          height: 80,  // Set a fixed height for the icon button
          decoration: BoxDecoration(
            color: Color(0xFFE03E0B),
            borderRadius: BorderRadius.all(Radius.circular(12)), // Rounded corners for a softer look
          ),
          child: Icon(icon, color: Colors.white, size: 40),  // Adjust icon size relative to the button
        ),
        SizedBox(height: 5),
        // AutoSizeText to automatically adjust text size
        SizedBox(
          width: 80,  // Same width as the button container to maintain alignment
          child: AutoSizeText(
            label,
            style: TextStyle(
              color: Colors.black, 
              fontWeight: FontWeight.bold,
            ),
            maxLines: 1,  // Ensures the text is on one line
            minFontSize: 8,  // Minimum font size before it stops resizing
            stepGranularity: 1,  // Determines how smoothly the text size adjusts
            maxFontSize: 16,  // Maximum font size
            overflow: TextOverflow.ellipsis,  // If text overflows, it will display an ellipsis
          ),
        ),
      ],
    );
  }
}

