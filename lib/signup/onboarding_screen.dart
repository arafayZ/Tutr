import 'package:flutter/material.dart';
import 'login_screen.dart';

// Defining a StatefulWidget because the screen needs to update when we swipe pages
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // PageController controls the movement (swiping) of the PageView
  final PageController _pageController = PageController();
  // Stores the index of the currently visible slide (0 to 3)
  int _currentPage = 0;

  // List of data for the onboarding slides (Image paths and descriptive text)
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
      backgroundColor: Colors.white, // Clean white background for a modern look
      body: SafeArea(
        // SafeArea ensures content doesn't go under the camera notch or status bar
        child: Column(
          children: [
            // Expanded takes up all available space above the bottom controls
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                // Updates the _currentPage state every time the user swipes
                onPageChanged: (int page) => setState(() => _currentPage = page),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  // Returns the custom content widget for the current slide
                  return OnboardingContent(
                    image: _pages[index]['image']!,
                    text: _pages[index]['text']!,
                  );
                },
              ),
            ),
            // The row containing the Back button, Dot indicators, and Next button
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // Method to create the navigation row at the bottom
  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Opacity hides the back button on the first slide while keeping the layout stable
          Opacity(
            opacity: _currentPage > 0 ? 1.0 : 0.0,
            child: _circleNavButton(
              icon: Icons.arrow_back,
              isFilled: false, // Outline version for "Back"
              onTap: () {
                // Moves to the previous slide with a smooth animation
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              },
            ),
          ),
          // Row of dots that show progress through the slides
          Row(
            children: List.generate(_pages.length, (index) => _buildIndicator(index)),
          ),
          // Next Button
          _circleNavButton(
            icon: Icons.arrow_forward,
            isFilled: true, // Solid black version for "Next"
            onTap: () {
              if (_currentPage < _pages.length - 1) {
                // Moves to the next slide
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                // If on the last slide, navigate to the Login Screen
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

  // Method to build a single dot indicator
  Widget _buildIndicator(int index) {
    bool isActive = _currentPage == index; // Checks if this dot matches the current page
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300), // Smoothly animates size and color
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: isActive ? 22 : 8, // Becomes a pill shape if active, circle if not
      decoration: BoxDecoration(
        color: isActive ? Colors.black : Colors.grey.shade200, // Black for active, grey for inactive
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }

  // Helper widget to create the circular navigation buttons
  Widget _circleNavButton({required IconData icon, required bool isFilled, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56, // Fixed diameter for a consistent circular look
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: isFilled ? Colors.black : Colors.transparent, // Solid or transparent
          border: isFilled ? null : Border.all(color: Colors.black, width: 1), // Black border for back button
        ),
        child: Icon(icon, color: isFilled ? Colors.white : Colors.black, size: 24),
      ),
    );
  }
}

// --- CONTENT WIDGET WITH OPTIMIZED IMAGE SIZING ---
class OnboardingContent extends StatelessWidget {
  final String image, text;
  const OnboardingContent({super.key, required this.image, required this.text});

  @override
  Widget build(BuildContext context) {
    // Calculates screen height to make the image size responsive to different phones
    double screenHeight = MediaQuery.of(context).size.height;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center, // Vertically centers the content
      children: [
        // Image Container
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 50), // Keeps image away from screen edges
          // Image height is capped at 35% of the total screen height
          height: screenHeight * 0.35,
          child: Image.asset(
            image,
            fit: BoxFit.contain, // Prevents stretching; maintains original aspect ratio
            filterQuality: FilterQuality.high, // Ensures the image is scaled smoothly (less pixelation)
          ),
        ),
        // Spacer that takes 5% of screen height
        SizedBox(height: screenHeight * 0.05),
        // Text Padding
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 45),
          child: Text(
            text,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20, // Clean, readable size
              fontWeight: FontWeight.bold,
              color: Colors.black,
              letterSpacing: -0.2, // Modern typography feel
              height: 1.4, // Line spacing for readability
            ),
          ),
        ),
      ],
    );
  }
}