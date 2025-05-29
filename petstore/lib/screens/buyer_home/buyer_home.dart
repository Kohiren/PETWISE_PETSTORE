import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'delivery_status.dart';

import 'app_bar.dart';
import 'slideshow.dart';
import 'category_row.dart';
import 'exit_dialog.dart';
import 'buyer_product.dart';
import 'buyer_info.dart';
import 'buyer_notification.dart';
import 'buyer_view_product.dart';
import 'package:petstore/api_endpoints.dart';



class BuyerHome extends StatefulWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  const BuyerHome({super.key, 
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  @override
  _BuyerHomeState createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late Timer _timer;

  final List<String> _imagePaths = [
    "assets/slideshow/slideshow_1.jpg",
    "assets/slideshow/slideshow_2.jpg",
    "assets/slideshow/slideshow_3.jpg",
    "assets/slideshow/slideshow_4.jpg",
    "assets/slideshow/slideshow_5.jpg",
  ];

  List<dynamic> _products = [];
  List<bool> _isFavorite = [];

  @override
  void initState() {
    super.initState();
    _startSlideshow();
    _fetchProductsFromAPI();
  }

  void _startSlideshow() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
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

  @override
  void dispose() {
    _timer.cancel();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _fetchProductsFromAPI() async {
    final url = Uri.parse(ApiEndpoints.allProducts); // Update if IP changes
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _products = data;
          _isFavorite = List.generate(_products.length, (_) => false);
        });
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      print('Error fetching products: $e');
    }
  }

  Future<void> _fetchProductDetails(int index) async {
    final product = _products[index];
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BuyerViewProduct(
          name: product['name'],
          email: widget.email,
          phone: widget.phone,
          address: widget.address,
          productName: product['name'],
          price: double.tryParse(product['price'].toString()) ?? 0.0,
          rating: 4.0,
          productDescription: product['description'] ?? "No description provided.",
          productCategory: product['category'] ?? "Unknown",
          variations: product['variation'] ?? "N/A",
          quantity: int.tryParse(product['quantity'].toString()) ?? 1,
          imagePath: product['image_path'] ?? "", // Ensure BuyerViewProduct has this field
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return await showExitDialog(context);
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: buildBuyerAppBar(context),
        body: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(
              child: Slideshow(
                pageController: _pageController,
                imagePaths: _imagePaths,
              ),
            ),
            SliverToBoxAdapter(
              child: CategoryRow(),
            ),
            _products.isEmpty
                ? SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final product = _products[index];
                          return 
                        BuyerProduct(
                            productName: product['name'],
                            price: double.tryParse(product['price'].toString()) ?? 0.0,
                            rating: 4.0, // You can replace this with actual product rating if available
                            isFavorite: _isFavorite[index],
                            onFavoriteToggle: (newFavorite) {
                              setState(() {
                                _isFavorite[index] = newFavorite;
                              });
                            },
                            onStarTap: (newRating) {
                              // Optional: handle star rating change
                            },
                            onTap: () {
                              _fetchProductDetails(index);
                            },
                            imagePath: product['image_path'] ?? "", // Pass the image path
                          );
                       },
                        childCount: _products.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: 0.75,
                      ),
                    ),
                  ),
          ],
        ),
        bottomNavigationBar: BottomAppBar(
          color: Color(0xFF220F01),
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: Icon(Icons.home, color: Colors.white),
                  onPressed: () {},
                ),
               IconButton(
                  icon: Icon(Icons.category, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => DeliveryStatusPage()),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.notifications, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerNotificationPage(
                          name: widget.name,
                          email: widget.email,
                          phone: widget.phone,
                          address: widget.address,
                        ),
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: Icon(Icons.person, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => BuyerInfoPage(
                          name: widget.name,
                          email: widget.email,
                          phone: widget.phone,
                          address: widget.address,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
