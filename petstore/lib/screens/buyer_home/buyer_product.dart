import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class BuyerProduct extends StatelessWidget {
  final String productName;
  final double price;
  final double rating;
  final bool isFavorite;
  final ValueChanged<bool> onFavoriteToggle;
  final ValueChanged<int> onStarTap;
  final VoidCallback onTap;
  final String imagePath;

  const BuyerProduct({
    super.key,
    required this.productName,
    required this.price,
    required this.rating,
    this.isFavorite = false,
    required this.onFavoriteToggle,
    required this.onStarTap,
    required this.onTap,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 180,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
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
            Stack(
              children: [
                Container(
                  height: 130,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    color: Colors.white,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10), // Adjust inner spacing
                    child: imagePath.isEmpty
                        ? const Center(
                            child: Icon(
                              Icons.image_not_supported,
                              size: 50,
                              color: Colors.grey,
                            ),
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imagePath,
                              fit: BoxFit.contain, // Maintain aspect ratio
                              placeholder: (context, url) =>
                                  const Center(child: CircularProgressIndicator()),
                              errorWidget: (context, url, error) => const Center(
                                child: CircleAvatar(
                                  radius: 30,
                                  backgroundColor: Colors.grey,
                                  child: Icon(
                                    Icons.person,
                                    size: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
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

            // Price
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '₱${price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ),

            // Rating Stars
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                children: List.generate(5, (index) {
                  final isFilled = index < rating.round();
                  return GestureDetector(
                    onTap: () => onStarTap(index + 1),
                    child: Icon(
                      isFilled ? Icons.star : Icons.star_border,
                      size: 16,
                      color: Colors.orangeAccent,
                    ),
                  );
                }),
              ),
            ),

            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
