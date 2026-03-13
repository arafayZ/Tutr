import 'package:flutter/material.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'bid_details_screen.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  String _selectedTab = "My Bids";

  final List<String> _allBids = [
    "Bilal Raza", "Sara Ali", "Zayan Khan", "Ayesha Malik",
    "Hamza Sheikh", "Dua Fatima", "Mustafa Ali", "Zainab Junaid"
  ];

  final List<String> _allRequests = [
    "Atif Ali Khan", "Omer Farooq", "Hania Amir"
  ];

  List<String> _filteredStudents = [];
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _updateList();
  }

  void _updateList() {
    setState(() {
      _filteredStudents = _selectedTab == "My Bids" ? _allBids : _allRequests;
    });
  }

  void _runFilter(String enteredKeyword) {
    List<String> source = _selectedTab == "My Bids" ? _allBids : _allRequests;
    List<String> results = enteredKeyword.isEmpty
        ? source
        : source.where((user) => user.toLowerCase().contains(enteredKeyword.toLowerCase())).toList();

    setState(() {
      _filteredStudents = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      resizeToAvoidBottomInset: false,
      body: Column(
        children: [
          const CustomTabHeader(
            title: Text("My Bids", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
          _buildSearchField(),
          _buildToggleSwitch(),
          Expanded(
            child: _filteredStudents.isNotEmpty
                ? ListView.builder(
              itemCount: _filteredStudents.length,
              padding: const EdgeInsets.only(bottom: 150, top: 10),
              itemBuilder: (context, index) => _BidListTile(
                name: _filteredStudents[index],
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BidDetailsScreen(
                      studentName: _filteredStudents[index],
                      isRequest: _selectedTab == "Requests",
                    ),
                  ),
                ),
              ),
            )
                : const Center(child: Text("No data found", style: TextStyle(color: Colors.grey))),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const CustomBottomNav(currentIndex: -1),
    );
  }

  Widget _buildSearchField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: _runFilter,
        decoration: InputDecoration(
          hintText: "Search Here...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(icon: const Icon(Icons.clear), onPressed: () { _searchController.clear(); _runFilter(""); })
              : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
        ),
      ),
    );
  }

  Widget _buildToggleSwitch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: const Color(0xFFE0E0E0).withOpacity(0.5),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            _buildTabButton("Requests"),
            _buildTabButton("My Bids"),
          ],
        ),
      ),
    );
  }

  Widget _buildTabButton(String label) {
    bool isSelected = _selectedTab == label;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTab = label;
            _searchController.clear();
            _updateList();
          });
        },
        child: Container(
          margin: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: isSelected ? Colors.black : Colors.transparent,
            borderRadius: BorderRadius.circular(25),
          ),
          alignment: Alignment.center,
          child: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
        ),
      ),
    );
  }
}

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
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
          const Spacer(),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 12)),
          )
        ],
      ),
    );
  }
}