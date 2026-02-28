import 'package:flutter/material.dart';
import 'login_screen.dart'; // Navigation destination

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {"image": "assets/images/slidebar1.png", "text": "Let’s help you connect with the right tutors and students faster."},
    {"image": "assets/images/slidebar2.png", "text": "Discover skills, subjects, and learning opportunities that matter."},
    {"image": "assets/images/slidebar3.png", "text": "Start lessons or teach in just a few taps."},
    {"image": "assets/images/slidebar4.png", "text": "Learn, teach, and grow together, all in one app."},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (int page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  return OnboardingContent(
                    image: _pages[index]['image']!,
                    text: _pages[index]['text']!,
                  );
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _currentPage > 0
              ? _circleNavButton(Icons.arrow_back, isFilled: false, onTap: () {
            _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
          })
              : const SizedBox(width: 56),
          Row(
            children: List.generate(_pages.length, (index) => _buildIndicator(index)),
          ),
          _circleNavButton(Icons.arrow_forward, isFilled: true, onTap: () {
            if (_currentPage < _pages.length - 1) {
              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.ease);
            } else {
              // NAVIGATION FIXED: Go to Login Screen
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LoginScreen()),
              );
            }
          }),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.black : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  Widget _circleNavButton(IconData icon, {required bool isFilled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        width: 56,
        decoration: BoxDecoration(
          color: isFilled ? Colors.black : Colors.transparent,
          shape: BoxShape.circle,
          border: isFilled ? null : Border.all(color: Colors.grey.shade300, width: 1.5),
        ),
        child: Icon(icon, color: isFilled ? Colors.white : Colors.black),
      ),
    );
  }
}

class OnboardingContent extends StatelessWidget {
  final String image, text;
  const OnboardingContent({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(image, height: 300),
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, height: 1.4),
          ),
        ),
      ],
    );
  }
}