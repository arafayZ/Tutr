import 'package:flutter/material.dart';

// --- Imports for your existing screens and widgets ---
import '../widgets/student_bottom_nav.dart';
import 'search_screen.dart';
import '../tutor/notifications_screen.dart';
import 'top_tutors_screen.dart';
import 'matric_screen.dart';
import 'intermediate_screen.dart';
import 'o_a_level_screen.dart';
import 'entrance_test_screen.dart';
import 'profile_screen.dart'; // Ensure this matches your file name

// --- 1. DATA MODELS ---
class Tutor {
  final String name;
  final String? profilePic;
  Tutor({required this.name, this.profilePic});
}

class Course {
  final String tutorName, subject, level, price, rating, mode;
  final Color themeColor;

  Course({
    required this.tutorName,
    required this.subject,
    required this.level,
    required this.price,
    required this.rating,
    required this.mode,
    required this.themeColor,
  });
}

// --- 2. MAIN DASHBOARD ---
class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  final String userName = "Abdul Rafay";
  int _selectedIndex = 0;

  // List of screens for the Bottom Navigation Bar
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      _buildHomeContent(),                            // Index 0: Home
      const Center(child: Text("Connection Screen")),  // Index 1
      const Center(child: Text("Inbox Screen")),       // Index 2
      const Center(child: Text("Favourites Screen")),  // Index 3
      const ProfileScreen(),                          // Index 4: Profile
    ];
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      // Swapping the entire body based on selection
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: StudentBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }

  // Helper method to keep the Home UI separate from the Scaffold logic
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        children: [
          _HeaderSection(greeting: _getGreeting(), name: userName),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 25),
                const _PromoSlider(),
                const SizedBox(height: 30),
                const _CategorySelector(),
                const SizedBox(height: 30),
                _buildSectionTitle("Top Tutor", showSeeAll: true),
                const SizedBox(height: 15),
                const _TopTutorsList(),
                const SizedBox(height: 30),
                _buildSectionTitle("Recommended Courses", showSeeAll: false),
                const SizedBox(height: 15),
                const _RecommendedCoursesList(),
                const SizedBox(height: 130), // Space for Nav Bar
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {bool showSeeAll = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (showSeeAll)
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TopTutorsScreen()),
              );
            },
            child: const Row(
              children: [
                Text("SEE ALL ",
                    style: TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold, fontSize: 10)),
                Icon(Icons.arrow_forward_ios, size: 10, color: Color(0xFF2979FF)),
              ],
            ),
          ),
      ],
    );
  }
}

// --- 3. COMPONENT WIDGETS ---

class _HeaderSection extends StatelessWidget {
  final String greeting, name;
  const _HeaderSection({required this.greeting, required this.name});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 35),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(50),
          bottomRight: Radius.circular(50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 26,
                backgroundColor: Colors.white,
                backgroundImage: AssetImage('assets/images/rafay.jpeg'),
              ),
              const Spacer(),
              _HeaderActionBtn(
                  icon: Icons.search,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SearchScreen()))
              ),
              const SizedBox(width: 12),
              _HeaderActionBtn(
                  icon: Icons.notifications_none_outlined,
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const NotificationsScreen()))
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(greeting, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w400)),
          const SizedBox(height: 4),
          Text(name, style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _HeaderActionBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _HeaderActionBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 21),
      ),
    );
  }
}

class _PromoSlider extends StatefulWidget {
  const _PromoSlider();

  @override
  State<_PromoSlider> createState() => _PromoSliderState();
}

class _PromoSliderState extends State<_PromoSlider> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> ads = [
    {
      "title": "Today's Special",
      "subtitle": "25% OFF*",
      "desc": "Get a Discount for Every Course Order only Valid for Today!",
      "colors": [const Color(0xFF2979FF), const Color(0xFF0D47A1)]
    },
    {
      "title": "Flash Sale",
      "subtitle": "50% OFF",
      "desc": "Join our premium Mathematics masterclass at half price!",
      "colors": [const Color(0xFFFF5252), const Color(0xFFB71C1C)]
    },
    {
      "title": "New Arrival",
      "subtitle": "FREE DEMO",
      "desc": "Check out our new Physics laboratory sessions starting this week.",
      "colors": [const Color(0xFF00BFA5), const Color(0xFF004D40)]
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 160,
          child: PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) => setState(() => _currentPage = page),
            itemCount: ads.length,
            itemBuilder: (context, index) {
              return Container(
                margin: const EdgeInsets.only(right: 10),
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  gradient: LinearGradient(
                    colors: ads[index]['colors'],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(ads[index]['subtitle'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                    Text(ads[index]['title'], style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(ads[index]['desc'], style: const TextStyle(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(ads.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(right: 5),
            width: _currentPage == i ? 18 : 6, height: 6,
            decoration: BoxDecoration(
                color: _currentPage == i ? Colors.amber : Colors.black12,
                borderRadius: BorderRadius.circular(5)
            ),
          )),
        )
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  const _CategorySelector();

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> categories = [
      {"name": "Matric", "screen": const MatricScreen()},
      {"name": "Intermediate", "screen": const IntermediateScreen()},
      {"name": "O & A Level", "screen": const OALevelScreen()},
      {"name": "Entrance Test", "screen": const EntranceTestScreen()},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Categories", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        SizedBox(
          height: 35,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: categories.length,
            itemBuilder: (context, i) {
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => categories[i]['screen']),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(right: 25),
                  child: Text(
                    categories[i]['name'],
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _TopTutorsList extends StatelessWidget {
  const _TopTutorsList();

  @override
  Widget build(BuildContext context) {
    final List<Tutor> tutors = [
      Tutor(name: "Sana Khan"),
      Tutor(name: "Ali Khan"),
      Tutor(name: "Fatima Iqbal"),
      Tutor(name: "Hassan Javed"),
    ];

    return SizedBox(
      height: 110,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: tutors.length,
        itemBuilder: (context, i) {
          return Padding(
            padding: const EdgeInsets.only(right: 20),
            child: Column(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 4))
                      ]),
                  child: const Icon(Icons.person, size: 40, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(tutors[i].name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecommendedCoursesList extends StatelessWidget {
  const _RecommendedCoursesList();

  @override
  Widget build(BuildContext context) {
    final List<Course> courses = [
      Course(tutorName: "Asim Ali Khan", subject: "Mathematics", level: "Metric", price: "1800/-", rating: "4.2", mode: "ONLINE", themeColor: const Color(0xFF8C1414)),
      Course(tutorName: "Anzala Abid", subject: "English", level: "O Level", price: "2000/-", rating: "4.2", mode: "TUTOR HOME", themeColor: const Color(0xFF1A314D)),
      Course(tutorName: "Hiba Khan", subject: "Chemistry", level: "Intermediate", price: "1900/-", rating: "4.2", mode: "STUDENT HOME", themeColor: const Color(0xFF630A0A)),
    ];

    return Column(
      children: courses.map((c) => _CourseCard(course: c)).toList(),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final Course course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 130,
            width: double.infinity,
            decoration: BoxDecoration(
              color: course.themeColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(course.level, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(course.price, style: const TextStyle(color: Color(0xFF2979FF), fontWeight: FontWeight.bold, fontSize: 15)),
                    const _CardDivider(),
                    const Icon(Icons.star, color: Colors.amber, size: 16),
                    Text(" ${course.rating}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    const _CardDivider(),
                    Text(course.mode, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}

class _CardDivider extends StatelessWidget {
  const _CardDivider();
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 10),
      child: Text("|", style: TextStyle(color: Colors.grey, fontSize: 16)),
    );
  }
}