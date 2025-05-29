import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'cart.dart';
import 'package:petstore/api_endpoints.dart';

// Placeholder CheckoutPage
class CheckoutPage extends StatelessWidget {
  final String imagePath;
  final String productName;
  final double price;
  final int quantity;
  final String name;
  final String email;
  final String phone;
  final String address;

  // For simplicity, fixed shipping and payment methods here
  final String shippingMethod = 'Door-to-Door';
  final String paymentMethod = 'Cash on Delivery';

  const CheckoutPage({super.key, 
    required this.imagePath,
    required this.productName,
    required this.price,
    required this.quantity,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,

  });


  Future<bool> submitCheckout() async {
    final url = Uri.parse(ApiEndpoints.checkout);

    final body = jsonEncode({
      'product_image': imagePath,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'address': address,
      'shipping_method': shippingMethod,
      'payment_method': paymentMethod,
      'total_amount': price, // as you requested, just the price, not price*quantity
      'status': 'Pending',
    });

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    return response.statusCode == 200;
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final double totalAmount = price;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Checkout'),
        backgroundColor: const Color(0xFF220F01),
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Order Summary',
                    style: textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),

                  // Customer Info
                  _buildInfoCard(
                    icon: Icons.person,
                    title: 'Customer Information',
                    content: [
                      'Name: $name',
                      'Email: $email',
                      'Phone: $phone',
                      'Address: $address',
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Info
                  _buildInfoCard(
                    icon: Icons.shopping_bag,
                    title: 'Product Details',
                    content: [
                      'Product: $productName',
                      'Price: ₱${price.toStringAsFixed(2)}',
                      'Quantity: $quantity',
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Product Image
                  Container(
                    height: 380,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      image: DecorationImage(
                        image: NetworkImage(imagePath),
                        fit: BoxFit.cover,
                      ),
                      // FIX: Changed 'boxBoxShadow' to 'boxShadow'
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 10,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Shipping & Payment Info
                  _buildInfoCard(
                    icon: Icons.local_shipping,
                    title: 'Shipping & Payment',
                    content: [
                      'Shipping: $shippingMethod',
                      'Payment: $paymentMethod',
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),

          // Total and Confirm Purchase
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Total Price
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 5,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    'Total: ₱${totalAmount.toStringAsFixed(2)}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(height: 10),

                // Confirm Purchase Button
                ElevatedButton.icon(
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Confirm Purchase', style: TextStyle(fontSize: 16)),
                  onPressed: () async {
                    bool success = await submitCheckout();

                    if (context.mounted) { // Check if context is still valid
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Order placed successfully!')),
                        );
                        // You may also navigate back or clear fields here
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Failed to place order. Try again.')),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<String> content,
  }) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      elevation: 3,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.brown),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ...content.map(
              (text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Text(text, style: const TextStyle(fontSize: 14)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class BuyerViewProduct extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String address;
  final String productName;
  final double price;
  final double rating;
  final String productDescription;
  final String productCategory;
  final String variations;
  final int quantity;
  final String imagePath;

  const BuyerViewProduct({
    super.key,
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
    required this.productName,
    required this.price,
    required this.rating,
    required this.productDescription,
    required this.productCategory,
    required this.variations,
    required this.quantity,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
  final textTheme = Theme.of(context).textTheme;
  final screenWidth = MediaQuery.of(context).size.width;

  return Scaffold(
    appBar: AppBar(
      title: Text('Product Details', style: textTheme.titleLarge?.copyWith(color: Colors.white)),
      backgroundColor: const Color(0xFF220F01),
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.shopping_cart, color: Colors.white),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => CartPage()));
          },
        ),
      ],
    ),
    body: SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: screenWidth * 0.9,
            height: screenWidth * 0.7,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.contain,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          const SizedBox(height: 50),
          Text('Product Details', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfo(textTheme, 'Name:', productName),
                  _buildInfo(textTheme, 'Variations:', variations),
                  _buildInfo(textTheme, 'Category:', productCategory),
                  _buildInfo(textTheme, 'Price:', '₱${price.toStringAsFixed(2)}', color: Colors.green),
                  _buildInfo(textTheme, 'Quantity:', '$quantity'),
                  _buildInfo(textTheme, 'Description:', productDescription),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildActionButton('Add to Cart', const Color(0xFF220F01), () {
                _showAddToCartDialog(context);
              }),
              _buildActionButton('Buy Now', Colors.green, () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CheckoutPage(
                      name: name,
                      email: email,
                      phone: phone,
                      address: address,
                      productName: productName,
                      price: price,
                      quantity: quantity,
                      imagePath: imagePath,
                    ),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 24),
          GestureDetector(
            onTap: () {
              // Navigate to seller shop logic
            },
            child: Row(
              children: [
                const Icon(Icons.storefront, color: Colors.deepPurple),
                const SizedBox(width: 8),
                Text('View Seller Shop', style: textTheme.titleMedium?.copyWith(color: Colors.deepPurple, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const Divider(height: 30),
          Text('Product Ratings', style: textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Row(
            children: List.generate(5, (index) {
              return Icon(
                index < rating ? Icons.star : Icons.star_border,
                color: Colors.amber,
              );
            }),
          ),
          const SizedBox(height: 16),
          Text('Customer Reviews', style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          FutureBuilder<List<dynamic>>(
            future: fetchFeedback(productName),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Text('No feedback yet.');
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: snapshot.data!.map((feedback) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.person)),
                        title: Text(feedback['firstname'] ?? 'Anonymous'),
                        subtitle: Text(feedback['message'] ?? ''),
                      ),
                      if (feedback['photo_path'] != null && feedback['photo_path'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0),
                          child: Image.network(
                            'http://192.168:5000/static/feedback_photo/${feedback['photo_path']}',
                            width: 200,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),
                      if (feedback['video_path'] != null && feedback['video_path'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(left: 16.0, top: 8.0),
                          child: Text('Video: ${feedback['video_path']}'),
                          // You can later use a video player widget here
                        ),
                      const Divider(),
                    ],
                  );
                }).toList(),
              );
            },
          )

        ],
      ),
    ),
  );
}

Future<List<dynamic>> fetchFeedback(String productName) async {
  final uri = Uri.parse('http://192.168:5000/get_feedback?product_name=$productName');
  final response = await http.get(uri);

  if (response.statusCode == 200) {
    return jsonDecode(response.body);
  } else {
    throw Exception('Failed to load feedback');
  }
}




  Widget _buildInfo(TextTheme textTheme, String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Text('$label $value', style: textTheme.bodyLarge?.copyWith(color: color ?? Colors.black87)),
    );
  }

  Widget _buildActionButton(String label, Color color, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(label, style: const TextStyle(fontSize: 16)),
    );
  }

  void _showAddToCartDialog(BuildContext context) {
    int selectedQuantity = 1;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(imagePath, height: 120, width: 120, fit: BoxFit.cover),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text("Add to Cart", style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.shopping_bag, color: Colors.brown),
                    title: Text("Product: $productName"),
                  ),
                 ListTile(
                  leading: const Icon(Icons.money, color: Colors.green),
                  title: Text("Price: ₱${price.toStringAsFixed(2)}"),
                ),
                  ListTile(
                    leading: const Icon(Icons.numbers, color: Colors.blue),
                    title: Row(
                      children: [
                        const Text("Quantity: "),
                        IconButton(
                          icon: const Icon(Icons.remove_circle, color: Colors.red),
                          onPressed: () {
                            if (selectedQuantity > 1) {
                              setState(() {
                                selectedQuantity--;
                              });
                            }
                          },
                        ),
                        Text('$selectedQuantity', style: const TextStyle(fontSize: 16)),
                        IconButton(
                          icon: const Icon(Icons.add_circle, color: Colors.green),
                          onPressed: () {
                            setState(() {
                              selectedQuantity++;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(child: const Text("Cancel"), onPressed: () => Navigator.pop(context)),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add_shopping_cart),
                        label: const Text("Add"),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF220F01)),
                        onPressed: () async {
                          // Capture context before the async gap
                          final currentContext = context;
                          bool success = await _addItemToCart(currentContext, selectedQuantity);

                          // Check if the context is still mounted before using it
                          if (currentContext.mounted) {
                            if (success) {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                const SnackBar(content: Text('Item added to cart successfully!')),
                              );
                            } else {
                              ScaffoldMessenger.of(currentContext).showSnackBar(
                                const SnackBar(content: Text('Failed to add item to cart.')),
                              );
                            }
                            Navigator.pop(currentContext);
                          }
                        },
                      ),
                    ],
                  )
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<bool> _addItemToCart(BuildContext context, int quantityToAdd) async {
  final String url = ApiEndpoints.addToCart;  // Ensure port matches your Flask server

  try {
    final response = await http.post(
      Uri.parse(url),
      headers: {"Content-Type": "application/json"}, // Send as JSON
      body: jsonEncode({
        'buyer_email': email,         // Match Flask key
        'name': productName,          // Match Flask key
        'price': price,               // Match Flask key
        'quantity': quantityToAdd,    // Match Flask key
        'image_path': imagePath       // Match Flask key
      }),
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      return jsonResponse['message'] == "Item added to cart";
    } else {
      debugPrint('Server error: ${response.body}');
      return false;
    }
  } catch (e) {
    debugPrint('Error adding to cart: $e');
    return false;
  }
}

}