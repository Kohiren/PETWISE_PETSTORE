import 'package:flutter/material.dart';
import '../login.dart';

PreferredSizeWidget buildHomeAppBar(BuildContext context) {
  return PreferredSize(
    preferredSize: Size.fromHeight(70),
    child: AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Color(0xFF220F01),
      title: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 35,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: "Search...",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(
                          borderSide: BorderSide.none,
                          borderRadius: BorderRadius.horizontal(left: Radius.circular(10)),
                        ),
                        contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 11),
                      ),
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFE03E0B),
                      borderRadius: BorderRadius.horizontal(right: Radius.circular(10)),
                    ),
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.search, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.shopping_cart, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.message, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (_) => LoginPage()));
            },
          ),
        ],
      ),
    ),
  );
}
