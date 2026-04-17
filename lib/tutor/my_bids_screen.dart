import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../widgets/custom_bottom_nav.dart';
import '../widgets/custom_tab_header.dart';
import 'bid_details_screen.dart';
import 'add_course_screen.dart';
import '../services/connection_service.dart';
import '../config/api_config.dart';
import '../utils/status_bar_config.dart';

class MyBidsScreen extends StatefulWidget {
  const MyBidsScreen({super.key});

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState();
}

class _MyBidsScreenState extends State<MyBidsScreen> {
  String _selectedTab = "Requests";
  List<Map<String, dynamic>> _myBids = [];
  List<Map<String, dynamic>> _requests = [];
  List<Map<String, dynamic>> _filteredList = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    StatusBarConfig.setLightStatusBar();
    _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int tutorProfileId = prefs.getInt('profileId') ?? 0;

      await Future.wait([
        _loadMyBids(tutorProfileId),
        _loadRequests(tutorProfileId),
      ]);

      if (mounted) {
        _updateList();
        setState(() => _isLoading = false);
      }

    } catch (e) {
      print('Error loading data: $e');
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorDialog("Failed to load data: ${e.toString().replaceFirst('Exception: ', '')}");
      }
    }
  }

  Future<void> _loadMyBids(int tutorProfileId) async {
    try {
      List<Map<String, dynamic>> negotiations = await ConnectionService.getNegotiations(tutorProfileId);

      if (mounted) {
        setState(() {
          _myBids = negotiations.map((item) => {
            'id': item['connectionId'],
            'studentId': item['studentId'],
            'studentName': item['studentName'] ?? 'Unknown Student',
            'studentImage': item['studentImage'],
            'courseId': item['courseId'],
            'courseName': item['subject'] ?? 'Course',
            'originalPrice': _convertToInt(item['originalPrice']),
            'studentBidPrice': _convertToInt(item['studentCounterOffer']),
            'tutorCounterOffer': _convertToInt(item['tutorCounterOffer']),
            'agreedPrice': _convertToInt(item['agreedPrice']),
            'status': item['status'],
            'location': item['location'],
            'phoneNumber': item['phoneNumber'],
            'gender': item['gender'],
            'email': item['studentEmail'],
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading my bids: $e');
      if (mounted) {
        setState(() => _myBids = []);
      }
    }
  }

  Future<void> _loadRequests(int tutorProfileId) async {
    try {
      List<Map<String, dynamic>> pendingRequests = await ConnectionService.getPendingRequests(tutorProfileId);

      if (mounted) {
        setState(() {
          _requests = pendingRequests.map((item) => {
            'id': item['connectionId'],
            'studentId': item['studentId'],
            'studentName': item['studentName'] ?? 'Unknown Student',
            'studentImage': item['studentImage'],
            'courseId': item['courseId'],
            'courseName': item['subject'] ?? 'Course',
            'originalPrice': _convertToInt(item['originalPrice']),
            'studentBidPrice': _convertToInt(item['studentCounterOffer']),
            'tutorCounterOffer': _convertToInt(item['tutorCounterOffer']),
            'agreedPrice': _convertToInt(item['agreedPrice']),
            'status': item['status'],
            'location': item['location'],
            'phoneNumber': item['phoneNumber'],
            'gender': item['gender'],
            'email': item['studentEmail'],
          }).toList();
        });
      }
    } catch (e) {
      print('Error loading requests: $e');
      if (mounted) {
        setState(() => _requests = []);
      }
    }
  }

  int _convertToInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  void _updateList() {
    setState(() {
      _filteredList = _selectedTab == "My Bids"
          ? List.from(_myBids)
          : List.from(_requests);
    });
    _runFilter(_searchController.text);
  }

  void _runFilter(String enteredKeyword) {
    List<Map<String, dynamic>> source = _selectedTab == "My Bids" ? _myBids : _requests;

    List<Map<String, dynamic>> results = enteredKeyword.isEmpty
        ? List.from(source)
        : source.where((item) =>
    item['studentName'].toString().toLowerCase().contains(enteredKeyword.toLowerCase()) ||
        item['courseName'].toString().toLowerCase().contains(enteredKeyword.toLowerCase())
    ).toList();

    if (mounted) {
      setState(() {
        _filteredList = results;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Error", style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message),
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK", style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );
  }

  Future<void> _refreshData() async {
    await _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      extendBody: true,
      resizeToAvoidBottomInset: true,
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.only(top: 16, bottom: 8),
              child: const CustomTabHeader(
                title: Text("Bids", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
            ),
            _buildSearchField(),
            _buildToggleSwitch(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _filteredList.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                itemCount: _filteredList.length,
                padding: const EdgeInsets.only(bottom: 150, top: 10),
                itemBuilder: (context, index) => _BidListTile(
                  item: _filteredList[index],
                  isRequest: _selectedTab == "Requests",
                  onRefresh: _refreshData,
                ),
              ),
            ),
          ],
        ),
      ),
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
          hintText: "Search by student or course...",
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
              icon: const Icon(Icons.clear),
              onPressed: () {
                _searchController.clear();
                _runFilter("");
              }
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
          child: Text(
            label,
            style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    String message = _selectedTab == "My Bids"
        ? "No active bids found"
        : "No pending requests";
    String subMessage = _selectedTab == "My Bids"
        ? "When students negotiate, their bids will appear here"
        : "When students request your courses, they will appear here";

    return SingleChildScrollView(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _selectedTab == "My Bids" ? Icons.gavel : Icons.pending_actions,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              subMessage,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade400,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _BidListTile extends StatelessWidget {
  final Map<String, dynamic> item;
  final bool isRequest;
  final VoidCallback onRefresh;

  const _BidListTile({
    required this.item,
    required this.isRequest,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final String studentName = item['studentName']?.toString() ?? 'Unknown Student';
    final String courseName = item['courseName']?.toString() ?? 'Course';
    final String? studentImage = item['studentImage']?.toString();

    final int price = _getPriceValue();
    final String status = item['status']?.toString() ?? 'PENDING';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.grey.shade300,
            backgroundImage: studentImage != null && studentImage.isNotEmpty
                ? NetworkImage('${ApiConfig.baseUrl}$studentImage')
                : null,
            child: studentImage == null || studentImage.isEmpty
                ? const Icon(Icons.person, color: Colors.grey, size: 25)
                : null,
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  studentName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 2),
                Text(
                  courseName,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(status),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      "Rs $price",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BidDetailsScreen(
                    studentName: studentName,
                    isRequest: isRequest,
                    bidData: item,
                  ),
                ),
              );
              if (result == true) {
                onRefresh();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  int _getPriceValue() {
    if (isRequest) {
      var studentOffer = item['studentBidPrice'];
      var origPrice = item['originalPrice'];

      if (studentOffer != null && studentOffer > 0) {
        return studentOffer is double ? studentOffer.toInt() : (studentOffer as int);
      } else if (origPrice != null && origPrice > 0) {
        return origPrice is double ? origPrice.toInt() : (origPrice as int);
      }
    } else {
      var tutorOffer = item['tutorCounterOffer'];
      var studentOffer = item['studentBidPrice'];
      var origPrice = item['originalPrice'];

      if (tutorOffer != null && tutorOffer > 0) {
        return tutorOffer is double ? tutorOffer.toInt() : (tutorOffer as int);
      } else if (studentOffer != null && studentOffer > 0) {
        return studentOffer is double ? studentOffer.toInt() : (studentOffer as int);
      } else if (origPrice != null && origPrice > 0) {
        return origPrice is double ? origPrice.toInt() : (origPrice as int);
      }
    }
    return 0;
  }

  Color _getStatusColor(String status) {
    switch (status.toUpperCase()) {
      case 'PENDING':
        return Colors.orange;
      case 'NEGOTIATING':
        return Colors.blue;
      case 'CONFIRMED':
        return Colors.green;
      case 'REJECTED':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}