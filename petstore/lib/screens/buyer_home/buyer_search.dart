import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:petstore/api_endpoints.dart';

class BuyerSearch extends StatefulWidget {
  const BuyerSearch({super.key});

  @override
  _BuyerSearchState createState() => _BuyerSearchState();
}



class _BuyerSearchState extends State<BuyerSearch> {
  List<dynamic> _products = [];
  bool _isLoading = false;

  Future<void> _searchProducts(String query) async {
    setState(() => _isLoading = true);

    final Uri url = Uri.parse(ApiEndpoints.productSearch(query));
    final response = await http.get(url);

    if (response.statusCode == 200) {
      setState(() {
        _products = json.decode(response.body);
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
      // Add error handling if needed
    }
  }

  @override
  void initState() {
    super.initState();
    _searchProducts(''); // Load all products initially
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Products'),
        backgroundColor: Colors.teal,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _products.isEmpty
              ? Center(child: Text('No products found'))
              : GridView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.7,
                  ),
                  itemCount: _products.length,
                  itemBuilder: (context, index) {
                    final product = _products[index];
                    return ProductCard(
                      name: product['name'],
                      price: product['price'],
                      imagePath: product['image_path'],
                    );
                  },
                ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final String name;
  final dynamic price;
  final String imagePath;

  const ProductCard({super.key, 
    required this.name,
    required this.price,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
           child: ClipRRect(
  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.network(
                ApiEndpoints.imageUrl(imagePath), // 👈 This replaces the hardcoded URL
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Icon(Icons.image_not_supported),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Text(
              '₱$price',
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: 14, color: Colors.teal),
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }
}
