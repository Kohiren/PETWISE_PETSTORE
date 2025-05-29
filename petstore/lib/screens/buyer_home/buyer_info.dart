import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'buyer_notification.dart';
import 'buyer_home.dart';
import 'package:petstore/screens/home/home.dart'; // Import the Home page

class BuyerInfoPage extends StatelessWidget {
  final String name;
  final String email;
  final String phone;
  final String address;

  BuyerInfoPage({super.key, 
    required this.name,
    required this.email,
    required this.phone,
    required this.address,
  });

  // Common dark brown color
  final Color appThemeColor = Color(0xFF220F01);

  // Logout confirmation dialog
  Future<void> _showLogoutDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.exit_to_app,
                  color: Colors.redAccent,
                  size: 40.0,
                ),
                SizedBox(height: 20),
                Text(
                  'Logout',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Are you sure you want to log out?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'No',
                        style: TextStyle(fontSize: 16, color: Colors.black),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => Home()), // Redirect to Home screen
                        );
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                      ),
                      child: Text(
                        'Yes',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Buyer Information'),
        backgroundColor: appThemeColor, // Updated AppBar color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text('Name', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(name),
            ),
            Divider(),
            ListTile(
              title: Text('Email', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(email),
            ),
            Divider(),
            ListTile(
              title: Text('Phone', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(phone),
            ),
            Divider(),
            ListTile(
              title: Text('Address', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              subtitle: Text(address),
            ),
            Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () {
                  print('Edit Profile Clicked');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: appThemeColor,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Edit Profile'),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: ElevatedButton(
                onPressed: () => _showLogoutDialog(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  textStyle: TextStyle(fontSize: 16),
                ),
                child: Text('Logout'),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        color: appThemeColor, // Updated BottomAppBar color
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
              IconButton(icon: Icon(Icons.category, color: Colors.white), onPressed: () {}),
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
                onPressed: () async {
                  try {
                    final doc = await FirebaseFirestore.instance
                        .collection('last')
                        .doc('signup')
                        .get();

                    if (doc.exists) {
                      final data = doc.data() as Map<String, dynamic>;

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BuyerInfoPage(
                            name: data['firstname'] ?? 'N/A',
                            email: data['email'] ?? 'N/A',
                            phone: data['phone'] ?? 'N/A',
                            address: data['barangay'] ?? 'N/A',
                          ),
                        ),
                      );
                    } else {
                      print('No user data found.');
                    }
                  } catch (e) {
                    print('Error fetching user data: $e');
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
