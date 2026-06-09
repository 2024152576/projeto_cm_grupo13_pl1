import 'package:flutter/material.dart';

class ReviewLikeButton extends StatelessWidget {
  final int likes;
  final bool isLiked;
  final VoidCallback? onTap;

  const ReviewLikeButton({
    super.key,
    required this.likes,
    required this.isLiked,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = '$likes ${likes == 1 ? 'Gosto' : 'Gostos'}';

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLiked ? Icons.favorite : Icons.favorite_border,
            color: isLiked ? const Color(0xFFFF8282) : Colors.grey,
            size: 20,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
