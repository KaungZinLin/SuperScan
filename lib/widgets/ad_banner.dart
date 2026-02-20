import 'package:flutter/material.dart';

class AdBanner extends StatelessWidget {
  const AdBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // ai generated code for temporary banner
    return Container(
      // margin: const EdgeInsets.all(16), // Optional: Add space around the ad
      width: double.infinity,
      height: 100, // Fixed height for the banner
      decoration: BoxDecoration(
        color: Colors.grey[200], // Placeholder color while loading
        borderRadius: BorderRadius.circular(12),
        image: const DecorationImage(
          image: AssetImage('assets/images/ad_test_atom_mm.jpg'),
          fit: BoxFit.cover, // Ensures the image fills the container
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}