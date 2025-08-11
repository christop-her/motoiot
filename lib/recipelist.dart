import 'package:flutter/material.dart';
import 'package:moto/recipedetails.dart';

class Recipe {
  final String name;
  final String image;
  final String description;
  final String duration;
  final String difficulty;

  Recipe({
    required this.name,
    required this.image,
    required this.description,
    required this.duration,
    required this.difficulty,
  });
}

class RecipeScreen extends StatelessWidget {
  final List<Recipe> recipes = [
    Recipe(
      name: 'Indomie noodles',
      image: 'images/maxresdefault.jpg',
      description: 'A delicious creamy Alfredo pasta.',
      duration: '25 mins',
      difficulty: 'Easy',
    ),
    Recipe(
      name: 'Egg Fried Rice',
      image: 'images/eggrice.jpg',
      description: 'Grilled chicken with spicy marinade.',
      duration: '45 mins',
      difficulty: 'Medium',
    ),
    Recipe(
      name: 'Baked Beans',
      image: 'images/beans.jpg',
      description: 'A healthy plant-based dish.',
      duration: '30 mins',
      difficulty: 'Easy',
    ),
    // Add more items as needed
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1C1C1E),
      appBar: AppBar(
        title: Text('Smart Kitchen Recipes'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.yellow[700],
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
            color: Colors.yellow[700],
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          final recipe = recipes[index];
          return GestureDetector(
            onTap: () {Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecipeDetailScreen(
      recipeName: recipe.name,
      imageUrl: recipe.image,
      duration: recipe.duration,
      ingredients: ['Pasta', 'Cream', 'Garlic', 'Parmesan'],
      containerA: ['Cream', 'Garlic'],
      containerB: ['Pasta', 'Parmesan'],
    ),
  ),
);
            }
,
            child: Container(
              margin: EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: Color(0xFF2C2C2E),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black54,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  )
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                    child: Image.asset(
                      recipe.image,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          recipe.name,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          recipe.description,
                          style: TextStyle(color: Colors.white70),
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconText(
                              icon: Icons.timer,
                              text: recipe.duration,
                            ),
                            IconText(
                              icon: Icons.leaderboard,
                              text: recipe.difficulty,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => RecipeDetailScreen(
      recipeName: recipe.name,
      imageUrl: recipe.image,
      duration: recipe.duration,
      ingredients: ['Pasta', 'pepper', 'seasoning', 'Tomato', '2 eggs'],
      containerA: ['2 eggs', 'Tomato'],
      containerB: ['Pasta', 'pepper', 'seasoning', 'Tomato'],
    ),
  ),
);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.yellow[700],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text('Start'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.yellow[700],
        foregroundColor: Colors.black,
        onPressed: () {
          // Add new recipe or trigger automation
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

class IconText extends StatelessWidget {
  final IconData icon;
  final String text;

  const IconText({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.yellow[700], size: 18),
        SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(color: Colors.white70),
        ),
      ],
    );
  }
}
