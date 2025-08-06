import 'package:flutter/material.dart';

class RecipeDetailScreen extends StatelessWidget {
  final String recipeName;
  final String imageUrl;
  final String duration;
  final List<String> ingredients;
  final List<String> containerA;
  final List<String> containerB;

  const RecipeDetailScreen({
    super.key,
    required this.recipeName,
    required this.imageUrl,
    required this.duration,
    required this.ingredients,
    required this.containerA,
    required this.containerB,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow[700],
        title: Text(recipeName),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Recipe image
            ClipRRect(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
              child: Image.asset(
                      imageUrl,
                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Cooking Time
                  Row(
                    children: [
                      Icon(Icons.timer, color: Colors.yellow[700]),
                      SizedBox(width: 6),
                      Text(
                        duration,
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),

                  // Ingredients
                  Text(
                    'Ingredients',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 10),
                  ...ingredients.map((item) => Text("• $item",
                      style: TextStyle(color: Colors.white70))),
                  SizedBox(height: 20),

                  // Container A
                  Text(
                    'Container A',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 8, bottom: 16),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: containerA
                          .map((item) => Text("• $item",
                              style: TextStyle(color: Colors.white70)))
                          .toList(),
                    ),
                  ),

                  // Container B
                  Text(
                    'Container B',
                    style: TextStyle(
                      color: Colors.yellow[700],
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 8),
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Color(0xFF2C2C2E),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: containerB
                          .map((item) => Text("• $item",
                              style: TextStyle(color: Colors.white70)))
                          .toList(),
                    ),
                  ),

                  SizedBox(height: 30),

                  // Action Button
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // start automation or next step
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.yellow[700],
                        foregroundColor: Colors.black,
                        padding:
                            EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: Icon(Icons.play_arrow),
                      label: Text('Start Cooking'),
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
