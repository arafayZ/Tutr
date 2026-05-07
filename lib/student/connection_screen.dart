import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'course_details_screen.dart';
import 'bid_details_screen.dart';
import 'chat_details_screen.dart';
import '../services/connection_service.dart';
import '../services/connection_refresh_service.dart';
import '../config/api_config.dart';

// --- COURSE COLORS (Same as other screens) ---
class CourseColors {
  static const List<Color> colors = [
    Color(0xFF1A1A2E),
    Color(0xFF16213E),
    Color(0xFF0F3460),
    Color(0xFF8B1E3F),
    Color(0xFF2C3E50),
    Color(0xFF1B4F72),
    Color(0xFF145A32),
    Color(0xFF7B2C3E),
    Color(0xFF4A235A),
    Color(0xFF1C2833),
    Color(0xFF6E2C00),
    Color(0xFF0B5345),
    Color(0xFF424949),
    Color(0xFF5D4037),
    Color(0xFF283747),
    Color(0xFF7E5109),
    Color(0xFF4A4A4A),
    Color(0xFF3E2723),
    Color(0xFF1A237E),
  ];

  static Color getCourseColor(int courseId) {
    return colors[courseId % colors.length];
  }
}

// Category Badge Colors Helper
Map<String, Color> getCategoryBadgeColors(String category) {
  switch (category.toUpperCase()) {
    case 'MATRIC':
      return {'bg': Colors.orange.shade100, 'text': Colors.orange.shade800};
    case 'INTERMEDIATE':
      return {'bg': Colors.teal.shade100, 'text': Colors.teal.shade800};
    case 'O_LEVEL':
      return {'bg': Colors.blue.shade100, 'text': Colors.blue.shade800};
    case 'A_LEVEL':
      return {'bg': Colors.green.shade100, 'text': Colors.green.shade800};
    case 'ENTRY_TEST':
      return {'bg': Colors.purple.shade100, 'text': Colors.purple.shade800};
    default:
      return {'bg': Colors.grey.shade100, 'text': Colors.grey.shade800};
  }
}

// Teaching Mode Icon Helper
IconData getTeachingModeIcon(String mode) {
  switch (mode.toLowerCase()) {
    case 'online':
      return Icons.wifi;
    case 'student_home':
    case "student's home":
      return Icons.home;
    case 'tutor_home':
    case "tutor's home":
      return Icons.location_city;
    default:
      return Icons.school;
  }
}

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen> with WidgetsBindingObserver {
  bool isConnectedTab = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";
  int _studentId = 0;
  bool _isLoading = true;
  bool _isRefreshing = false;

  List<Map<String, dynamic>> connectedTutors = [];
  List<Map<String, dynamic>> myBids = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadStudentId();

    // Listen for refresh events from BidDetailsScreen
    ConnectionRefreshService().onRefreshConnections.listen((_) {
      if (mounted) {
        _refreshData();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      _refreshData();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh when screen becomes visible (returns from other screens)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_isLoading && !_isRefreshing && mounted && _studentId != 0) {
        _refreshData();
      }
    });
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _studentId = prefs.getInt('profileId') ?? 0;
      });
    }
    await _loadData();
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      await Future.wait([
        _loadConnectedTutors(),
        _loadMyBids(),
      ]);
    } catch (e) {
      print('Error loading data: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isRefreshing = false;
        });
      }
    }
  }

  Future<void> _refreshData() async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    await _loadData();
  }

  Future<void> _loadConnectedTutors() async {
    try {
      final response = await ConnectionService.getStudentConfirmedConnections(_studentId);

      final List<Map<String, dynamic>> transformed = response.map((conn) {
        double originalPriceValue = conn['originalPrice']?.toDouble() ?? 0.0;
        double agreedPriceValue = conn['agreedPrice']?.toDouble() ?? 0.0;
        double ratingValue = conn['averageRating']?.toDouble() ?? 0.0;

        String teachingModeText = 'Online';
        String teachingMode = conn['teachingMode']?.toString() ?? '';
        if (teachingMode == 'ONLINE') {
          teachingModeText = 'Online';
        } else if (teachingMode == 'STUDENT_HOME') {
          teachingModeText = "Student's Home";
        } else if (teachingMode == 'TUTOR_HOME') {
          teachingModeText = "Tutor's Home";
        }

        String categoryRaw = conn['category']?.toString() ?? 'General';
        String categoryDisplay = _getCategoryDisplayName(categoryRaw);

        return {
          'id': conn['courseId'] ?? 0,
          'connectionId': conn['connectionId'] ?? 0,
          'name': conn['tutorName'] ?? 'Unknown Tutor',
          'subject': conn['subject'] ?? 'General',
          'originalPrice': originalPriceValue,
          'agreedPrice': agreedPriceValue,
          'priceValue': originalPriceValue,
          'categoryDisplay': categoryDisplay,
          'categoryRaw': categoryRaw,
          'rating': ratingValue.toStringAsFixed(1),
          'teachingMode': teachingModeText,
          'location': conn['location'] ?? 'Online',
          'color': CourseColors.getCourseColor(conn['courseId'] ?? 0),
          'tutorId': conn['tutorId'] ?? 0,
          'studentId': conn['studentId'] ?? _studentId,
          'tutorHeadline': conn['tutorHeadline'] ?? 'Tutor',
          'status': conn['status'] ?? 'CONFIRMED',
          'averageRating': ratingValue,
          'totalRatings': conn['totalRatings'] ?? 0,
        };
      }).toList();

      setState(() {
        connectedTutors = transformed;
      });
    } catch (e) {
      print('Error loading connected tutors: $e');
    }
  }

  Future<void> _loadMyBids() async {
    try {
      final response = await ConnectionService.getStudentConnectionsRaw(_studentId);

      final filtered = response.where((conn) {
        String status = conn['status']?.toString() ?? '';
        return status == 'PENDING' || status == 'NEGOTIATING';
      }).toList();

      final List<Map<String, dynamic>> transformed = filtered.map((conn) {
        double originalPrice = conn['originalPrice']?.toDouble() ?? 0.0;
        double studentBidPrice = conn['studentCounterOffer']?.toDouble() ?? 0.0;
        double tutorCounterOffer = conn['tutorCounterOffer']?.toDouble() ?? 0.0;
        double ratingValue = conn['averageRating']?.toDouble() ?? 0.0;

        String status = conn['status']?.toString() ?? 'PENDING';

        String? tutorImage = conn['tutorImage']?.toString();
        if (tutorImage != null && tutorImage.isNotEmpty) {
          tutorImage = '${ApiConfig.baseUrl}$tutorImage';
        }

        return {
          'id': conn['connectionId'] ?? 0,
          'name': conn['tutorName'] ?? 'Unknown Tutor',
          'tutorName': conn['tutorName'] ?? 'Unknown Tutor',
          'subject': conn['subject'] ?? 'General',
          'courseName': conn['subject'] ?? 'Course',
          'originalPrice': originalPrice,
          'studentBidPrice': studentBidPrice,
          'tutorCounterOffer': tutorCounterOffer,
          'status': status,
          'courseId': conn['courseId'] ?? 0,
          'studentId': conn['studentId'] ?? _studentId,
          'tutorId': conn['tutorId'] ?? 0,
          'tutorImage': tutorImage,
          'averageRating': ratingValue,
          'location': conn['location'],
          'teachingMode': conn['teachingMode'],
          'tutorHeadline': conn['tutorHeadline'],
        };
      }).toList();

      setState(() {
        myBids = transformed;
      });
    } catch (e) {
      print('Error loading my bids: $e');
    }
  }

  String _getCategoryDisplayName(String category) {
    switch (category.toUpperCase()) {
      case 'MATRIC':
        return 'Matric';
      case 'INTERMEDIATE':
        return 'Intermediate';
      case 'O_LEVEL':
        return 'O Level';
      case 'A_LEVEL':
        return 'A Level';
      case 'ENTRY_TEST':
        return 'Entrance Test';
      default:
        return category;
    }
  }

  Future<void> _disconnectTutor(int connectionId, String tutorName, int index) async {
    try {
      await ConnectionService.studentDisconnect(connectionId, disconnectedBy: "STUDENT");
      setState(() {
        connectedTutors.removeAt(index);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Disconnected from $tutorName'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to disconnect'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  void _showDisconnectDialog(int connectionId, String tutorName, int index) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "Disconnect Tutor?",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Colors.black),
          ),
          content: Text(
            "You will no longer be connected with $tutorName",
            style: const TextStyle(fontSize: 14, color: Colors.black87),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _disconnectTutor(connectionId, tutorName, index);
              },
              child: const Text(
                "Disconnect",
                style: TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToCourseDetail(Map<String, dynamic> course) {
    final courseData = {
      'id': course['id'],
      'courseId': course['id'],
      'tutorName': course['name'],
      'name': course['name'],
      'sub': course['subject'],
      'title': course['subject'],
      'category': course['categoryRaw'],
      'price': course['price'],
      'priceValue': course['priceValue'],
      'rating': course['rating'],
      'totalRatings': course['totalRatings'],
      'location': course['location'],
      'teachingMode': course['teachingMode'],
      'tutorImage': course['tutorImage'] ?? '',
      'tutorHeadline': course['tutorHeadline'],
    };
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseDetailsScreen(courseData: courseData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentList = isConnectedTab ? connectedTutors : myBids;
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    final filteredList = currentList.where((item) {
      final name = item['name']?.toString().toLowerCase() ?? '';
      final subject = item['subject']?.toString().toLowerCase() ?? '';
      return name.contains(_searchQuery.toLowerCase()) ||
          subject.contains(_searchQuery.toLowerCase());
    }).toList();

    // Determine if we should show empty state or list
    final bool isEmpty = filteredList.isEmpty && !_isLoading;
    final bool showEmptyState = isEmpty && !_isRefreshing;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.black,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Header (non-scrolling)
            SliverToBoxAdapter(
              child: Column(
                children: [
                  _buildHeader(),
                  _buildSearchBar(),
                  const SizedBox(height: 10),
                  _buildToggleButtons(),
                  const SizedBox(height: 15),
                  if (_searchQuery.isNotEmpty) _buildResultBar(filteredList.length),
                ],
              ),
            ),

            // Scrollable content
            if (_isLoading)
              const SliverFillRemaining(
                child: Center(child: CircularProgressIndicator(color: Colors.black)),
              )
            else if (showEmptyState)
              SliverFillRemaining(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(isConnectedTab ? Icons.people_outline : Icons.gavel_outlined, size: 64, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text(
                        isConnectedTab ? "No Connected Tutors" : "No Active Bids",
                        style: TextStyle(fontSize: 18, color: Colors.grey[600], fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        isConnectedTab
                            ? "Connect with tutors to see them here"
                            : "Send offers to tutors to see bids here",
                        style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                      ),
                    ],
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 10, 20, bottomPadding + 20),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) {
                      if (isConnectedTab) {
                        return _buildTutorCard(filteredList[index], index);
                      } else {
                        return _buildBidCard(filteredList[index]);
                      }
                    },
                    childCount: filteredList.length,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 15, offset: const Offset(0, 4)),
        ],
      ),
      child: const Center(
        child: Text(
          "Connections",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: const InputDecoration(
            hintText: "Search by name or subject...",
            prefixIcon: Icon(Icons.search, color: Colors.black54, size: 22),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildResultBar(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Color(0xFF1A1C43), fontSize: 14, fontWeight: FontWeight.bold),
              children: [
                const TextSpan(text: "Result for "),
                TextSpan(text: '"$_searchQuery"', style: const TextStyle(color: Colors.blue)),
              ],
            ),
          ),
          Text("$count FOUND", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildToggleButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 50,
        decoration: BoxDecoration(color: const Color(0xFFE5E7EB), borderRadius: BorderRadius.circular(30)),
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isConnectedTab = true),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: isConnectedTab ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: Text("Connected", style: TextStyle(color: isConnectedTab ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => isConnectedTab = false),
                child: Container(
                  margin: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: !isConnectedTab ? Colors.black : Colors.transparent,
                    borderRadius: BorderRadius.circular(26),
                  ),
                  child: Center(
                    child: Text("My Bids", style: TextStyle(color: !isConnectedTab ? Colors.white : Colors.black, fontWeight: FontWeight.bold)),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTutorCard(Map<String, dynamic> tutor, int index) {
    final badgeColors = getCategoryBadgeColors(tutor['categoryRaw']);
    final teachingIcon = getTeachingModeIcon(tutor['teachingMode']);
    final connectionId = tutor['connectionId'];

    final double originalPrice = tutor['originalPrice'] ?? 0;
    final double agreedPrice = tutor['agreedPrice'] ?? 0;

    final bool showAgreedPrice = agreedPrice > 0 && agreedPrice != originalPrice;
    final String displayPrice = showAgreedPrice
        ? '${agreedPrice.toStringAsFixed(0)} PKR'
        : '${originalPrice.toStringAsFixed(0)} PKR';

    return GestureDetector(
      onTap: () => _navigateToCourseDetail(tutor),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 70,
              height: 180,
              decoration: BoxDecoration(
                color: tutor['color'],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
              child: Center(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  height: 35,
                  width: 35,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) {
                    return Text(
                      tutor['name'][0].toUpperCase(),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(tutor['name'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: badgeColors['bg'], borderRadius: BorderRadius.circular(10)),
                      child: Text(tutor['categoryDisplay'], style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: badgeColors['text'])),
                    ),
                    const SizedBox(height: 4),
                    Text(tutor['subject'], style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.black87), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (showAgreedPrice) ...[
                          Text(displayPrice,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                          const SizedBox(width: 6),
                          Text('${originalPrice.toStringAsFixed(0)} PKR',
                              style: const TextStyle(color: Colors.grey, fontSize: 11, decoration: TextDecoration.lineThrough)),
                        ] else ...[
                          Text(displayPrice,
                              style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.star, color: Colors.orange, size: 12), const SizedBox(width: 2), Text(tutor['rating'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11))]),
                        Row(mainAxisSize: MainAxisSize.min, children: [Icon(teachingIcon, size: 11, color: Colors.grey), const SizedBox(width: 2), Text(tutor['teachingMode'], style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis)]),
                        Row(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.location_on, size: 10, color: Colors.grey), const SizedBox(width: 2), SizedBox(width: 80, child: Text(tutor['location'], style: const TextStyle(fontSize: 10, color: Colors.grey), maxLines: 1, overflow: TextOverflow.ellipsis))]),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => _showDisconnectDialog(connectionId, tutor['name'], index),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Disconnect", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ChatDetailsScreen(
                                    userName: tutor['name'],
                                    tutorId: tutor['tutorId'],
                                    studentId: tutor['studentId'],
                                  ),
                                ),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black,
                              foregroundColor: Colors.white,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              minimumSize: const Size(0, 32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Message", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
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
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final status = bid['status'] ?? 'PENDING';
    final statusColor = _getStatusColor(status);
    final bool showOffer = status != 'PENDING';

    final tutorOffer = bid['tutorCounterOffer'] ?? bid['studentBidPrice'] ?? 0;

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => BidDetailsScreen(
              courseId: bid['courseId'] ?? 0,
              studentId: _studentId,
              onRefresh: _refreshData,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 70,
              height: 90,
              child: Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.black,
                  backgroundImage: (bid['tutorImage'] != null && bid['tutorImage'].toString().isNotEmpty)
                      ? NetworkImage(bid['tutorImage'])
                      : null,
                  child: (bid['tutorImage'] == null || bid['tutorImage'].toString().isEmpty)
                      ? const Icon(Icons.person, color: Colors.white, size: 30)
                      : null,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(bid['name'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF1A1C43))),
                    const SizedBox(height: 4),
                    Text(bid['courseName'], style: const TextStyle(color: Colors.grey, fontSize: 12), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        if (showOffer)
                          Text("Offer: ${tutorOffer.toStringAsFixed(0)} PKR",
                              style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 12)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: statusColor.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                          child: Text(status,
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Icon(Icons.chevron_right, color: Colors.grey[400], size: 24),
            ),
          ],
        ),
      ),
    );
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