import 'package:flutter/material.dart';
import '../widgets/custom_tab_header.dart';
import 'course_detail_screen.dart';
import 'student_profile_screen.dart';

// --- DATA MODELS ---
class CourseData {
  final String id, tutorName, subject, grade, price, rating, mode;
  final Color color;

  CourseData({
    required this.id,
    required this.tutorName,
    required this.subject,
    required this.grade,
    required this.price,
    required this.rating,
    required this.mode,
    required this.color,
  });

  // Helper to convert object to Map to satisfy your screen's requirement
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'tutorName': tutorName,
      'subject': subject,
      'grade': grade,
      'price': price,
      'rating': rating,
      'mode': mode,
      'color': color,
    };
  }
}

class StudentData {
  final String id, name;
  StudentData({required this.id, required this.name});
}

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  bool isSearchingCourses = true;
  String searchQuery = "";

  Map<String, bool> selectedCategories = {
    "Matric": false,
    "Intermediate": false,
    "O Level": false,
    "A Level": false,
    "Entrance Test": false,
  };

  Map<String, bool> selectedModes = {
    "Online": false,
    "Student Home": false,
    "Tutor Home": false,
  };

  final List<CourseData> _allCourses = [
    CourseData(id: "c1", tutorName: "Asim Ali Khan", subject: "Physics", grade: "Matric", price: "2000", rating: "4.2", mode: "Online", color: Colors.red.shade900),
    CourseData(id: "c2", tutorName: "Ali Imran", subject: "Physics", grade: "Intermediate", price: "2200", rating: "4.0", mode: "Tutor Home", color: Colors.brown),
    CourseData(id: "c3", tutorName: "Hiba Khan", subject: "Physics", grade: "O Level", price: "2500", rating: "4.3", mode: "Student Home", color: Colors.pink.shade900),
  ];

  final List<StudentData> _allStudents = [
    StudentData(id: "s1", name: "Asim Ali Khan"),
    StudentData(id: "s2", name: "Asim Furqan"), // Corrected spelling
    StudentData(id: "s3", name: "Asim Ayub"),   // Corrected spelling
  ];

  List<dynamic> get _filteredResults {
    if (isSearchingCourses) {
      return _allCourses.where((c) {
        bool matchesSearch = c.subject.toLowerCase().contains(searchQuery.toLowerCase()) ||
            c.tutorName.toLowerCase().contains(searchQuery.toLowerCase());
        bool noCategoryFilter = !selectedCategories.values.contains(true);
        bool matchesCategory = noCategoryFilter || selectedCategories[c.grade] == true;
        bool noModeFilter = !selectedModes.values.contains(true);
        bool matchesMode = noModeFilter || selectedModes[c.mode] == true;
        return matchesSearch && matchesCategory && matchesMode;
      }).toList();
    } else {
      return _allStudents.where((s) => s.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialCategories: selectedCategories,
        initialModes: selectedModes,
        onApply: (newCats, newModes) {
          setState(() {
            selectedCategories = newCats;
            selectedModes = newModes;
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredResults;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text("Search", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
                    ),
                    child: TextField(
                      onChanged: (val) => setState(() => searchQuery = val),
                      decoration: const InputDecoration(
                        hintText: "Search here...",
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(vertical: 15),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                GestureDetector(
                  onTap: _showFilterOptions,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Icon(Icons.tune, color: Colors.black, size: 24),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30)),
              child: Row(
                children: [
                  _buildTabButton("Courses", isSearchingCourses, () => setState(() => isSearchingCourses = true)),
                  _buildTabButton("Students", !isSearchingCourses, () => setState(() => isSearchingCourses = false)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black, fontSize: 14),
                    children: [
                      const TextSpan(text: "Result for "),
                      TextSpan(
                          text: "\"${searchQuery.isEmpty ? "All" : searchQuery}\"",
                          style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                Text("${results.length} FOUND", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final item = results[index];
                if (isSearchingCourses && item is CourseData) {
                  return _buildCourseItem(item);
                } else if (!isSearchingCourses && item is StudentData) {
                  return _buildStudentItem(item);
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
              color: isActive ? Colors.black : Colors.transparent, borderRadius: BorderRadius.circular(30)),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: isActive ? Colors.white : Colors.black, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildCourseItem(CourseData course) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CourseDetailScreen(
              course: course.toMap(),
              onAvailableTap: () {},
              // Fixed: onDelete expected a function that takes the course map
              onDelete: (courseMap) {},
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)],
        ),
        child: Row(
          children: [
            Container(width: 80, height: 80, decoration: BoxDecoration(color: course.color, borderRadius: BorderRadius.circular(15))),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(course.tutorName, style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                  Text(course.subject, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text("${course.price} PKR | ${course.grade}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 16),
                      Text(" ${course.rating}  |  ", style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(course.mode.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildStudentItem(StudentData student) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 5)],
      ),
      child: ListTile(
        onTap: () {
          final details = StudentDetails(
            id: student.id,
            name: student.name,
            profilePic: "assets/images/user.png",
            location: "Karachi, Pakistan",
            dob: "Not Available",
            gender: "Male",
            college: "KIET", // Corrected
            school: "Karachi Public School",
            phone: "+92 300 0000000",
            email: "${student.name.toLowerCase().replaceAll(' ', '')}@email.com",
          );
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => StudentProfileScreen(
                    student: details,
                    onDisconnect: (id) {},
                  )
              )
          );
        },
        leading: const CircleAvatar(backgroundColor: Colors.black, radius: 25, child: Icon(Icons.person, color: Colors.white)),
        title: Text(student.name, style: const TextStyle(fontWeight: FontWeight.bold)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
      ),
    );
  }
}

// --- FILTER BOTTOM SHEET ---
class FilterBottomSheet extends StatefulWidget {
  final Map<String, bool> initialCategories;
  final Map<String, bool> initialModes;
  final Function(Map<String, bool>, Map<String, bool>) onApply;

  const FilterBottomSheet({
    super.key,
    required this.initialCategories,
    required this.initialModes,
    required this.onApply,
  });

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  late Map<String, bool> categories;
  late Map<String, bool> teachingModes;

  @override
  void initState() {
    super.initState();
    categories = Map.from(widget.initialCategories);
    teachingModes = Map.from(widget.initialModes);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black,
                  radius: 20,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                const Text("Filter", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    setState(() {
                      categories.updateAll((k, v) => false);
                      teachingModes.updateAll((k, v) => false);
                    });
                  },
                  child: const Text("Clear", style: TextStyle(color: Colors.grey, fontSize: 16)),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Categories:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ...categories.keys.map((key) => _buildCustomCheckbox(key, categories[key]!, (val) {
                    setState(() => categories[key] = val!);
                  })),
                  const SizedBox(height: 30),
                  const Text("Teaching Mode:", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  ...teachingModes.keys.map((key) => _buildCustomCheckbox(key, teachingModes[key]!, (val) {
                    setState(() => teachingModes[key] = val!);
                  })),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(25),
              child: SizedBox(
                width: double.infinity,
                height: 65,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onApply(categories, teachingModes);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(35)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Spacer(flex: 2),
                      const Text("Apply", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                        child: const Icon(Icons.arrow_forward, color: Colors.black, size: 22),
                      )
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCustomCheckbox(String title, bool value, Function(bool?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => onChanged(!value),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: value ? Colors.black : const Color(0xFFE8F1FF),
                borderRadius: BorderRadius.circular(6),
                border: value ? null : Border.all(color: Colors.grey.shade300),
              ),
              child: value ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
            ),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}