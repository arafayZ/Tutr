import 'package:flutter/material.dart';

// --- 1. SHARED APP BAR ---
PreferredSizeWidget buildSharedAppBar(BuildContext context, String title) {
  return PreferredSize(
    preferredSize: const Size.fromHeight(80),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: const BoxDecoration(color: Colors.black, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_back, color: Colors.white, size: 20),
                ),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(width: 44),
            ],
          ),
        ),
      ),
    ),
  );
}

// --- 2. SHARED SEARCH BAR ---
Widget buildSharedSearchBar({
  required BuildContext context,
  required Function(String) onSearch,
  required List<String> activeCategories,
  required List<String> activeModes,
  required String activeBudget,
  required Function(List<String>, List<String>, String) onApplyFilters,
}) {
  return Padding(
    padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: TextField(
        onChanged: onSearch,
        decoration: InputDecoration(
          hintText: "Search tutors...",
          prefixIcon: const Icon(Icons.search, color: Colors.black54),
          suffixIcon: GestureDetector(
            onTap: () => _showFilterSheet(
              context,
              activeCategories,
              activeModes,
              activeBudget,
              onApplyFilters,
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.black),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 20),
        ),
      ),
    ),
  );
}

// --- 3. FILTER BOTTOM SHEET (SAFE & SCROLLABLE) ---
void _showFilterSheet(
    BuildContext context,
    List<String> initialCategories,
    List<String> initialModes,
    String initialBudget,
    Function(List<String>, List<String>, String) onApply,
    ) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFFF8F9FB),
    useSafeArea: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (context) {
      List<String> tempCategories = List.from(initialCategories);
      List<String> tempModes = List.from(initialModes);
      String tempBudget = initialBudget;

      return StatefulBuilder(builder: (context, setModalState) {
        void toggleCategory(String val) {
          setModalState(() {
            tempCategories.contains(val) ? tempCategories.remove(val) : tempCategories.add(val);
          });
        }

        void toggleMode(String val) {
          setModalState(() {
            tempModes.contains(val) ? tempModes.remove(val) : tempModes.add(val);
          });
        }

        return DraggableScrollableSheet(
          initialChildSize: 0.75,
          minChildSize: 0.5,
          maxChildSize: 0.95,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              padding: EdgeInsets.only(
                left: 25,
                right: 25,
                top: 15,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 25),

                  const Text("Categories:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 10),
                  ...["Matric", "Intermediate", "O Level", "A Level", "Entrance Test"]
                      .map((cat) => _buildFilterOption(cat, tempCategories.contains(cat), (v) => toggleCategory(cat))),

                  const SizedBox(height: 25),
                  const Text("Teaching Mode:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 10),
                  ...["Online", "Student's Home", "Tutor's Place"]
                      .map((mode) => _buildFilterOption(mode, tempModes.contains(mode), (v) => toggleMode(mode))),

                  const SizedBox(height: 25),
                  const Text("Budget:",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                  const SizedBox(height: 10),
                  ...["Under 1,000 PKR", "1,000 – 2,000 PKR", "2,000 – 3,000 PKR", "3,000 – 5,000 PKR", "Above 5,000 PKR"]
                      .map((budget) => _buildFilterOption(budget, tempBudget == budget, (v) {
                    setModalState(() => tempBudget = budget);
                  })),

                  const SizedBox(height: 30),

                  // --- SMALLER APPLY BUTTON ---
                  GestureDetector(
                    onTap: () {
                      onApply(tempCategories, tempModes, tempBudget);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20), // Reduced vertical padding
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(40)),
                      child: Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Text(
                                  "Apply",
                                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold) // Reduced font size
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(6), // Reduced icon container padding
                            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                            child: const Icon(Icons.arrow_forward, color: Colors.black, size: 18), // Reduced icon size
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      });
    },
  );
}

// --- HELPER OPTION ---
Widget _buildFilterOption(String title, bool isSelected, Function(bool?) onChanged) {
  return InkWell(
    onTap: () => onChanged(!isSelected),
    child: Row(
      children: [
        Checkbox(
          value: isSelected,
          onChanged: onChanged,
          activeColor: Colors.black,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        ),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500)),
      ],
    ),
  );
}

// --- 4. TUTOR LIST ---
Widget buildTutorList(List<Map<String, dynamic>> list, Function(int) onFavToggle) {
  return ListView.builder(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
    itemCount: list.length,
    itemBuilder: (context, i) {
      final t = list[i];
      return Container(
        margin: const EdgeInsets.only(bottom: 15),
        height: 110,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 8, offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 85,
              decoration: BoxDecoration(
                color: t['color'],
                borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(t['name'], style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 10)),
                        GestureDetector(
                          onTap: () => onFavToggle(i),
                          child: Icon(t['fav'] ? Icons.favorite : Icons.favorite_border, color: t['fav'] ? Colors.red : Colors.black54, size: 18),
                        ),
                      ],
                    ),
                    Text(t['subject'], maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text(t['price'], style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 14)),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 14),
                        Text(" ${t['rating']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
                        const Text("  |  ", style: TextStyle(color: Colors.grey)),
                        Text(t['location'], style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.grey)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// --- 5. EMPTY STATE ---
Widget buildEmptyState() {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(color: Colors.red.withValues(alpha: 0.1), shape: BoxShape.circle),
          child: const Icon(Icons.close_rounded, color: Colors.red, size: 60),
        ),
        const SizedBox(height: 16),
        const Text("Nothing to show", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54)),
        const SizedBox(height: 8),
        const Text("Try searching for something else", style: TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    ),
  );
}