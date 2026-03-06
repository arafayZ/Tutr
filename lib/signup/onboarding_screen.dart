import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> _pages = [
    {
      "image": "assets/images/slidebar1.png",
      "text": "Let’s help you connect with the right tutors and students faster."
    },
    {
      "image": "assets/images/slidebar2.png",
      "text": "Discover skills, subjects, and learning opportunities that matter."
    },
    {
      "image": "assets/images/slidebar3.png",
      "text": "Start lessons or teach in just a few taps."
    },
    {
      "image": "assets/images/slidebar4.png",
      "text": "Learn, teach, and grow together, all in one app."
    },
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
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Opacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            child: _navButton(
              icon: Icons.arrow_back,
              onTap: () {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          Row(
            children: List.generate(_pages.length, (index) => _buildIndicator(index)),
          ),
          _navButton(
            icon: Icons.arrow_forward,
            onTap: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 22 : 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // UPDATED: Removed circle decoration and used simple icons
  Widget _navButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Makes the empty space around the icon clickable
      child: SizedBox(
        width: 56,
        height: 56,
        child: Icon(
          icon,
          color: Colors.black, // Clean black icon on your white background
          size: 30, // Increased size slightly to make up for the missing circle
        ),
      ),
    );
  }
} // <--- End of State class

// --- CONTENT WIDGET ---
class OnboardingContent extends StatelessWidget {
  final String image, text;
  const OnboardingContent({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          height: screenHeight * 0.35,
          child: Image.asset(
            image,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
          ),
        ),
        SizedBox(height: screenHeight * 0.05),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.2,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}