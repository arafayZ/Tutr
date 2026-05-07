import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/report_block_service.dart';
import '../config/api_config.dart';
import 'tutor_profile_screen.dart';

class BlockTutorScreen extends StatefulWidget {
  const BlockTutorScreen({super.key});

  @override
  State<BlockTutorScreen> createState() => _BlockTutorScreenState();
}

class _BlockTutorScreenState extends State<BlockTutorScreen> {
  List<Map<String, dynamic>> _blockedTutors = [];
  bool _isLoading = true;
  int _studentId = 0;

  @override
  void initState() {
    super.initState();
    _loadStudentId();
  }

  Future<void> _loadStudentId() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    final studentId = prefs.getInt('profileId');

    setState(() {
      _studentId = studentId ?? 0;
    });

    await _loadBlockedTutors();
  }

  Future<void> _loadBlockedTutors() async {
    if (_studentId == 0) {
      setState(() => _isLoading = false);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final tutors = await ReportBlockService.getBlockedTutors(_studentId);
      setState(() {
        _blockedTutors = tutors;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _unblockTutor(int index, int tutorId, String tutorName) async {
    try {
      await ReportBlockService.unblockTutor(_studentId, tutorId);

      setState(() {
        _blockedTutors.removeAt(index);
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$tutorName unblocked successfully'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  void _showUnblockDialog(BuildContext context, int index, String tutorName, int tutorId) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 10),
              const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
              const SizedBox(height: 15),
              const Text(
                "Unblock Tutor",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                "Are you sure you want to unblock $tutorName?",
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black87),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Cancel", style: TextStyle(color: Colors.grey)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _unblockTutor(index, tutorId, tutorName);
                    },
                    child: const Text(
                      "Yes",
                      style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Text(message, textAlign: TextAlign.center),
        actions: [
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("OK", style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToTutorProfile(Map<String, dynamic> tutor) {
    final Map<String, dynamic> tutorData = {
      'name': tutor['tutorName'] ?? 'Unknown',
      'expertise': tutor['tutorHeadline'] ?? 'Tutor',
      'profileImage': tutor['tutorImage'],
      'tutorId': tutor['tutorId'],
      'location': tutor['location'] ?? 'Not specified',
      'rating': tutor['rating'] ?? '4.0',
      'totalStudents': tutor['totalStudents'] ?? 0,
      'totalCourses': tutor['totalCourses'] ?? 0,
      'about': tutor['about'] ?? 'No description available.',
    };

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TutorProfileScreen(tutorData: tutorData),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double bottomPadding = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: Column(
        children: [
          _buildHeader(context),
          const SizedBox(height: 25),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(25),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(25),
                child: _buildBody(),
              ),
            ),
          ),
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 30),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.black),
      );
    }

    if (_blockedTutors.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_outlined,
                size: 50,
                color: Colors.grey[400],
              ),
            ),
            const SizedBox(height: 20),
            Text(
              "No Blocked Tutors",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Tutors you block will appear here",
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(vertical: 10),
      physics: const BouncingScrollPhysics(),
      itemCount: _blockedTutors.length,
      separatorBuilder: (context, index) => const Divider(
        height: 1,
        indent: 20,
        endIndent: 20,
        color: Color(0xFFF0F0F0),
      ),
      itemBuilder: (context, index) {
        final tutor = _blockedTutors[index];
        return _buildTutorItem(tutor, index);
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 60, 20, 25), // Increased top padding from 50 to 60 to lower content
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 45,
                height: 45,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          const Text(
            "Block Tutor",
            style: TextStyle(
              color: Colors.black,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTutorItem(Map<String, dynamic> tutor, int index) {
    final String name = tutor['tutorName'] ?? 'Unknown';
    final String role = tutor['tutorHeadline'] ?? 'Tutor';
    final String? imageUrl = tutor['tutorImage'];
    final int tutorId = tutor['tutorId'] ?? 0;

    return InkWell(
      onTap: () => _navigateToTutorProfile(tutor),
      borderRadius: BorderRadius.circular(15),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              backgroundImage: imageUrl != null && imageUrl.isNotEmpty
                  ? NetworkImage('${ApiConfig.baseUrl}$imageUrl')
                  : null,
              child: imageUrl == null || imageUrl.isEmpty
                  ? const Icon(Icons.person, color: Colors.grey, size: 28)
                  : null,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    role,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showUnblockDialog(context, index, name, tutorId),
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                    child: Text(
                      "Unblock",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}