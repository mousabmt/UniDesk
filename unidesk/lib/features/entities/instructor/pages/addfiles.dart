import 'package:flutter/material.dart';

class AddFilesPage extends StatelessWidget {
  const AddFilesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // ---------------- Greeting Box ----------------
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
                    "Upload and manage your course files.",
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),

                  const SizedBox(height: 16),

                  // -------- Select Course Dropdown --------
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xfff4f4f4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        hint: const Text("Select Course"),
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
                        onChanged: (value) {},
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- Upload Card ----------------
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                children: [

                  Icon(Icons.cloud_upload,
                      size: 60, color: const Color(0xff0bb4b1)),

                  const SizedBox(height: 10),

                  const Text(
                    "Browse or drag & drop files",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ---------- Upload File Button ----------
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff0bb4b1),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      icon: const Icon(Icons.upload, color: Colors.white),
                      label: const Text(
                        "Upload File",
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ---------------- My Courses ----------------
            const Text(
              "My Courses",
              style: TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 14),

            CourseFileCard(
              title: "CS301",
              subtitle: "Data Structures",
              fileCount: 4,
            ),

            const SizedBox(height: 12),

            CourseFileCard(
              title: "STAT210",
              subtitle: "Statistics II",
              fileCount: 4,
            ),

            const SizedBox(height: 20),

            // ---------- Add New Course ----------
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                icon: const Icon(Icons.add, color: Color(0xffd36b8b)),
                label: const Text(
                  "Add New Course",
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

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}

//
// ---------------------- COURSE CARD ----------------------
//
class CourseFileCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int fileCount;

  const CourseFileCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.fileCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: Row(
        children: [

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xff0bb4b1),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey),
                ),

                const SizedBox(height: 5),

                Text(
                  "$fileCount files",
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xffd2f4f2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.folder_open,
              color: Color(0xff0bb4b1),
            ),
          ),
        ],
      ),
    );
  }
}