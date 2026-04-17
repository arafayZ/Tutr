import 'package:flutter/material.dart';

class BlockTutorScreen extends StatefulWidget {
  const BlockTutorScreen({super.key});

  @override
  State<BlockTutorScreen> createState() => _BlockTutorScreenState();
}

class _BlockTutorScreenState extends State<BlockTutorScreen> {
  // Mutable list of blocked tutors
  final List<Map<String, String>> _blockedTutors = [
    {"name": "Ahmed Khan", "role": "Physics Expert"},
    {"name": "Sara Malik", "role": "Math Instructor"},
    {"name": "Ali Raza", "role": "Chemistry Specialist"},
    {"name": "Fatima Noor", "role": "Biology Tutor"},
    {"name": "Hassan Javed", "role": "English Coach"},
    {"name": "Zainab Abbas", "role": "Computer Science Head"},
    {"name": "Bilal Sheikh", "role": "Statistics Professor"},
  ];

  void _showUnblockDialog(BuildContext context, int index) {
    bool isSuccess = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  if (!isSuccess) ...[
                    const Icon(Icons.warning_amber_rounded, size: 50, color: Colors.orange),
                    const SizedBox(height: 15),
                    const Text(
                      "Unblock Tutor",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Are you sure you want to unblock ${_blockedTutors[index]['name']}?",
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
                        // Black color text for "Yes" with no background
                        TextButton(
                          onPressed: () {
                            // Update main screen list
                            setState(() {
                              _blockedTutors.removeAt(index);
                            });

                            // Update dialog state to show success
                            setDialogState(() {
                              isSuccess = true;
                            });

                            // Auto-close after 2 seconds
                            Future.delayed(const Duration(seconds: 2), () {
                              if (context.mounted) Navigator.pop(context);
                            });
                          },
                          child: const Text(
                              "Yes",
                              style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)
                          ),
                        ),
                      ],
                    ),
                  ] else ...[
                    const SizedBox(height: 10),
                    const CircularProgressIndicator(color: Colors.black, strokeWidth: 3),
                    const SizedBox(height: 25),
                    const Text(
                      "Success!",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      "Tutor unblocked successfully.",
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              ),
            );
          },
        );
      },
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
                child: _blockedTutors.isEmpty
                    ? const Center(
                  child: Text(
                      "No blocked tutors",
                      style: TextStyle(color: Colors.grey, fontSize: 16)
                  ),
                )
                    : ListView.separated(
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
                    return _buildTutorItem(
                      _blockedTutors[index]['name']!,
                      _blockedTutors[index]['role']!,
                      index,
                    );
                  },
                ),
              ),
            ),
          ),

          // Bottom safe space
          SizedBox(height: bottomPadding > 0 ? bottomPadding : 30),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 50, 20, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
            ),
          ),
          const Expanded(
            child: Center(
              child: Text(
                "Block Tutor",
                style: TextStyle(
                    color: Colors.black,
                    fontSize: 20,
                    fontWeight: FontWeight.bold
                ),
              ),
            ),
          ),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildTutorItem(String name, String role, int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      child: Row(
        children: [
          const CircleAvatar(
              radius: 28,
              backgroundColor: Colors.black
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
                        color: Colors.black
                    )
                ),
                const SizedBox(height: 2),
                Text(
                    role,
                    style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 13
                    )
                ),
              ],
            ),
          ),
          // Unblock Button (Black BG)
          Container(
            decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(20)
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () => _showUnblockDialog(context, index),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Text(
                    "Unblock",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}