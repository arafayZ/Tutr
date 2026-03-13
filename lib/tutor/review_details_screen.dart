import 'package:flutter/material.dart';
import '../widgets/custom_tab_header.dart';

class ReviewDetailsScreen extends StatelessWidget {
  final String name;
  final String rating;
  final String review;

  const ReviewDetailsScreen({
    super.key,
    required this.name,
    required this.rating,
    required this.review,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          // Header with Title and Back Button
          const CustomTabHeader(
            title: Text(
              "Reviews",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Course Summary Card matching your design
                  _buildCourseSummaryCard(),

                  const SizedBox(height: 30),

                  // Detailed Review Content
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.black,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            // Rating Badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEDF2FF),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(0xFF0961F5).withOpacity(0.2),
                                ),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.star, color: Colors.orange, size: 14),
                                  const SizedBox(width: 4),
                                  Text(
                                    rating,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Color(0xFF1A237E),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        Text(
                          review,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "2 Weeks Ago",
                          style: TextStyle(
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget to build the specific course card shown in your image
  Widget _buildCourseSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
          ),
        ],
      ),
      child: Row(
        children: [
          // Red Texture Image placeholder
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              image: const DecorationImage(
                image: NetworkImage('https://via.placeholder.com/100'), // Replace with your red asset
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Asim Ali Khan",
                  style: TextStyle(
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const Text(
                  "Physics",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                RichText(
                  text: const TextSpan(
                    style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
                    children: [
                      TextSpan(text: "2000 PKR ", style: TextStyle(fontSize: 16)),
                      TextSpan(
                        text: "Matric",
                        style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.normal),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    const Text(" 4.2  |  ", style: TextStyle(fontWeight: FontWeight.bold)),
                    Text(
                      "ONLINE",
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blueGrey[900],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}