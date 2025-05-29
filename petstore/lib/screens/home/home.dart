import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'home_appbar.dart';
import 'home_slideshow.dart';
import 'home_categories.dart';
import 'home_bottom_nav.dart';
import 'home_product.dart';
import 'package:petstore/api_endpoints.dart';

import '../login.dart'; // ✅ Correct import



class Home extends StatefulWidget {
  const Home({super.key});

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  List<dynamic> _products = [];

  final List<String> _imagePaths = [
    "assets/slideshow/slideshow_1.jpg",
    "assets/slideshow/slideshow_2.jpg",
    "assets/slideshow/slideshow_3.jpg",
    "assets/slideshow/slideshow_4.jpg",
    "assets/slideshow/slideshow_5.jpg",
  ];

  @override
  void initState() {
    super.initState();
    _startSlideshow();
    _fetchProducts();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 3), (Timer timer) {
      if (_currentPage < _imagePaths.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      _pageController.animateToPage(
        _currentPage,
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
      setState(() {});
    });
  }

  Future<void> _fetchProducts() async {
    final response = await http.get(Uri.parse(ApiEndpoints.allProducts));

    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
      });
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
          context: context,
          builder: (BuildContext context) {
            return Dialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              backgroundColor: Colors.white,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 25.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.exit_to_app_rounded, color: Colors.redAccent, size: 50),
                    SizedBox(height: 20),
                    Text("Exit App", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87)),
                    SizedBox(height: 10),
                    Text("Are you sure you want to exit the app?",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16, color: Colors.black54)),
                    SizedBox(height: 25),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[300],
                            foregroundColor: Colors.black87,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Cancel"),
                        ),
                        ElevatedButton(
                          onPressed: () => Navigator.of(context).pop(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.redAccent,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: Text("Exit"),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            );
          },
        ) ??
        false;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: buildHomeAppBar(context),
        body: SingleChildScrollView(
          child: Column(
            children: [
              HomeSlideshow(
                controller: _pageController,
                imagePaths: _imagePaths,
                currentPage: _currentPage,
              ),
              HomeCategories(),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                padding: const EdgeInsets.all(8),
                childAspectRatio: 0.72,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                children: List.generate(_products.length, (index) {
                  var product = _products[index];
                  String imageUrl = product['image_path'];

                  if (!imageUrl.startsWith('http')) {
                    imageUrl = 'assets/uploads/$imageUrl';
                  }

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => LoginPage()), // ✅ push using MaterialPageRoute
                      );
                    },
                    child: HomeProduct(
                      productName: product['name'],
                      price: double.tryParse(product['price'].toString()) ?? 0.0,
                      rating: product['rating']?.toDouble() ?? 0.0,
                      imagePath: imageUrl,
                      isFavorite: product['isFavorite'] ?? false,
                      onFavoriteToggle: (newFavorite) {
                        setState(() {
                          product['isFavorite'] = newFavorite;
                        });
                      },
                      onStarTap: (newRating) {
                        setState(() {
                          product['rating'] = newRating.toDouble();
                        });
                      },
                    ),
                  );
                }),
              )
            ],
          ),
        ),
        bottomNavigationBar: HomeBottomNav(),
      ),
    );
  }
}
