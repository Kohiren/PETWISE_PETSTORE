import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'checkout.dart'; // Import checkout.dart here
import 'package:petstore/api_endpoints.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: MyHomePage(),
  ));
}



// CartItem model
class CartItem {
  final int id;
  final String imagePath;
  final String name;
  final double price;
  int quantity;
  bool isSelected; // Added for checkbox

  CartItem({
    required this.id,
    required this.imagePath,
    required this.name,
    required this.price,
    required this.quantity,
    this.isSelected = false, // Initialize to false
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: json['id'],
      imagePath: json['image_path'],
      name: json['name'],
      price: double.tryParse(json['price'].toString()) ?? 0.0,
      quantity: int.tryParse(json['quantity'].toString()) ?? 1,
      isSelected:
          false, // Default value. Crucial for new items from the server.
    );
  }
}

// Main Home Page
class MyHomePage extends StatelessWidget {
  const MyHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildBuyerAppBar(context),
      body: Center(child: Text('Welcome to the Store')),
    );
  }
}

// Cart Page
class CartPage extends StatefulWidget {
  const CartPage({super.key});

  @override
  _CartPageState createState() => _CartPageState();
}

class _CartPageState extends State<CartPage> {
  List<CartItem> cartItems = [];
  bool isLoading = true;
  bool _selectAll =
      false; // Track the state of the "Select All" checkbox.

  @override
  void initState() {
    super.initState();
    fetchCartItems();
  }

  Future<void> fetchCartItems() async {
    final response = await http.get(Uri.parse(ApiEndpoints.cart));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        cartItems = data.map((item) => CartItem.fromJson(item)).toList();
        isLoading =
            false; // Set isLoading to false after successfully fetching data
      });
    } else {
      print('Failed to load cart items');
      setState(() {
        isLoading =
            false; // Even on error, set isLoading to false to prevent the loading indicator from spinning forever.
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load cart items')),
      ); // Show error to user
    }
  }

  double get totalPrice => cartItems
      .where((item) => item.isSelected) // Only selected items.
      .fold(0, (sum, item) => sum + item.price * item.quantity);

  void incrementQuantity(int index) {
    setState(() {
      cartItems[index].quantity++;
    });
  }

  void decrementQuantity(int index) {
    setState(() {
      if (cartItems[index].quantity > 1) cartItems[index].quantity--;
    });
  }

  void removeItem(int index) async {
    final int itemId = cartItems[index].id;

    final response = await http.delete(
  Uri.parse(ApiEndpoints.deleteCartItem(itemId.toString())), // convert int to String here
  );

    if (response.statusCode == 200) {
      setState(() {
        cartItems.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Item removed from cart')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete item from server')),
      );
    }
  }

  // Function to handle item selection
  void _toggleItemSelection(int itemId) {
    setState(() {
      final item = cartItems.firstWhere((item) => item.id == itemId);
      item.isSelected = !item.isSelected;
      // Update "Select All" checkbox
      _updateSelectAll();
    });
  }

  // Function to handle "Select All" checkbox
  void _handleSelectAll(bool? value) {
    if (value == null) return; // Important for null safety
    setState(() {
      _selectAll = value;
      for (var item in cartItems) {
        item.isSelected = value;
      }
    });
  }

  // Function to update the "Select All" checkbox state
  void _updateSelectAll() {
    setState(() {
      _selectAll =
          cartItems.every((item) => item.isSelected); // all selected = true
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildBuyerAppBar(context),
      backgroundColor: Colors.grey[100],
      body: isLoading
          ? Center(
              child: CircularProgressIndicator()) // Show loading indicator
          : cartItems.isEmpty
              ? Center(
                  child: Text('Your cart is empty',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                )
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Row(
                        children: [
                          Checkbox(
                            value: _selectAll,
                            onChanged: _handleSelectAll,
                          ),
                          Text(
                            'Select All',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        itemBuilder: (context, index) {
                          final item = cartItems[index];
                          return Card(
                            margin: EdgeInsets.symmetric(vertical: 8),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: item.isSelected,
                                    onChanged: (value) =>
                                        _toggleItemSelection(item.id),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      item.imagePath,
                                      width: 70,
                                      height: 70,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error,
                                              stackTrace) =>
                                          Icon(Icons.image_not_supported,
                                              size: 70),
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        SizedBox(height: 6),
                                        Text(
                                          "₱ ${item.price.toStringAsFixed(2)}",
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            IconButton(
                                              icon: Icon(
                                                  Icons.remove_circle_outline),
                                              onPressed: () =>
                                                  decrementQuantity(index),
                                            ),
                                            Text(
                                              '${item.quantity}',
                                              style: TextStyle(fontSize: 16),
                                            ),
                                            IconButton(
                                              icon: Icon(
                                                  Icons.add_circle_outline),
                                              onPressed: () =>
                                                  incrementQuantity(index),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete_outline,
                                        color: Colors.red),
                                    onPressed: () => removeItem(index),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, -2)),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Total",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "₱ ${totalPrice.toStringAsFixed(2)}",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green[700],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          ElevatedButton.icon(
                            onPressed: () {
                              // Filter out unselected items.
                              List<CartItem> selectedItems = cartItems
                                  .where((item) => item.isSelected)
                                  .toList();

                              if (selectedItems.isNotEmpty) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => CheckoutPage(
                                        totalAmount:
                                            totalPrice), // Pass the total of selected items
                                  ),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(
                                          'Please select items to checkout.')),
                                );
                              }
                            },
                            icon: Icon(Icons.payment),
                            label: Text("Proceed to Checkout"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFF220F01),
                              padding: EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}

// Custom AppBar with Search and Cart
PreferredSizeWidget buildBuyerAppBar(BuildContext context) {
  return AppBar(
    backgroundColor: Color(0xFF220F01),
    title: Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 36,
            child: TextField(
              decoration: InputDecoration(
                hintText: "Search...",
                filled: true,
                fillColor: Colors.white,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
              ),
              style: TextStyle(fontSize: 14),
            ),
          ),
        ),
        IconButton(
          icon: Icon(Icons.shopping_cart),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CartPage()),
            );
          },
        ),
      ],
    ),
  );
}
