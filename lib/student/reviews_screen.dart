import 'package:flutter/material.dart';
import 'write_review_screen.dart';

class ReviewsScreen extends StatefulWidget {
  // 1. Add the courseData parameter
  final Map<String, dynamic> courseData;

  const ReviewsScreen({super.key, required this.courseData});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 30),
                  _buildRatingSummary(),
                  const SizedBox(height: 30),
                  _buildReviewList(),
                  const SizedBox(height: 20),
                  _buildWriteReviewButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(35),
          bottomRight: Radius.circular(35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
              ),
            ),
          ),
          const Text(
            "Reviews & Ratings",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          ),
        ],
      ),
    );
  }

  Widget _buildRatingSummary() {
    return Column(
      children: [
        const Text(
          "4.8",
          style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) => const Icon(Icons.star, color: Colors.orange, size: 24)),
        ),
        const SizedBox(height: 8),
        const Text("Based on 448 Reviews", style: TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }

  Widget _buildReviewList() {
    final reviews = [
      {"name": "Ali Khan", "rating": "4.2", "comment": "Great tutor! Helped me understand Physics concepts clearly and improved my grades.", "date": "2 Weeks Ago"},
      {"name": "Abdul Rafay", "rating": "4.2", "comment": "Great tutor! Helped me understand Physics concepts clearly.", "date": "2 Hours Ago"},
      {"name": "Sara Ahmed", "rating": "4.8", "comment": "Excellent teaching! My problem-solving skills have improved a lot.", "date": "2 Weeks Ago"},
      {"name": "Bilal Raza", "rating": "4.6", "comment": "Interactive and clear lessons. I feel more confident in my exams now.", "date": "2 Weeks Ago"},
    ];

    return Column(children: reviews.map((data) => _buildReviewCard(data)).toList());
  }

  Widget _buildReviewCard(Map<String, dynamic> data) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(radius: 25, backgroundColor: Colors.black, child: Icon(Icons.person, color: Colors.white)),
              const SizedBox(width: 15),
              Expanded(child: Text(data['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black))),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(border: Border.all(color: Colors.blue), borderRadius: BorderRadius.circular(15)),
                child: Row(
                  children: [
                    const Icon(Icons.star, color: Colors.orange, size: 14),
                    const SizedBox(width: 4),
                    Text(data['rating'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.black)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(data['comment'], style: const TextStyle(fontSize: 14, color: Colors.grey, height: 1.4)),
          const SizedBox(height: 15),
          Text(data['date'], style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black)),
        ],
      ),
    );
  }

  Widget _buildWriteReviewButton(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              // 2. Access widget.courseData here
              builder: (context) => WriteReviewScreen(courseData: widget.courseData),
            ),
          );
        },
        child: Container(
          height: 55,
          padding: const EdgeInsets.symmetric(horizontal: 25),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(30),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
            ],
          ),
          child: IntrinsicWidth(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Write a Review",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 15),
                Container(
                  height: 35,
                  width: 35, // Balanced width
                  decoration: const BoxDecoration(
                      color: Colors.white, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_forward, color: Colors.black, size: 18),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}