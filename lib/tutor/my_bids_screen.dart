// Import Flutter material package for widgets
import 'package:flutter/material.dart';

// Import custom widgets for bottom navigation and tab header
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';

// ===================
// 1. MAIN BIDS SCREEN
// ===================
class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  // List of all students (dummy data)
  final List<String> _allStudents = [
    "Bilal Raza", "Sara Ali", "Zayan Khan", "Ayesha Malik",
    "Hamza Sheikh", "Dua Fatima", "Mustafa Ali", "Zainab Junaid",
    "Omer Farooq", "Hania Amir"
  ];

  // Filtered list to show search results
  List<String> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  // Initialize filtered list with all students
  @override
  void initState() {
    super.initState();
    _filteredStudents = _allStudents;
  }

  // Filter students based on search input
  void _runFilter(String enteredKeyword) {
    List<String> results = [];
    if (enteredKeyword.isEmpty) {
      results = _allStudents; // No keyword -> show all
    } else {
      results = _allStudents
          .where((user) => user.toLowerCase().contains(enteredKeyword.toLowerCase()))
          .toList(); // Filter list
    }
    setState(() {
      _filteredStudents = results;
    });
  }

  // ----------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB), // Background color
      extendBody: true, // For floating button overlap
      resizeToAvoidBottomInset: false, // Avoid resize on keyboard
      body: Column(
        children: [

          // --- CUSTOM HEADER ---
          const CustomTabHeader(
            title: Text(
              "My Bids",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),

          // --- SEARCH FIELD ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _runFilter(value), // Run filter on typing
              decoration: InputDecoration(
                hintText: "Search Here...",
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _runFilter(""); // Clear search
                  },
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- STUDENTS LIST ---
          Expanded(
            child: _filteredStudents.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredStudents.length,
              padding: const EdgeInsets.only(bottom: 150, top: 10),
              itemBuilder: (context, index) => _BidListTile(
                name: _filteredStudents[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const BidDetailsScreen()),
                ),
              ),
            )
                : const Center(
              child: Text("No students found", style: TextStyle(color: Colors.grey)),
            ),
          ),
        ],
      ),

      // --- FLOATING ACTION BUTTON ---
      floatingActionButton: FloatingActionButton(
        onPressed: () {}, // Add new bid (currently empty)
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // --- CUSTOM BOTTOM NAVIGATION ---
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }
}

// =====================
// 2. BID DETAILS SCREEN
// =====================
class BidDetailsScreen extends StatefulWidget {
  const BidDetailsScreen({super.key});

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState();
}

class _BidDetailsScreenState extends State<BidDetailsScreen> {
  String _selectedButtonLabel = ""; // Track which button was clicked

  // Show a generic popup
  void _showPopup(BuildContext context, Widget content) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Padding(padding: const EdgeInsets.all(24), child: content),
      ),
    );
  }

  // Handle Accept / Counter / Reject button logic
  void _onButtonPressed(String label, Widget popup) async {
    if (label == "Reject Offer") {
      // Show confirmation dialog for reject
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          child: const Padding(padding: EdgeInsets.all(24), child: _RejectPopup()),
        ),
      );
      if (confirmed == true) {
        setState(() => _selectedButtonLabel = "Rejected");
      }
    } else {
      setState(() => _selectedButtonLabel = label);
      _showPopup(context, popup); // Show corresponding popup
    }
  }

  // ----------------- BUILD -----------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text(
              "Bid Details",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  // --- BID INFO CARD ---
                  const _BidInfoCard(),
                  const SizedBox(height: 40),

                  // --- STATUS BUTTONS ---
                  if (_selectedButtonLabel != "Rejected") ...[
                    _StatusButton(
                      label: "Accept Offer",
                      color: _selectedButtonLabel == "Accept Offer" ? Colors.black : const Color(0xFFE0E0E0),
                      textColor: _selectedButtonLabel == "Accept Offer" ? Colors.white : Colors.black,
                      onTap: () => _onButtonPressed("Accept Offer", const _SuccessPopup()),
                    ),
                    _StatusButton(
                      label: "Counter Offer",
                      color: _selectedButtonLabel == "Counter Offer" ? Colors.black : const Color(0xFFE0E0E0),
                      textColor: _selectedButtonLabel == "Counter Offer" ? Colors.white : Colors.black,
                      onTap: () => _onButtonPressed("Counter Offer", const _CounterPopup()),
                    ),
                    _StatusButton(
                      label: "Reject Offer",
                      color: _selectedButtonLabel == "Reject Offer" ? Colors.black : const Color(0xFFE0E0E0),
                      textColor: _selectedButtonLabel == "Reject Offer" ? Colors.white : Colors.black,
                      onTap: () => _onButtonPressed("Reject Offer", const _RejectPopup()),
                    ),
                  ] else ...[
                    // Show rejected status if rejected
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.red, size: 26),
                          SizedBox(width: 10),
                          Text("Offer Rejected", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),

      // Floating action button
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNav(),
    );
  }
}

// ===================
// 3. POPUPS & COMPONENTS
// ===================

// Success popup after accepting offer
class _SuccessPopup extends StatelessWidget {
  const _SuccessPopup();
  @override
  Widget build(BuildContext context) {
    return const Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text("🎉", style: TextStyle(fontSize: 50)),
        SizedBox(height: 15),
        Text("Congratulations", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))),
        SizedBox(height: 10),
        Text("You're now connected with your student.", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)),
        SizedBox(height: 20),
        CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
      ],
    );
  }
}

// Counter Offer popup
class _CounterPopup extends StatelessWidget {
  const _CounterPopup();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const Text("1500 PKR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)),
        const SizedBox(height: 20),
        TextField(
          textAlign: TextAlign.center,
          decoration: InputDecoration(
            hintText: "Enter Counter Offer",
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()),
                child: const Text("Send", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        )
      ],
    );
  }
}

// Reject popup confirmation
class _RejectPopup extends StatelessWidget {
  const _RejectPopup();
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        const SizedBox(height: 25),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("CANCEL", style: TextStyle(color: Colors.black))),
            TextButton(onPressed: () => Navigator.pop(context, true), child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))),
          ],
        )
      ],
    );
  }
}

// Single bid tile in the list
class _BidListTile extends StatelessWidget {
  final String name;
  final VoidCallback onTap;
  const _BidListTile({required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)),
      child: Row(
        children: [
          const CircleAvatar(backgroundColor: Colors.black, radius: 25),
          const SizedBox(width: 15),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
            child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 11)),
          )
        ],
      ),
    );
  }
}

// Bid info card in details screen
class _BidInfoCard extends StatelessWidget {
  const _BidInfoCard();
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10
            )
          ]
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(width: 80, height: 80, decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10))),
              const SizedBox(width: 15),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text("2000 PKR | Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),
          const Divider(height: 40),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Student Offer:", style: TextStyle(fontWeight: FontWeight.bold)),
              Text("1500 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)),
            ],
          ),
        ],
      ),
    );
  }
}

// Status buttons for Accept / Counter / Reject
class _StatusButton extends StatelessWidget {
  final String label;
  final Color color;
  final Color textColor;
  final VoidCallback onTap;

  const _StatusButton({required this.label, required this.color, this.textColor = Colors.white, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        height: 55,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: color,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))
          ),
          onPressed: onTap,
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }
}