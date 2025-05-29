import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';  // Import cached_network_image

class HomeProduct extends StatelessWidget {
  final String productName;
  final double price;
  final double rating;
  final String imagePath;  // Added for product image
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle; // Callback for favorite toggle
  final ValueChanged<int> onStarTap; // Callback for star rating change

  const HomeProduct({
    super.key,
    required this.productName,
    required this.price,
    required this.rating,
    required this.imagePath, // Required to display product image
    this.isFavorite = false,
    required this.onFavoriteToggle,
    required this.onStarTap, // Added the callback for stars
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon + Favorite
          Stack(
            children: [
              // Product image with responsive sizing
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Container(
                  width: double.infinity,
                  height: 130,
                  color: Color.fromARGB(255, 255, 255, 255),
                  child: Padding(
                    padding: const EdgeInsets.all(12), // Add padding around the image
                    child: imagePath.isNotEmpty
                        ? imagePath.startsWith('http')
                            ? CachedNetworkImage(
                                imageUrl: imagePath,
                                fit: BoxFit.contain, // Adjusts image size within bounds
                                placeholder: (context, url) => const Center(
                                  child: CircularProgressIndicator(),
                                ),
                                errorWidget: (context, url, error) => const Center(
                                  child: Icon(
                                    Icons.error,
                                    size: 60,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : Image.asset(
                                imagePath,
                                fit: BoxFit.contain, // Same for local assets
                              )
                        : const Center(
                            child: Icon(
                              Icons.image,
                              size: 60,
                              color: Colors.grey,
                            ),
                          ),
                  ),
                ),
              ),
              // Favorite icon
              Positioned(
                top: 8,
                right: 8,
                child: GestureDetector(
                  onTap: () => onFavoriteToggle(!isFavorite),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          // Product Name
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              productName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Price and Clickable Stars
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '\$${price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    final isFilled = index < rating.round();
                    return GestureDetector(
                      onTap: () => onStarTap(index + 1), // Star tap callback
                      child: Icon(
                        isFilled ? Icons.star : Icons.star_border,
                        size: 16,
                        color: Colors.orangeAccent,
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
