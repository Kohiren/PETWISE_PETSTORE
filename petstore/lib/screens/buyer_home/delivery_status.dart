import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DeliveryStatusPage extends StatefulWidget {
  const DeliveryStatusPage({super.key});

  @override
  _DeliveryStatusPageState createState() => _DeliveryStatusPageState();
}

class _DeliveryStatusPageState extends State<DeliveryStatusPage> {
  int selectedIndex = 0;
  List<dynamic> orders = [];

  final List<String> statusTabs = ['To Pay', 'To Receive', 'Completed', 'Canceled'];
  final List<IconData> statusIcons = [Icons.payment, Icons.local_shipping, Icons.check_circle, Icons.cancel];
  final List<String> endpoints = ['checkout', 'receive_order', 'complete_order', 'cancelled_order'];

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Initial fetch
  }

  Future<void> fetchOrders() async {
    // Ensure the widget is still mounted before calling setState
    if (!mounted) return;

    final endpoint = endpoints[selectedIndex];
    final response = await http.get(Uri.parse('http://192.168:5000/$endpoint'));

    if (response.statusCode == 200) {
      setState(() {
        orders = json.decode(response.body);
      });
    } else {
      setState(() {
        orders = [];
      });
      print('Failed to load orders: ${response.statusCode}');
    }
  }

  Future<void> _showLeaveFeedbackDialog(Map order) async {
    final formKey = GlobalKey<FormState>();
    final TextEditingController commentController = TextEditingController();
    double rating = 3.0;
    List<XFile> mediaFiles = [];
    final ImagePicker picker = ImagePicker();

    Future<void> pickMedia(BuildContext dialogContext) async { // Pass dialogContext
      showModalBottomSheet(
          context: dialogContext, // Use dialogContext here
          builder: (context) {
            return SafeArea(
              child: Wrap(
                children: [
                  ListTile(
                    leading: Icon(Icons.photo_library),
                    title: Text('Pick Images'),
                    onTap: () async {
                      Navigator.pop(context);
                      final List<XFile> images = await picker.pickMultiImage();
                      // Using setState for the main widget state, but still safe
                      // as the dialog is still open at this point.
                      if (mounted) {
                        setState(() {
                        mediaFiles.addAll(images);
                      });
                      }
                                        },
                  ),
                  ListTile(
                    leading: Icon(Icons.videocam),
                    title: Text('Pick Video'),
                    onTap: () async {
                      Navigator.pop(context);
                      final XFile? video = await picker.pickVideo(source: ImageSource.gallery);
                      if (video != null) {
                        // Using setState for the main widget state, but still safe
                        // as the dialog is still open at this point.
                        if (mounted) {
                          setState(() {
                          mediaFiles.add(video);
                        });
                        }
                      }
                    },
                  ),
                ],
              ),
            );
          });
    }

    await showDialog(
      context: context,
      builder: (dialogContext) { // Renamed context to dialogContext
        return StatefulBuilder(builder: (context, setStateDialog) {
          // Use setStateDialog inside this dialog to update UI
          return AlertDialog(
            title: Text('Leave Feedback'),
            content: SingleChildScrollView(
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Product info
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order['product_image'] ?? '',
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: Colors.grey[300],
                              width: 60,
                              height: 60,
                              child: Icon(Icons.image, color: Colors.grey),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(order['product_name'] ?? 'No Name', style: TextStyle(fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("₱${order['price']}", style: TextStyle(color: Colors.brown[700])),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 12),

                    // Star rating
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Rate the product', style: TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(height: 6),
                    RatingBar.builder(
                      initialRating: rating,
                      minRating: 1,
                      maxRating: 5,
                      direction: Axis.horizontal,
                      allowHalfRating: true,
                      itemCount: 5,
                      itemSize: 30,
                      itemBuilder: (context, _) => Icon(Icons.star, color: Colors.amber),
                      onRatingUpdate: (newRating) {
                        setStateDialog(() {
                          rating = newRating;
                        });
                      },
                    ),
                    SizedBox(height: 12),

                    // Comment input
                    TextFormField(
                      controller: commentController,
                      maxLines: 3,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Write your comment',
                        alignLabelWithHint: true,
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a comment';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 12),

                    // Media previews
                    if (mediaFiles.isNotEmpty)
                      SizedBox(
                        height: 80,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: mediaFiles.length,
                          itemBuilder: (context, index) {
                            final file = mediaFiles[index];
                            final isVideo = file.path.endsWith('.mp4') || file.path.endsWith('.mov');
                            return Stack(
                              children: [
                                Container(
                                  margin: EdgeInsets.only(right: 8),
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: !isVideo
                                        ? DecorationImage(image: FileImage(File(file.path)), fit: BoxFit.cover)
                                        : null,
                                    color: Colors.black12,
                                  ),
                                  child: isVideo
                                      ? Center(
                                          child: Icon(Icons.videocam, size: 40, color: Colors.white70),
                                        )
                                      : null,
                                ),
                                Positioned(
                                  top: 0,
                                  right: 0,
                                  child: GestureDetector(
                                    onTap: () {
                                      setStateDialog(() {
                                        mediaFiles.removeAt(index);
                                      });
                                    },
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(Icons.close, size: 20, color: Colors.white),
                                    ),
                                  ),
                                )
                              ],
                            );
                          },
                        ),
                      ),

                    SizedBox(height: 12),

                    ElevatedButton.icon(
                      onPressed: () async {
                        await pickMedia(dialogContext); // Pass dialogContext here
                      },
                      icon: Icon(Icons.attach_file),
                      label: Text('Add Images/Videos'),
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext), // Use dialogContext
                child: Text('Cancel'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                onPressed: () async {
                  if (formKey.currentState!.validate()) {

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Submitting feedback...')),
                      );
                    }

                    var uri = Uri.parse('http://192.168:5000/submit_feedback');
                    var request = http.MultipartRequest('POST', uri);

                    request.fields['rating'] = rating.toString();
                    request.fields['comment'] = commentController.text;
                    request.fields['product_name'] = order['product_name'] ?? '';
                    request.fields['product_image'] = order['product_image'] ?? '';
                    request.fields['firstname'] = 'Jane Doe';
                    request.fields['profile_picture'] = 'https://example.com/placeholder_profile.jpg';

                    for (var file in mediaFiles) {
                      request.files.add(await http.MultipartFile.fromPath('media_files', file.path, filename: file.name));
                    }

                    try {
                      var streamedResponse = await request.send();
                      var response = await http.Response.fromStream(streamedResponse);

                      if (response.statusCode == 200) {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Feedback submitted successfully!')),
                          );
                        }
                        fetchOrders();
                      } else {
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to submit feedback: ${response.body}')),
                          );
                        }
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error submitting feedback: $e')),
                        );
                      }
                    }

                    // Now pop the dialog safely
                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  }
                },
                child: Text('Submit'),
              ),
            ],
          );
        });
      },
    );
  }

  Widget buildOrderItem(Map order) {
    return Card(
      margin: EdgeInsets.all(8),
      child: Column(
        children: [
          ListTile(
            leading: Image.network(
              order['product_image'] ?? '',
              width: 50,
              errorBuilder: (_, __, ___) => Icon(Icons.image),
            ),
            title: Text(order['product_name'] ?? 'No Name'),
            subtitle: Text("₱${order['price']} x ${order['quantity']}"),
            trailing: Text("₱${order['total_amount']}"),
          ),

          // Cancel Order button on "To Pay"
          if (selectedIndex == 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  onPressed: () async {
                    final response = await http.post(
                      Uri.parse('http://192.168:5000/api/cancel_order'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'product_name': order['product_name'],
                        'address': order['address'],
                        'created_at': order['created_at'],
                      }),
                    );

                    if (response.statusCode == 200) {
                      if (mounted) { // Add mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order cancelled successfully')),
                        );
                      }
                      fetchOrders();
                    } else {
                      if (mounted) { // Add mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to cancel order')),
                        );
                      }
                    }
                  },
                  child: Text("Cancel Order"),
                ),
              ),
            ),

          // Order Received button on "To Receive"
          if (selectedIndex == 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  onPressed: () async {
                    final response = await http.post(
                      Uri.parse('http://1192.168:5000/mark_order_received'),
                      headers: {'Content-Type': 'application/json'},
                      body: json.encode({
                        'id': order['id'], // make sure your 'order' has an 'id' field here
                      }),
                    );
                    if (response.statusCode == 200) {
                      if (mounted) { // Add mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Order marked as received')),
                        );
                      }
                      fetchOrders();
                    } else {
                      if (mounted) { // Add mounted check
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Failed to mark as received')),
                        );
                      }
                    }
                  },
                  child: Text("Order Received"),
                ),
              ),
            ),

          // Leave Feedback button on "Completed"
          if (selectedIndex == 2)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              child: Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.brown),
                  onPressed: () {
                    _showLeaveFeedbackDialog(order);
                  },
                  child: Text("Leave Feedback"),
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
        title: Text('My Orders'),
        centerTitle: true,
        backgroundColor: Colors.brown[400],
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(vertical: 12),
            color: Colors.brown[100],
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(statusTabs.length, (index) {
                final isSelected = index == selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedIndex = index;
                    });
                    fetchOrders();
                  },
                  child: Column(
                    children: [
                      Icon(statusIcons[index], color: isSelected ? Colors.brown : Colors.grey),
                      SizedBox(height: 6),
                      Text(
                        statusTabs[index],
                        style: TextStyle(
                          color: isSelected ? Colors.brown : Colors.grey,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                      if (isSelected)
                        Container(
                          margin: EdgeInsets.only(top: 6),
                          height: 2,
                          width: 40,
                          color: Colors.brown,
                        )
                    ],
                  ),
                );
              }),
            ),
          ),
          Expanded(
            child: orders.isEmpty
                ? Center(child: Text("No ${statusTabs[selectedIndex]} orders."))
                : ListView.builder(
                    itemCount: orders.length,
                    itemBuilder: (context, index) => buildOrderItem(orders[index]),
                  ),
          ),
        ],
      ),
    );
  }
}