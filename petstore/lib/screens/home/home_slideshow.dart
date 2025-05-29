import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class HomeSlideshow extends StatelessWidget {
  final PageController controller;
  final List<String> imagePaths;
  final int currentPage;

  const HomeSlideshow({super.key, 
    required this.controller,
    required this.imagePaths,
    required this.currentPage,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 230,
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          PageView.builder(
            controller: controller,
            itemCount: imagePaths.length,
            itemBuilder: (context, index) {
              return Image.asset(
                imagePaths[index],
                fit: BoxFit.cover,
                width: double.infinity,
              );
            },
          ),
          Positioned(
            bottom: 10,
            child: SmoothPageIndicator(
              controller: controller,
              count: imagePaths.length,
              effect: ExpandingDotsEffect(
                dotHeight: 8,
                dotWidth: 8,
                activeDotColor: Color(0xFFE03E0B),
                dotColor: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
