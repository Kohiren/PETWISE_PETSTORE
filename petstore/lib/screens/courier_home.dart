import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:petstore/api_endpoints.dart';

class CourierScreen extends StatefulWidget {
  const CourierScreen({super.key});

  @override
  _CourierScreenState createState() => _CourierScreenState();
}

class _CourierScreenState extends State<CourierScreen> {
  List<dynamic> _deliveries = [];

  @override
  void initState() {
    super.initState();
    _fetchAssignedDeliveries();
  }

  Future<void> _fetchAssignedDeliveries() async {
    final response = await http.get(
      Uri.parse(ApiEndpoints.assignedDeliveries),
    );

    if (response.statusCode == 200) {
      setState(() {
        _deliveries = json.decode(response.body);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load deliveries')),
      );
    }
  }

 Future<void> _markAsDelivered(int index, String productName, String address, String createdAt) async {
  final url = Uri.parse(ApiEndpoints.markDelivered); // Use the markDelivered endpoint

  try {
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'product_name': productName,
        'address': address,
        'created_at': createdAt,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _deliveries.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order marked as delivered!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed: ${response.body}')),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}


  String _formatTime(String datetime) {
    final dt = DateTime.parse(datetime);
    return DateFormat('MMM d, yyyy • h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text(
          "PETWISE XPRESS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 20,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.teal.shade700,
        elevation: 3,
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildRiderProfile(),
          const SizedBox(height: 20),
          _buildStatsCards(),
          const SizedBox(height: 20),
          _buildAssignedDeliveriesList(),
        ],
      ),
    );
  }

  Widget _buildRiderProfile() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.teal.shade100,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 35,
            backgroundImage: AssetImage("assets/images/courier.jpg"),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                "Welcome, Marco!",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 4),
              Text("PETWISE Delivery Rider", style: TextStyle(color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard("Today’s Deliveries", _deliveries.length.toString(), Icons.delivery_dining),
        _buildStatCard("Completed", "12", Icons.check_circle),
      ],
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.teal.shade50,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 28, color: Colors.teal),
            const SizedBox(height: 8),
            Text(
              count,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignedDeliveriesList() {
    if (_deliveries.isEmpty) {
      return const Center(
        child: Text(
          "No assigned deliveries.",
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Assigned Deliveries",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        ..._deliveries.asMap().entries.map((entry) {
          int index = entry.key;
          var delivery = entry.value;
          return Column(
            children: [
              _buildDeliveryCard(
                index: index,
                name: delivery['product_name'],
                address: delivery['address'],
                timeRaw: delivery['created_at'],
              ),
              const SizedBox(height: 10),
            ],
          );
        }),
      ],
    );
  }

  Widget _buildDeliveryCard({
    required int index,
    required String name,
    required String address,
    required String timeRaw,
  }) {
    final formattedTime = _formatTime(timeRaw);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 6,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.pets, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(
                child: Text(name,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.teal),
              const SizedBox(width: 8),
              Expanded(child: Text(address)),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              const Icon(Icons.access_time, color: Colors.teal),
              const SizedBox(width: 8),
              Text(formattedTime),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    _markAsDelivered(index, name, address, timeRaw);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Mark as Delivered"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
