import 'package:flutter/material.dart';
import 'tutor_profile_screen.dart'; //

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  // Data modeled after the Favourites UI
  final List<Map<String, dynamic>> _favourites = [
    {
      "name": "Hiba Khan",
      "subject": "English",
      "price": "2500 PKR",
      "level": "O Level",
      "rating": "4.2",
      "mode": "ONLINE",
      "color": Colors.brown,
    },
    {
      "name": "Asif Ali Khan",
      "subject": "Physics",
      "price": "2000 PKR",
      "level": "Matric",
      "rating": "4.2",
      "mode": "TUTOR HOME",
      "color": Colors.green.shade900,
    },
    {
      "name": "Ali Imran",
      "subject": "Urdu",
      "price": "2200 PKR",
      "level": "Intermediate",
      "rating": "4.0",
      "mode": "STUDENT HOME",
      "color": Colors.blue.shade300,
    },
    {
      "name": "Sameer Arif",
      "subject": "Biology",
      "price": "56 USD",
      "oldPrice": "71 USD",
      "level": "",
      "rating": "4.9",
      "mode": "ONLINE",
      "color": Colors.blue.shade900,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              physics: const BouncingScrollPhysics(),
              itemCount: _favourites.length,
              itemBuilder: (context, index) {
                // Pass the specific tutor data to the card builder
                return _buildFavouriteCard(context, _favourites[index]);
              },
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 30),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          "Favourites",
          style: TextStyle(
            color: Colors.black,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFavouriteCard(BuildContext context, Map<String, dynamic> data) {
    return GestureDetector(
      // Navigation trigger to open the Tutor Profile
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TutorProfileScreen(tutorData: data),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Container(
                width: 90,
                decoration: BoxDecoration(
                  color: data['color'],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            data['name'],
                            style: const TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                          const Icon(Icons.favorite, color: Colors.red, size: 18),
                        ],
                      ),
                      Text(
                        data['subject'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Text(
                            data['price'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          if (data['oldPrice'] != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              data['oldPrice'],
                              style: const TextStyle(
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                                fontSize: 12,
                              ),
                            ),
                          ],
                          const SizedBox(width: 8),
                          Text(
                            data['level'],
                            style: const TextStyle(color: Colors.grey, fontSize: 11),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            data['rating'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 11,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text("|", style: TextStyle(color: Colors.grey)),
                          const SizedBox(width: 8),
                          Text(
                            data['mode'],
                            style: const TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                              fontSize: 10,
                            ),
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