import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:petstore/api_endpoints.dart';

final String serverIp = '192.168';

class CartItem {
  final int id;
  final String imagePath;
  final String name;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.quantity,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      imagePath: json['image_path'],
      name: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
    );
  }
}

class CheckoutPage extends StatefulWidget {
  final double totalAmount;

  const CheckoutPage({super.key, required this.totalAmount});

  @override
  _CheckoutPageState createState() => _CheckoutPageState();
}

class _CheckoutPageState extends State<CheckoutPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;

  // Shipping info controllers
  TextEditingController provinceController = TextEditingController();
  TextEditingController municipalityController = TextEditingController();
  TextEditingController barangayController = TextEditingController();
  TextEditingController zipCodeController = TextEditingController();

  // Shipping and Payment methods states
  String selectedShippingMethod = 'Door-to-Door Delivery';
  String selectedPaymentMethod = 'Cash on Delivery (COD)';

  final shippingMethods = [
    'Door-to-Door Delivery'
  ];

  final paymentMethods = [
    'Cash on Delivery (COD)'
  ];

  @override
  void initState() {
    super.initState();
    fetchCartItems();
    _loadShippingAddress();
  }

  @override
  void dispose() {
    provinceController.dispose();
    municipalityController.dispose();
    barangayController.dispose();
    zipCodeController.dispose();
    super.dispose();
  }

  Future<void> _loadShippingAddress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      provinceController.text = prefs.getString('province') ?? '';
      municipalityController.text = prefs.getString('municipality') ?? '';
      barangayController.text = prefs.getString('barangay') ?? '';
      zipCodeController.text = prefs.getString('zipcode') ?? '';
    });
  }

  Future<void> fetchCartItems() async {
    try {
      final response = await http.get(Uri.parse(ApiEndpoints.cart));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          cartItems = data.map((item) => CartItem.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cart items');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading cart items: $e')),
      );
    }
  }

  Widget _buildCartItem(CartItem item) {
    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            item.imagePath,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported),
          ),
        ),
        title: Text(
          item.name,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Quantity: ${item.quantity}'),
        trailing: Text(
          '₱ ${(item.price * item.quantity).toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.brown[700],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.brown[800],
        ),
      ),
    );
  }

  Widget _buildShippingSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          _buildSectionTitle('Shipping Information'),
          SizedBox(height: 8),
          _buildTextField(provinceController, 'Province'),
          SizedBox(height: 8),
          _buildTextField(municipalityController, 'Municipality'),
          SizedBox(height: 8),
          _buildTextField(barangayController, 'Barangay'),
          SizedBox(height: 8),
          _buildTextField(zipCodeController, 'Zip Code', keyboardType: TextInputType.number),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label,
      {TextInputType keyboardType = TextInputType.text}) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.brown[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildShippingMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Shipping Method'),
          ...shippingMethods.map(
            (method) => RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: selectedShippingMethod,
              activeColor: Colors.brown[700],
              onChanged: (value) {
                setState(() {
                  selectedShippingMethod = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Payment Method'),
          ...paymentMethods.map(
            (method) => RadioListTile<String>(
              title: Text(method),
              value: method,
              groupValue: selectedPaymentMethod,
              activeColor: Colors.brown[700],
              onChanged: (value) {
                setState(() {
                  selectedPaymentMethod = value!;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  double get cartTotal {
  return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
}

Widget _buildCheckoutButton() {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: Offset(0, 4),
        ),
      ],
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Total Price Text
        Text(
          'Total: ₱ ${cartTotal.toStringAsFixed(2)}',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.brown[900],
            letterSpacing: 1.2,
          ),
        ),

        // Space between text and button
        SizedBox(width: 24),

        // Place Order Button (fixed width)
        SizedBox(
          height: 48,
          child: ElevatedButton(
            onPressed: () async {
              // Your existing checkout logic here (unchanged)
              final checkoutUrl = Uri.parse('http://$serverIp:5000/api/checkout');
              final deleteUrlBase = 'http://$serverIp:5000/api/cart';

              bool allSuccess = true;

              for (var item in cartItems) {
                final body = {
                  'product_image': item.imagePath,
                  'product_name': item.name,
                  'price': item.price.toString(),
                  'quantity': item.quantity.toString(),
                  'address':
                      '${provinceController.text}, ${municipalityController.text}, ${barangayController.text}, ${zipCodeController.text}',
                  'shipping_method': selectedShippingMethod,
                  'payment_method': selectedPaymentMethod,
                  'total_amount': (item.price * item.quantity).toString(),
                  'status': 'Pending',
                };

                try {
                  final checkoutResponse = await http.post(
                    checkoutUrl,
                    headers: {'Content-Type': 'application/json'},
                    body: json.encode(body),
                  );

                  if (checkoutResponse.statusCode == 200) {
                    final deleteResponse = await http.delete(
                      Uri.parse('$deleteUrlBase/${item.id}'),
                    );

                    if (deleteResponse.statusCode == 200) {
                      print('Deleted item ${item.name} from cart successfully');
                    } else {
                      allSuccess = false;
                      print('Failed to delete item ${item.name} from cart: ${deleteResponse.body}');
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Failed to remove ${item.name} from cart')),
                      );
                    }
                  } else {
                    allSuccess = false;
                    print('Checkout failed for ${item.name}: ${checkoutResponse.body}');
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Checkout failed: ${checkoutResponse.body}')),
                    );
                  }
                } catch (e) {
                  allSuccess = false;
                  print('Error: $e');
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error during checkout: $e')),
                  );
                }
              }

              if (allSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Checkout completed and cart updated')),
                );
                await fetchCartItems();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24),
            ),
            child: Text(
              'Place Order',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Checkout'),
        backgroundColor: Colors.brown[700],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: ListView(
                      children: [
                        _buildSectionTitle('Your Cart'),
                        ...cartItems.map(_buildCartItem),
                        Divider(color: Colors.brown[300], thickness: 1, indent: 16, endIndent: 16),
                        _buildShippingSection(),
                        Divider(color: Colors.brown[300], thickness: 1, indent: 16, endIndent: 16),
                        _buildShippingMethodSection(),
                        Divider(color: Colors.brown[300], thickness: 1, indent: 16, endIndent: 16),
                        _buildPaymentMethodSection(),
                      ],
                    ),
                  ),
                  _buildCheckoutButton(),
                ],
              ),
            ),
    );
  }
}
