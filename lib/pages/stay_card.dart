import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';

String formatCurrency(String priceString) {
  try {
    final price = int.tryParse(priceString) ?? 0;
    final formatter = NumberFormat("#,###", "vi_VN");
    return '${formatter.format(price).replaceAll(",", ".")}';
  } catch (_) {
    return priceString;
  }
}

class StayCard extends StatelessWidget {
  final String imagePath;
  final String title;
  final String price;
  final String rating;
  final bool isLiked;
  final VoidCallback? onTap;
  final VoidCallback? onLikePressed;

  const StayCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.price,
    required this.rating,
    this.isLiked = false,
    this.onTap,
    this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: 120,
        child: Card(
          color: const Color.fromARGB(255, 248, 247, 253),
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          clipBehavior: Clip.antiAlias,
          child: Row(
            children: [
              // Ảnh bên trái
              SizedBox(
                width: 120,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CachedNetworkImage(
                      imageUrl: imagePath,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: Colors.grey.shade300,
                        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                      ),
                      errorWidget: (context, url, error) => const Icon(Icons.broken_image),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: GestureDetector(
                        onTap: onLikePressed,
                        child: Container(
                          width: 26,
                          height: 26,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            size: 14,
                            color: isLiked ? Colors.purple : Colors.purple[200],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Thông tin bên phải
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${formatCurrency(price)} VND/đêm',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            rating,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
