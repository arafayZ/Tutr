import 'package:flutter/material.dart'; // Import Flutter material design package for UI components
import '../widgets/custom_bottom_nav.dart'; // Import custom bottom navigation bar widget

// --- 1. REUSABLE HEADER ---
class CustomTabHeader extends StatelessWidget { // Stateless widget since header has no changing state
  final String title; // Variable to hold the header title text
  final VoidCallback? onBackTap; // Optional custom function to override default back button behavior

  const CustomTabHeader({super.key, required this.title, this.onBackTap}); // Constructor requiring title, optional back tap

  @override
  Widget build(BuildContext context) { // Build method returns the visual widget tree
    return Container( // Outer container for the entire header
      width: double.infinity, // Stretch header to full screen width
      height: 120, // Fixed height for the header area
      decoration: const BoxDecoration( // Visual styling for the container
        color: Colors.white, // White background color for the header
        borderRadius: BorderRadius.only( // Apply rounded corners only at the bottom
          bottomLeft: Radius.circular(30), // Round bottom left corner with radius 30
          bottomRight: Radius.circular(30), // Round bottom right corner with radius 30
        ),
        boxShadow: [ // Add shadow to give header a lifted appearance
          BoxShadow(color: Colors.black12, blurRadius: 10, offset: Offset(0, 5)), // Subtle downward shadow
        ],
      ),
      child: SafeArea( // SafeArea prevents content from overlapping system UI like status bar
        bottom: false, // Only apply safe area padding to the top, not bottom
        child: Stack( // Stack allows widgets to overlap each other
          children: [
            Center( // Center widget positions the title in the middle of the header
              child: Text(
                title, // Display the title string passed into this widget
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold), // Bold and large title style
              ),
            ),
            Align( // Align widget positions the back button to a specific side
              alignment: Alignment.centerLeft, // Place the back button on the left center
              child: Padding(
                padding: const EdgeInsets.only(left: 20), // Add left padding so button doesn't touch the edge
                child: GestureDetector( // GestureDetector listens for tap gestures
                  onTap: onBackTap ?? () => Navigator.pop(context), // Use custom back action or default pop
                  child: const CircleAvatar( // CircleAvatar creates a circular shaped widget
                    backgroundColor: Colors.black, // Black background for the circle
                    radius: 22, // Controls the size of the circle
                    child: Icon(Icons.arrow_back, color: Colors.white, size: 20), // White arrow icon inside the circle
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

// --- 2. MAIN BIDS LIST SCREEN ---
class MyBidsScreen extends StatefulWidget { // StatefulWidget because list changes based on search input
  const MyBidsScreen({super.key}); // Constructor with optional key parameter

  @override
  State<MyBidsScreen> createState() => _MyBidsScreenState(); // Creates the mutable state object for this widget
}

class _MyBidsScreenState extends State<MyBidsScreen> { // State class holds all the dynamic data
  final List<String> _allStudents = [ // Static full list of all student names
    "Bilal Raza", "Sara Ali", "Zayan Khan", "Ayesha Malik", // First four student names
    "Hamza Sheikh", "Dua Fatima", "Mustafa Ali", "Zainab Junaid", // Next four student names
    "Omer Farooq", "Hania Amir" // Last two student names
  ];

  List<String> _filteredStudents = []; // Dynamic list that updates based on search input
  final TextEditingController _searchController = TextEditingController(); // Controller to read and clear the search field

  @override
  void initState() { // Called once when this screen first loads
    super.initState(); // Always call super first in initState
    _filteredStudents = _allStudents; // Initially show all students before any search is made
  }

  void _runFilter(String enteredKeyword) { // Function that filters students based on typed keyword
    List<String> results = []; // Temporary empty list to hold matching results
    if (enteredKeyword.isEmpty) { // Check if the search box is empty
      results = _allStudents; // If empty, restore full list of students
    } else {
      results = _allStudents
          .where((user) => user.toLowerCase().contains(enteredKeyword.toLowerCase())) // Case-insensitive match
          .toList(); // Convert the filtered iterable back to a list
    }
    setState(() { // Trigger UI rebuild with new filtered data
      _filteredStudents = results; // Update the displayed list with filtered results
    });
  }

  @override
  Widget build(BuildContext context) { // Build method returns the screen's widget tree
    return Scaffold( // Scaffold provides the basic screen structure
      backgroundColor: const Color(0xFFF8F9FB), // Light grey background for the whole screen
      extendBody: true, // Allow body content to extend behind the bottom navigation bar
      resizeToAvoidBottomInset: false, // Prevent the screen from resizing when keyboard appears
      body: Column( // Column stacks widgets vertically
        children: [
          const CustomTabHeader(title: "My Bids"), // Display the reusable header with title
          Padding(
            padding: const EdgeInsets.all(16.0), // Add uniform padding around the search bar
            child: TextField( // Text input field for searching students
              controller: _searchController, // Link to controller to manage input value
              onChanged: (value) => _runFilter(value), // Call filter function every time text changes
              decoration: InputDecoration( // Visual styling for the text field
                hintText: "Search Here...", // Placeholder text shown when field is empty
                prefixIcon: const Icon(Icons.search), // Search icon displayed on the left side
                suffixIcon: _searchController.text.isNotEmpty // Only show clear button when there is text
                    ? IconButton(
                  icon: const Icon(Icons.clear), // X icon to clear the search input
                  onPressed: () {
                    _searchController.clear(); // Wipe all text from the search field
                    _runFilter(""); // Reset filtered list back to full list
                  },
                )
                    : null, // No suffix icon when search field is empty
                filled: true, // Enable background fill color for the text field
                fillColor: Colors.white, // White background inside the search box
                border: OutlineInputBorder( // Define the border style of the field
                  borderRadius: BorderRadius.circular(15), // Smooth rounded corners for the field
                  borderSide: BorderSide.none, // Hide the visible border stroke
                ),
              ),
            ),
          ),
          Expanded( // Expanded fills remaining vertical space with the list
            child: _filteredStudents.isNotEmpty // Check if there are any matching students
                ? ListView.builder( // Efficient scrollable list built on demand
              itemCount: _filteredStudents.length, // Total number of items to render
              padding: const EdgeInsets.only(bottom: 150, top: 10), // Space at top and bottom of list
              itemBuilder: (context, index) => _BidListTile( // Build each tile for every student
                name: _filteredStudents[index], // Pass the current student's name to the tile
                onTap: () => Navigator.push( // Navigate to details screen on tap
                  context,
                  MaterialPageRoute(builder: (context) => const BidDetailsScreen()), // Create route to details
                ),
              ),
            )
                : const Center( // Center widget when no results are found
              child: Text("No students found", style: TextStyle(color: Colors.grey)), // Grey empty state message
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Circular floating button at the bottom
        onPressed: () {}, // Placeholder for add new bid action
        backgroundColor: Colors.black, // Black background for the FAB
        shape: const CircleBorder(), // Force perfectly circular shape
        child: const Icon(Icons.add, color: Colors.white, size: 30), // White plus icon inside the FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Dock FAB in center of bottom bar
      bottomNavigationBar: const CustomBottomNav(), // Attach the shared custom navigation bar
    );
  }
}

// --- 3. BID DETAILS SCREEN ---
class BidDetailsScreen extends StatefulWidget { // StatefulWidget because buttons change state on press
  const BidDetailsScreen({super.key}); // Constructor with optional key

  @override
  State<BidDetailsScreen> createState() => _BidDetailsScreenState(); // Creates the mutable state for this screen
}

class _BidDetailsScreenState extends State<BidDetailsScreen> { // State class for bid details screen
  String _selectedButtonLabel = ""; // Tracks which action button is currently selected, empty by default

  void _showPopup(BuildContext context, Widget content) { // Helper function to show a dialog popup
    showDialog( // Display a modal dialog on top of the screen
      context: context, // Pass context for dialog positioning
      builder: (context) => Dialog( // Build the dialog widget
        backgroundColor: Colors.white, // White background for the dialog box
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Rounded dialog corners
        child: Padding(padding: const EdgeInsets.all(24), child: content), // Padding around dialog content
      ),
    );
  }

  void _onButtonPressed(String label, Widget popup) async { // Async function to handle button press logic
    if (label == "Reject Offer") { // Check if the pressed button is the reject button
      final confirmed = await showDialog<bool>( // Show reject confirmation dialog and wait for result
        context: context, // Context for positioning the dialog
        builder: (context) => Dialog( // Build the confirmation dialog
          backgroundColor: Colors.white, // White background for reject dialog
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)), // Rounded corners
          child: const Padding(padding: EdgeInsets.all(24), child: _RejectPopup()), // Show reject popup content
        ),
      );
      if (confirmed == true) { // Only proceed if user actually tapped REJECT button
        setState(() => _selectedButtonLabel = "Rejected"); // Update state to hide all action buttons
      }
    } else { // Handle accept and counter offer buttons
      setState(() => _selectedButtonLabel = label); // Update state to highlight the selected button
      _showPopup(context, popup); // Open the appropriate popup for the selected action
    }
  }

  @override
  Widget build(BuildContext context) { // Build method returns the details screen widget tree
    return Scaffold( // Scaffold provides the basic screen layout structure
      backgroundColor: const Color(0xFFF8F9FB), // Light grey background matching the list screen
      extendBody: true, // Allow content to flow behind the bottom navigation bar
      resizeToAvoidBottomInset: false, // Keep layout static when keyboard is shown
      body: Column( // Vertical stack for header and scrollable content
        children: [
          const CustomTabHeader(title: "Bid Details"), // Show header with Bid Details title
          Expanded( // Fill remaining space with scrollable content
            child: SingleChildScrollView( // Allow content to scroll if it overflows the screen
              padding: const EdgeInsets.all(20), // Uniform padding around all inner content
              child: Column( // Vertical stack for info card and action buttons
                children: [
                  const _BidInfoCard(), // Display the bid information card at the top
                  const SizedBox(height: 40), // Vertical spacing between info card and buttons

                  // Conditionally show buttons OR rejection message based on current state
                  if (_selectedButtonLabel != "Rejected") ...[ // Show buttons only if offer is not rejected
                    _StatusButton( // Accept offer action button
                      label: "Accept Offer", // Button display text
                      color: _selectedButtonLabel == "Accept Offer" ? Colors.black : const Color(0xFFE0E0E0), // Black when selected, grey otherwise
                      textColor: _selectedButtonLabel == "Accept Offer" ? Colors.white : Colors.black, // White text when selected, black otherwise
                      onTap: () => _onButtonPressed("Accept Offer", const _SuccessPopup()), // Show success popup on tap
                    ),
                    _StatusButton( // Counter offer action button
                      label: "Counter Offer", // Button display text
                      color: _selectedButtonLabel == "Counter Offer" ? Colors.black : const Color(0xFFE0E0E0), // Black when selected, grey otherwise
                      textColor: _selectedButtonLabel == "Counter Offer" ? Colors.white : Colors.black, // White text when selected, black otherwise
                      onTap: () => _onButtonPressed("Counter Offer", const _CounterPopup()), // Show counter popup on tap
                    ),
                    _StatusButton( // Reject offer action button
                      label: "Reject Offer", // Button display text
                      color: _selectedButtonLabel == "Reject Offer" ? Colors.black : const Color(0xFFE0E0E0), // Black when selected, grey otherwise
                      textColor: _selectedButtonLabel == "Reject Offer" ? Colors.white : Colors.black, // White text when selected, black otherwise
                      onTap: () => _onButtonPressed("Reject Offer", const _RejectPopup()), // Show reject confirmation on tap
                    ),
                  ] else ...[ // Show this block when offer has been confirmed as rejected
                    Container( // Styled container to display the rejection status message
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20), // Inner spacing for the message
                      decoration: BoxDecoration( // Visual styling for the rejection container
                        color: Colors.red.shade50, // Very light red background to indicate rejection
                        borderRadius: BorderRadius.circular(15), // Rounded corners for the container
                        border: Border.all(color: Colors.red.shade200), // Subtle red border around the container
                      ),
                      child: const Row( // Horizontal layout for icon and text
                        mainAxisAlignment: MainAxisAlignment.center, // Center the row content horizontally
                        children: [
                          Icon(Icons.cancel_outlined, color: Colors.red, size: 26), // Red cancel icon on the left
                          SizedBox(width: 10), // Small gap between icon and text
                          Text(
                            "Offer Rejected", // Rejection status label text
                            style: TextStyle(
                              color: Colors.red, // Red text color to match rejection theme
                              fontWeight: FontWeight.bold, // Bold text for emphasis
                              fontSize: 16, // Readable font size
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],

                  const SizedBox(height: 100), // Bottom spacing to clear the floating action button
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton( // Floating action button at the bottom center
        onPressed: () {}, // Placeholder action for the FAB
        backgroundColor: Colors.black, // Black background for the FAB
        shape: const CircleBorder(), // Perfectly circular FAB shape
        child: const Icon(Icons.add, color: Colors.white, size: 30), // White plus icon inside FAB
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // Position FAB in center of nav bar
      bottomNavigationBar: const CustomBottomNav(), // Attach the shared bottom navigation bar
    );
  }
}

// --- 4. POPUP CONTENT & COMPONENTS ---
class _SuccessPopup extends StatelessWidget { // Stateless popup for accept offer success message
  const _SuccessPopup(); // Constructor with no parameters needed
  @override
  Widget build(BuildContext context) { // Build method for the success popup content
    return const Column( // Vertical layout for popup elements
      mainAxisSize: MainAxisSize.min, // Wrap height to content size, don't fill dialog
      children: [
        Text("🎉", style: TextStyle(fontSize: 50)), // Large celebration emoji at the top
        SizedBox(height: 15), // Space between emoji and title
        Text("Congratulations",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1A237E))), // Dark blue bold heading
        SizedBox(height: 10), // Space between heading and message
        Text("You're now connected with your student. Get ready to start your lessons!",
            textAlign: TextAlign.center, style: TextStyle(color: Colors.grey, fontSize: 13)), // Centered grey message
        SizedBox(height: 20), // Space between message and loading spinner
        CircularProgressIndicator(color: Colors.black, strokeWidth: 2), // Black loading spinner at the bottom
      ],
    );
  }
}

class _CounterPopup extends StatelessWidget { // Stateless popup for counter offer input
  const _CounterPopup(); // Constructor with no parameters needed
  @override
  Widget build(BuildContext context) { // Build method for the counter offer popup content
    return Column( // Vertical layout for counter offer elements
      mainAxisSize: MainAxisSize.min, // Shrink height to fit content only
      children: [
        const Text("Student Offer", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)), // Label for student's original offer
        const Text("1500 PKR", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 20)), // Student offer amount in blue
        const SizedBox(height: 20), // Space before the input section
        const Text("Enter your offer", style: TextStyle(fontWeight: FontWeight.w500)), // Instruction label for input
        const SizedBox(height: 10), // Space between label and input field
        TextField( // Input field for tutor to type their counter offer amount
          textAlign: TextAlign.center, // Center the typed text inside the field
          decoration: InputDecoration(
            hintText: "1700", // Sample hint showing an example counter offer amount
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)), // Pill-shaped rounded border
          ),
        ),
        const SizedBox(height: 20), // Space between input and action buttons
        Row( // Horizontal layout for cancel and send buttons
          children: [
            Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))), // Cancel button closes the dialog
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context), // Send button also closes dialog for now
                style: ElevatedButton.styleFrom(backgroundColor: Colors.black, shape: const StadiumBorder()), // Black pill-shaped send button
                child: const Text("Send", style: TextStyle(color: Colors.white)), // White Send label text
              ),
            ),
          ],
        )
      ],
    );
  }
}

class _RejectPopup extends StatelessWidget { // Stateless confirmation popup for rejecting an offer
  const _RejectPopup(); // Constructor with no parameters needed
  @override
  Widget build(BuildContext context) { // Build method for the reject confirmation popup
    return Column( // Vertical layout for the confirmation elements
      mainAxisSize: MainAxisSize.min, // Wrap height to only what is needed
      children: [
        const Text("Are you sure?", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Bold confirmation question
        const SizedBox(height: 15), // Space between question and warning message
        const Text(
          "Do you really want to reject this student's bid? This action cannot be undone.", // Warning message text
          textAlign: TextAlign.center, // Center align the warning message
          style: TextStyle(color: Colors.grey), // Grey color for the warning text
        ),
        const SizedBox(height: 25), // Space between warning and action buttons
        Row( // Horizontal layout for cancel and reject buttons
          mainAxisAlignment: MainAxisAlignment.end, // Push buttons to the right side
          children: [
            TextButton(
              onPressed: () => Navigator.pop(context, false), // Return false when user cancels, no rejection happens
              child: const Text("CANCEL", style: TextStyle(color: Colors.black)), // Black CANCEL button
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true), // Return true when user confirms rejection
              child: const Text("REJECT", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)), // Bold red REJECT button
            ),
          ],
        )
      ],
    );
  }
}

class _BidListTile extends StatelessWidget { // Stateless widget for each student row in the list
  final String name; // Student name to display on the tile
  final VoidCallback onTap; // Callback function triggered when Details button is tapped
  const _BidListTile({required this.name, required this.onTap}); // Constructor requiring name and tap handler

  @override
  Widget build(BuildContext context) { // Build method for the list tile widget
    return Container( // Outer container for the tile with styling
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Horizontal and vertical spacing between tiles
      padding: const EdgeInsets.all(12), // Inner spacing between tile edges and content
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), // White rounded tile background
      child: Row( // Horizontal layout for avatar, name, and button
        children: [
          const CircleAvatar(backgroundColor: Colors.black, radius: 25), // Black circle as placeholder profile picture
          const SizedBox(width: 15), // Gap between avatar and student name
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold)), // Bold student name text
          const Spacer(), // Pushes the Details button to the far right side
          ElevatedButton(
            onPressed: onTap, // Navigate to bid details screen on press
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black, // Black background for the details button
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)), // Slightly rounded button corners
            ),
            child: const Text("Details", style: TextStyle(color: Colors.white, fontSize: 11)), // Small white Details label
          )
        ],
      ),
    );
  }
}

class _BidInfoCard extends StatelessWidget { // Stateless card widget showing bid information
  const _BidInfoCard(); // Constructor with no parameters
  @override
  Widget build(BuildContext context) { // Build method for the info card
    return Container( // Outer container for the info card with styling
      padding: const EdgeInsets.all(20), // Inner padding around all card content
      decoration: BoxDecoration(
        color: Colors.white, // White card background
        borderRadius: BorderRadius.circular(20), // Rounded corners for the card
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)], // Very subtle shadow under card
      ),
      child: Column( // Vertical layout for image row and offer details
        children: [
          Row( // Horizontal layout for subject image and subject info
            children: [
              Container(
                width: 80, // Fixed width for the subject image placeholder
                height: 80, // Fixed height for the subject image placeholder
                decoration: BoxDecoration(color: Colors.red[900], borderRadius: BorderRadius.circular(10)), // Dark red rounded image placeholder
              ),
              const SizedBox(width: 15), // Gap between image and text info
              const Column( // Vertical stack for subject details
                crossAxisAlignment: CrossAxisAlignment.start, // Left align all text in this column
                children: [
                  Text("Physics", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)), // Subject name in bold
                  Text("2000 PKR | Matric", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)), // Price and level in blue
                  Text("⭐ 4.2 | ONLINE", style: TextStyle(fontSize: 10, color: Colors.grey)), // Rating and mode in small grey text
                ],
              ),
            ],
          ),
          const Divider(height: 40), // Horizontal divider line separating subject info from offer details
          const Row( // Row for tutor's offer label and amount
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push label and value to opposite sides
            children: [
              Text("Your Offer:", style: TextStyle(fontWeight: FontWeight.bold)), // Bold label on the left
              Text("2000 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)), // Red bold offer amount on the right
            ],
          ),
          const Row( // Row for student's offer label and amount
            mainAxisAlignment: MainAxisAlignment.spaceBetween, // Push label and value to opposite sides
            children: [
              Text("Student Offer:", style: TextStyle(fontWeight: FontWeight.bold)), // Bold label on the left
              Text("1500 PKR", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18)), // Red bold student amount on the right
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusButton extends StatelessWidget { // Reusable stateless button for accept, counter, and reject actions
  final String label; // Text to display on the button
  final Color color; // Background color that changes based on selection state
  final Color textColor; // Text color that changes based on selection state
  final VoidCallback onTap; // Function called when the button is pressed

  const _StatusButton({required this.label, required this.color, this.textColor = Colors.white, required this.onTap}); // Constructor with default white text color

  @override
  Widget build(BuildContext context) { // Build method for the status button
    return Padding(
      padding: const EdgeInsets.only(bottom: 12), // Bottom spacing to separate stacked buttons
      child: SizedBox(
        width: double.infinity, // Button stretches to full screen width
        height: 55, // Standard fixed height for all action buttons
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: color, // Dynamic background color passed from parent state
            elevation: 0, // Remove default button shadow for flat appearance
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Rounded corners for the button
          ),
          onPressed: onTap, // Trigger the parent provided tap function
          child: Text(label, style: TextStyle(color: textColor, fontWeight: FontWeight.bold)), // Bold label with dynamic text color
        ),
      ),
    );
  }
}