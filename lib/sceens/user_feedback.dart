import 'package:flutter/material.dart';

Widget userFeedbackTile(
  String name,
  String review,
  int rating,
  String timeAgo,
  String avatarAsset,
) {
  return ListTile(
    leading: CircleAvatar(
      backgroundImage: AssetImage(avatarAsset),
      radius: 24,
    ),
    title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
    subtitle: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(review),
        Row(
          children: List.generate(
            5,
            (index) => Icon(
              index < rating ? Icons.star : Icons.star_border,
              color: Colors.orange,
              size: 16,
            ),
          ),
        ),
        Text(timeAgo, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    ),
  );
}
