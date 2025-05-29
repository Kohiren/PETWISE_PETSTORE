import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'buyer_view_product.dart';
import 'package:petstore/api_endpoints.dart';

class BirdFeedPage extends StatefulWidget {
  const BirdFeedPage({super.key});

  @override
  _BirdFeedPageState createState() => _BirdFeedPageState();
}

class _BirdFeedPageState extends State<BirdFeedPage> {
  List<dynamic> products = [];
  bool isLoading = true;
  String errorMessage = '';

// Use a single IP constant

  @override
  void initState() {
    super.initState();
    fetchBirdFeedProducts();
  }

  Future<void> fetchBirdFeedProducts() async {
    final String apiUrl = ApiEndpoints.birdfeedProducts;

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        List<dynamic> allProducts = json.decode(response.body);
        setState(() {
          products = allProducts;
          isLoading = false;
          errorMessage = '';
        });
      } else {
        throw Exception('Failed to load bird feed products. Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Error loading products: $e';
        isLoading = false;
      });
    }
  }

  Widget buildStarRating(int count) {
    return Row(
      children: List.generate(5, (index) {
        return Icon(
          index < count ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 16,
        );
      }),
    );
  }

  Widget buildProductCard(dynamic product) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BuyerViewProduct(
              name: 'Bird Feed Seller',
              email: 'seller@example.com',
              phone: '0912-345-6789',
              address: 'Bird Feed Avenue',
              productName: product['name'] ?? 'No name',
              price: double.tryParse(product['price'].toString()) ?? 0.0,
              rating: 4.0,
              productDescription: product['description'] ?? 'No description provided',
              productCategory: product['category'] ?? 'Others',
              variations: product['variations'] ?? 'None',
              quantity: product['quantity'] ?? 1,
              imagePath: ApiEndpoints.imageUrl(product['image_path']),
            ),
          ),
        );
      },
      child: Card(
        color: Colors.white,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 120,
                  width: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      Uri.encodeFull(ApiEndpoints.imageUrl(product['image_path'] ?? '')),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: Center(child: Icon(Icons.broken_image, size: 40)),
                        );
                      },
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10),
              Text(
                product['name'] ?? 'Unknown Product',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '₱${product['price'].toString()}',
                style: TextStyle(
                  color: Colors.green[700],
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 6),
              buildStarRating(4),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF220F01), // New color
        title: Text(
          'Bird Feeders & Food',
          style: TextStyle(color: Colors.white), // Header text color white
        ),
        iconTheme: IconThemeData(color: Colors.white), // Back icon color
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : products.isEmpty
                  ? Center(child: Text('No bird feeder products available.'))
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                          childAspectRatio: 0.75,
                        ),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          return buildProductCard(products[index]);
                        },
                      ),
                    ),
      bottomNavigationBar: Container(
        height: 50,
        color: Color(0xFF220F01), // Footer color
      ),
    );
  }
}
