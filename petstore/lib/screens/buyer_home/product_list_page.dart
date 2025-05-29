import 'package:flutter/material.dart';
import 'buyer_view_product.dart';
import 'dart:convert'; 
import 'package:http/http.dart' as http;
import 'package:petstore/api_endpoints.dart';

class ProductListPage extends StatefulWidget {
  const ProductListPage({super.key});

  @override
  _ProductListPageState createState() => _ProductListPageState();
}

class _ProductListPageState extends State<ProductListPage> {
  List<dynamic> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  fetchProducts() async {
    // Your API request to get products
    var response = await http.get(Uri.parse(ApiEndpoints.altProducts));
    var data = json.decode(response.body);

    setState(() {
      products = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Products")),
      body: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) {
          var product = products[index];
          return ListTile(
            leading: Image.network(product['image_path']),
            title: Text(product['name']),
            subtitle: Text('\$${product['price']}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BuyerViewProduct(
                    name: 'Buyer Name',
                    email: 'buyer@example.com',
                    phone: '1234567890',
                    address: '123 Street',
                    productName: product['name'],
                    price: product['price'],
                    rating: 4.5,
                    productDescription: product['description'],
                    productCategory: product['category'],
                    variations: product['variation'],
                    quantity: product['quantity'],
                    imagePath: product['image_path'],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
