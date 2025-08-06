import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class profile_list extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final void Function()? onTap;

  const profile_list({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      overlayColor: const WidgetStatePropertyAll(Colors.transparent),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.06,
              width: MediaQuery.of(context).size.width * 0.9,
              child: Row(children: [
                Container(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.1500,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 247, 250, 247),
                    shape: BoxShape.circle,
                  ),
                  child: CircleAvatar(
          radius: 25,
          backgroundColor: icon == Icons.power_settings_new ? Colors.redAccent : Colors.blueAccent,
          child:  Icon(icon, color: Colors.white),
        ),
                ),
                const SizedBox(
                  width: 5,
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.06,
                  width: MediaQuery.of(context).size.width * 0.5800,
                  child: Row(children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        title,
                        style: GoogleFonts.inter(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                            color: color),
                      ),
                    ),
                  ]),
                ),
                Container(
                    height: MediaQuery.of(context).size.height * 0.06,
                    width: MediaQuery.of(context).size.width * 0.1100,
                    decoration: const BoxDecoration(),
                    child: const Icon(Icons.arrow_forward_outlined)
                    ),
              ]),
            ),
          ],
        ),
      ),
    );
  }
}
