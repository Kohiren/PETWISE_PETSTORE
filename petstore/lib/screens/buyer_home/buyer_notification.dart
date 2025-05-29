import 'package:flutter/material.dart';

import 'buyer_info.dart';
import 'buyer_home.dart';

class BuyerNotificationPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  BuyerNotificationPage({super.key, 
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  final List<Map<String, String>> notifications = [
    {
      'title': 'Order Shipped!',
      'message': 'Your order #1234 has been shipped and is on its way.',
      'time': '2 hours ago'
    },
    {
      'title': 'Discount Offer',
      'message': 'Get 20% off on your next purchase! Use code: SAVE20.',
      'time': '1 day ago'
    },
    {
      'title': 'New Product Alert',
      'message': 'We have a new product in our store. Check it out now!',
      'time': '3 days ago'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications'),
        backgroundColor: Color(0xFF220F01), // Updated header color
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: notifications.length,
          itemBuilder: (context, index) {
            return _buildNotificationCard(
              notifications[index]['title']!,
              notifications[index]['message']!,
              notifications[index]['time']!,
            );
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF220F01), // Updated footer color
        child: Padding(
          padding: EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.home, color: Colors.white),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyerHome(
                        name: name,
                        email: email,
                        phone: phone,
                        address: address,
                      ),
                    ),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.category, color: Colors.white),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(Icons.notifications, color: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BuyerNotificationPage(
                        name: name,
                        email: email,
                        phone: phone,
                        address: address,
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
                        name: name,
                        email: email,
                        phone: phone,
                        address: address,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(String title, String message, String time) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 10),
      child: ListTile(
        contentPadding: EdgeInsets.all(16),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Colors.black87,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5.0),
          child: Text(
            message,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
        trailing: Text(
          time,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}
