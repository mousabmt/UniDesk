import 'package:flutter/material.dart';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  State<AttendancePage> createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  String? selectedCourse;
  String? selectedLecture;
  bool showAttendance = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
 
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // --------- Header Box ---------
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  const Text(
                    "Hello Dr. Ahmad",
                    style: TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    "Manage your class attendance.",
                    style: TextStyle(color: Colors.grey),
                  ),

                  const SizedBox(height: 16),

                  // -------- Select Course --------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xfff4f4f4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Select Course"),
                        value: selectedCourse,
                        items: const [
                          DropdownMenuItem(
                            value: "CS301",
                            child: Text("CS301 - Data Structures"),
                          ),
                          DropdownMenuItem(
                            value: "STAT210",
                            child: Text("STAT210 - Statistics II"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedCourse = value);
                        },
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // -------- Tabs (Attendance / Reports) --------
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => showAttendance = true);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: showAttendance
                                  ? const Color(0xff0bb4b1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xff0bb4b1),
                              ),
                            ),
                            child: Text(
                              "Attendance",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: showAttendance
                                    ? Colors.white
                                    : const Color(0xff0bb4b1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() => showAttendance = false);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !showAttendance
                                  ? const Color(0xff0bb4b1)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xff0bb4b1),
                              ),
                            ),
                            child: Text(
                              "Reports",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !showAttendance
                                    ? Colors.white
                                    : const Color(0xff0bb4b1),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // -------- Date Picker (Fake for now) --------
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xfff4f4f4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.calendar_today, color: Colors.grey),
                        SizedBox(width: 10),
                        Text("May 14, 2024"),
                        Spacer(),
                        Icon(Icons.arrow_drop_down),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- Select Lecture --------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xfff4f4f4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Select Lecture"),
                        value: selectedLecture,
                        items: const [
                          DropdownMenuItem(
                            value: "lec1",
                            child: Text("Lecture 1: Introduction"),
                          ),
                          DropdownMenuItem(
                            value: "lec2",
                            child: Text("Lecture 2: Trees"),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() => selectedLecture = value);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 25),

            // -------- Students List Title --------
            const Text(
              "Students List",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // -------- Students Cards --------
            StudentAttendanceCard(
              name: "Sara Ali",
              room: "Preding B, Room 2203",
              image: "https://i.pravatar.cc/150?img=47",
              attended: true,
            ),

            const SizedBox(height: 10),

            StudentAttendanceCard(
              name: "Ahmed Hassan",
              room: "Building B, Room 2203",
              image: "https://i.pravatar.cc/150?img=12",
              attended: false,
            ),

            const SizedBox(height: 20),

            // -------- Add New Student --------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Color(0xffd36b8b)),
                label: const Text(
                  "Add New Student",
                  style: TextStyle(
                    color: Color(0xffd36b8b),
                    fontSize: 16,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xffd36b8b)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () {},
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}

//
// ---------------------- Student Card ----------------------
//
class StudentAttendanceCard extends StatelessWidget {
  final String name;
  final String room;
  final String image;
  final bool attended;

  const StudentAttendanceCard({
    super.key,
    required this.name,
    required this.room,
    required this.image,
    required this.attended,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 3),
          )
        ],
      ),
      child: Row(
        children: [

          // Avatar
          CircleAvatar(
            radius: 26,
            backgroundImage: NetworkImage(image),
          ),

          const SizedBox(width: 14),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  room,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),

          // Status Icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: attended
                  ? const Color(0xffd2f4f2)
                  : const Color(0xffffe6e6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              attended ? Icons.check : Icons.close,
              color: attended
                  ? const Color(0xff0bb4b1)
                  : const Color(0xffd36b6b),
            ),
          ),
        ],
      ),
    );
  }
}