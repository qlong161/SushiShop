import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sushishop_btl/components/button.dart';
import 'package:sushishop_btl/pages/admin_page.dart';

class IntroPage extends StatelessWidget {
  const IntroPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 138, 60, 55),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(25.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 25),

                // 1. Shop name
                Text(
                  "SUSHI MAN",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 25),

                // 2. Icon / Image
                Padding(
                  padding: const EdgeInsets.all(50.0),
                  child: Center(
                    child: Image.asset('lib/images/tuna.png', height: 200),
                  ),
                ),
                const SizedBox(height: 25),

                // 3. Title
                Text(
                  "THE TASTE OF JAPANESE FOOD",
                  style: GoogleFonts.dmSerifDisplay(
                    fontSize: 38,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 10),

                // 4. Subtitle
                Text(
                  "Feel the taste of the most popular Japanese food from anywhere and anytime",
                  style: TextStyle(color: Colors.grey[300], height: 2),
                ),
                const SizedBox(height: 30),

                // 5. Get started button
                MyButton(
                  text: "Get Started",
                  onTap: () {
                    Navigator.pushNamed(context, '/menupage');
                  },
                ),
                const SizedBox(height: 30),

                Center(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AdminPage(),
                        ),
                      );
                    },
                    child: Text(
                      "@Được cook bởi 3 sinh viên rất đẹp trai",
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
