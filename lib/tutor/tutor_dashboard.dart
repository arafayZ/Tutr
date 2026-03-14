import 'package:flutter/material.dart';

// Import custom screen files for navigation
import 'student_category_screen.dart';
import 'my_bids_screen.dart';
import 'course_category_screen.dart';
import 'reviews_screen.dart';
import 'add_course_screen.dart';
import 'search_screen.dart';
import '../widgets/custom_bottom_nav.dart';

// --- 1. DATA MODEL ---
class Course {
  final String tutorName, subject, grade, price, rating, mode;
  final Color fallbackColor;
  final String? backgroundImage;

  Course({
    required this.tutorName,
    required this.subject,
    required this.grade,
    required this.price,
    required this.rating,
    required this.mode,
    required this.fallbackColor,
    this.backgroundImage,
  });
}

enum TutorStatus { pending, approvedEmpty, active }

// --- 2. MAIN DASHBOARD ---
class TutorDashboard extends StatefulWidget {
  const TutorDashboard({super.key});

  @override
  State<TutorDashboard> createState() => _TutorDashboardState();
}

class _TutorDashboardState extends State<TutorDashboard> {
  TutorStatus currentStatus = TutorStatus.active;
  String userName = "Abdul Rafay";
  String? profilePicPath = 'assets/images/rafay.jpeg';
  int activeStudents = 30;
  int activeCourses = 10;

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return "Good Morning";
    if (hour < 17) return "Good Afternoon";
    return "Good Evening";
  }

  @override
  Widget build(BuildContext context) {
    final String displayStudents = activeStudents.toString().padLeft(2, '0');
    final String displayCourses = activeCourses.toString().padLeft(2, '0');

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddCourseScreen()),
          );
        },
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 35),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Stack(
          children: [
            Container(
              height: 220,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFF1A1A1A),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 50),
                _TopProfileRow(greeting: _getGreeting(), name: userName, profilePic: profilePicPath),
                const SizedBox(height: 25),
                _StatCardsGrid(students: displayStudents, courses: displayCourses),
                const SizedBox(height: 35),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Activity Center", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 15),
                      const _ActivityCenterRow(),
                      const SizedBox(height: 40),
                      _buildDynamicContent(),
                      const SizedBox(height: 120),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: const CustomBottomNav(currentIndex: 0),
    );
  }

  Widget _buildDynamicContent() {
    switch (currentStatus) {
      case TutorStatus.pending:
        return const _PendingReviewView();
      case TutorStatus.approvedEmpty:
        return const _EmptyCoursesView();
      case TutorStatus.active:
        return const _ActiveCoursesListView();
    }
  }
}

// --- 3. STAT CARDS ---
class _StatCardsGrid extends StatelessWidget {
  final String students, courses;
  const _StatCardsGrid({required this.students, required this.courses});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Row(
        children: [
          _StatCard(
            count: students,
            label: "Active Students",
            colors: const [Color(0xFFE64D26), Color(0xFF8B2D17)],
          ),
          const SizedBox(width: 12),
          _StatCard(
            count: courses,
            label: "Active Courses",
            colors: const [Color(0xFF007EF2), Color(0xFF003D75)],
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String count, label;
  final List<Color> colors;
  const _StatCard({required this.count, required this.label, required this.colors});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 150,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 5),
            )
          ],
          gradient: LinearGradient(colors: colors, begin: Alignment.topLeft, end: Alignment.bottomRight),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(count, style: const TextStyle(color: Colors.white, fontSize: 42, fontWeight: FontWeight.bold)),
            Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}

// --- 4. COURSE CARD ---
class CourseCard extends StatelessWidget {
  final Course course;
  const CourseCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: course.fallbackColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
              image: course.backgroundImage != null ? DecorationImage(image: AssetImage(course.backgroundImage!), fit: BoxFit.cover) : null,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(course.tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(course.subject, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    Text(course.grade, style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(course.price, style: const TextStyle(color: Color(0xFF0961F5), fontWeight: FontWeight.bold, fontSize: 15)),
                    _buildDivider(),
                    const Icon(Icons.star, color: Colors.amber, size: 18),
                    Text(" ${course.rating}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    _buildDivider(),
                    Text(course.mode.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text("|", style: TextStyle(color: Colors.grey, fontSize: 18)),
  );
}

// --- 5. DYNAMIC VIEWS ---
class _ActiveCoursesListView extends StatelessWidget {
  const _ActiveCoursesListView();
  @override
  Widget build(BuildContext context) {
    final List<Course> mockDbData = [
      Course(tutorName: "Asim Ali Khan", subject: "Mathematics", grade: "Matric", price: "1800/-", rating: "4.2", mode: "Online", fallbackColor: const Color(0xFFAD1457)),
      Course(tutorName: "Abdul Rafay", subject: "Sindhi", grade: "Matric", price: "1000/-", rating: "3.2", mode: "Offline", fallbackColor: const Color(0xFFAD8E14)),
      Course(tutorName: "Anzala Abid", subject: "English", grade: "O Level", price: "2000/-", rating: "4.2", mode: "Tutor Home", fallbackColor: const Color(0xFF0D47A1)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Top Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        // Spread without .toList() to fix linting
        ...mockDbData.map((course) => CourseCard(course: course)),
      ],
    );
  }
}

class _PendingReviewView extends StatelessWidget {
  const _PendingReviewView();
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        children: [
          Icon(Icons.hourglass_bottom_rounded, size: 100, color: Color(0xFFE0E0E0)),
          SizedBox(height: 15),
          Text("Your account is under review.", style: TextStyle(color: Colors.grey)),
          Text("Some features are limited until approval.", style: TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}

class _EmptyCoursesView extends StatelessWidget {
  const _EmptyCoursesView();
  @override
  Widget build(BuildContext context) {
    return const Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Top Courses", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 40),
        Center(
          child: Column(
            children: [
              Icon(Icons.cancel_outlined, size: 100, color: Color(0xFFE0E0E0)),
              Text("Nothing Here Yet", style: TextStyle(color: Colors.grey, fontSize: 18)),
            ],
          ),
        ),
      ],
    );
  }
}

// --- 6. TOP PROFILE ROW ---
class _TopProfileRow extends StatelessWidget {
  final String greeting, name;
  final String? profilePic;
  const _TopProfileRow({required this.greeting, required this.name, this.profilePic});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            backgroundImage: profilePic != null ? AssetImage(profilePic!) : null,
            child: profilePic == null ? const Icon(Icons.person) : null,
          ),
          const SizedBox(width: 15),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(greeting, style: const TextStyle(color: Colors.white70, fontSize: 13)),
            Text(name, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
            child: const _CircleIconButton(icon: Icons.search),
          ),
          const SizedBox(width: 10),
          const _CircleIconButton(icon: Icons.notifications_none),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  const _CircleIconButton({required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white12, shape: BoxShape.circle),
      child: Icon(icon, color: Colors.white, size: 22),
    );
  }
}

// --- ACTIVITY CENTER ---
class _ActivityCenterRow extends StatelessWidget {
  const _ActivityCenterRow();
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActIcon(
          icon: Icons.person_outline,
          label: "Students",
          color: Colors.black,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const StudentCategoryScreen())),
        ),
        _ActIcon(
          icon: Icons.book_outlined,
          label: "Courses",
          color: Colors.black,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const CourseCategoryScreen())),
        ),
        _ActIcon(
          icon: Icons.gavel,
          label: "Bids",
          color: Colors.black,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyBidsScreen())),
        ),
        _ActIcon(
          icon: Icons.star_border,
          label: "Reviews",
          color: Colors.black,
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReviewsScreen())),
        ),
      ],
    );
  }
}

class _ActIcon extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _ActIcon({required this.icon, required this.label, required this.color, this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                )
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}