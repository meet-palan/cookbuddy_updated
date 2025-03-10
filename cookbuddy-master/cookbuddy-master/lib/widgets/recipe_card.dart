import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class RecipeCard extends StatelessWidget {
  final String title;
  final Uint8List? imageBytes;
  final String time;
  final String author;
  final double rating;
  final bool showFavorite;
  final bool showMenu;
  final bool isFavorite;
  final VoidCallback onFavoritePressed;
  final VoidCallback onTap;
  final VoidCallback onEditPressed;
  final VoidCallback onDeletePressed;

  const RecipeCard({
    super.key,
    required this.title,
    required this.imageBytes,
    required this.time,
    required this.author,
    required this.rating,
    required this.isFavorite,
    required this.onFavoritePressed,
    required this.onTap,
    required this.onEditPressed,
    required this.onDeletePressed,
    required this.showFavorite,
    required this.showMenu,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        elevation: 4,
        margin: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Recipe Image
              imageBytes != null
                  ? Image.memory(
                      imageBytes!,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: 180,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child:
                          const Icon(Icons.image, size: 50, color: Colors.grey),
                    ),

              // Gradient Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.1),
                        Colors.black.withOpacity(0.8),
                      ],
                    ),
                  ),
                ),
              ),

              // Top Section (Rating Left, Favorite & Menu Right)
              Positioned(
                top: 7,
                left: 10,
                right: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Rating Badge (Left Side)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.star,
                              color: Colors.yellow, size: 16),
                          const SizedBox(width: 4),
                          Text(
                            "$rating",
                            style: GoogleFonts.lora(
                                color: Colors.white, fontSize: 14),
                          ),
                        ],
                      ),
                    ),

                    // Favorite & Menu (Right Side)
                    Row(
                      children: [
                        // Show favorite button only if showFavorite is true
                        if (showFavorite)
                          GestureDetector(
                            onTap: onFavoritePressed,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.8),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFavorite ? Colors.red : Colors.black,
                              ),
                            ),
                          ),

                        const SizedBox(
                            width: 8), // Space between Favorite and Menu

                        // Show menu button if showMenu is true, else add empty space to maintain layout
                        showMenu
                            ? PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') {
                                    onEditPressed();
                                  } else if (value == 'delete') {
                                    onDeletePressed();
                                  }
                                },
                                itemBuilder: (context) => [
                                  PopupMenuItem(
                                    value: 'edit',
                                    child: ListTile(
                                      leading: Icon(Icons.edit,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary),
                                      title: Text(
                                        'Edit',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .primary),
                                      ),
                                    ),
                                  ),
                                  PopupMenuItem(
                                    value: 'delete',
                                    child: ListTile(
                                      leading: Icon(Icons.delete,
                                          color: Theme.of(context)
                                              .colorScheme
                                              .error),
                                      title: Text(
                                        'Delete',
                                        style: TextStyle(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .error),
                                      ),
                                    ),
                                  ),
                                ],
                                icon: const Icon(Icons.more_vert,
                                    color: Colors.black54),
                                color: Theme.of(context).cardColor,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              )
                            : const SizedBox(
                                width: 1), // Keeps spacing same even if hidden
                      ],
                    ),
                  ],
                ),
              ),

              // Recipe Name & Details (Bottom Overlay)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(12),
                      bottomRight: Radius.circular(12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.lora(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.access_time_filled_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                time,
                                style: GoogleFonts.lora(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              const Icon(Icons.person,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 6),
                              Text(
                                author,
                                style: GoogleFonts.lora(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold),
                              ),
                            ],
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
