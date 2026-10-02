import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

// ======================================================
// APP
// ======================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Fruit Directory',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
        ),
        useMaterial3: true,
      ),
      home: const FruitHomePage(),
    );
  }
}

// ======================================================
// FRUIT MODEL
// ======================================================

class Fruit {
  final int id;
  final String name;
  final String family;
  final String genus;
  final double calories;
  final double protein;
  final double carbohydrates;
  final double fat;

  Fruit({
    required this.id,
    required this.name,
    required this.family,
    required this.genus,
    required this.calories,
    required this.protein,
    required this.carbohydrates,
    required this.fat,
  });

  factory Fruit.fromJson(Map<String, dynamic> json) {
    return Fruit(
      id: json['id'],
      name: json['name'],
      family: json['family'],
      genus: json['genus'],
      calories: (json['nutritions']['calories'] ?? 0).toDouble(),
      protein: (json['nutritions']['protein'] ?? 0).toDouble(),
      carbohydrates:
          (json['nutritions']['carbohydrates'] ?? 0).toDouble(),
      fat: (json['nutritions']['fat'] ?? 0).toDouble(),
    );
  }
}

// ======================================================
// HOME PAGE
// ======================================================

class FruitHomePage extends StatefulWidget {
  const FruitHomePage({super.key});

  @override
  State<FruitHomePage> createState() => _FruitHomePageState();
}

class _FruitHomePageState extends State<FruitHomePage> {

  // API URL
  final String apiUrl =
      'https://www.fruityvice.com/api/fruit/all';

  // Store API result
  late Future<List<Fruit>> fruits;

  @override
  void initState() {
    super.initState();

    // Fetch fruits when the app starts
    fruits = fetchFruits();
  }

  // ======================================================
  // FETCH FRUITS FROM API
  // ======================================================

  Future<List<Fruit>> fetchFruits() async {

    final response = await http.get(
      Uri.parse(apiUrl),
    );

    // Check if API request was successful
    if (response.statusCode == 200) {

      // Convert JSON response
      final List<dynamic> data =
          jsonDecode(response.body);

      // Convert JSON into Fruit objects
      return data
          .map((json) => Fruit.fromJson(json))
          .toList();

    } else {

      throw Exception(
        'Failed to load fruits',
      );
    }
  }

  // ======================================================
  // BUILD PAGE
  // ======================================================

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      // ==================================================
      // APP BAR
      // ==================================================

      appBar: AppBar(
        title: const Text(
          'Fruit Directory',
        ),
        centerTitle: true,
      ),

      // ==================================================
      // BODY
      // ==================================================

      body: FutureBuilder<List<Fruit>>(

        future: fruits,

        builder: (context, snapshot) {

          // ==================================================
          // LOADING
          // ==================================================

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          // ==================================================
          // ERROR
          // ==================================================

          if (snapshot.hasError) {

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),

                child: Text(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          // ==================================================
          // NO DATA
          // ==================================================

          if (!snapshot.hasData ||
              snapshot.data!.isEmpty) {

            return const Center(
              child: Text(
                'No fruits found.',
              ),
            );
          }

          // ==================================================
          // GET FRUITS
          // ==================================================

          final List<Fruit> fruitList =
              snapshot.data!;

          // ==================================================
          // LIST VIEW BUILDER
          // ==================================================

          return ListView(
            children: [

              // Header
              const FruitHeader(),

              // Fruit list
              ListView.builder(

                shrinkWrap: true,

                physics:
                    const NeverScrollableScrollPhysics(),

                itemCount: fruitList.length,

                itemBuilder: (context, index) {

                  final fruit =
                      fruitList[index];

                  return FruitCard(
                    fruit: fruit,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

// ======================================================
// FRUIT HEADER
// ======================================================

class FruitHeader extends StatelessWidget {
  const FruitHeader({super.key});

  @override
  Widget build(BuildContext context) {

    return Container(

      padding: const EdgeInsets.all(24),

      color: Colors.green.shade100,

      child: Column(
        children: [

          // Fruit icon
          const Icon(
            Icons.eco,
            size: 60,
            color: Colors.green,
          ),

          const SizedBox(height: 10),

          // Title
          const Text(
            'Welcome to Fruit Directory',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          // Description
          const Text(
            'Discover fruits and their nutritional information',
            style: TextStyle(
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // API button
          ElevatedButton.icon(
            icon: const Icon(
              Icons.cloud_download,
            ),
            label: const Text(
              'View Fruits',
            ),
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

// ======================================================
// FRUIT CARD
// ======================================================

class FruitCard extends StatelessWidget {

  final Fruit fruit;

  const FruitCard({
    super.key,
    required this.fruit,
  });

  @override
  Widget build(BuildContext context) {

    return Card(

      margin: const EdgeInsets.all(12),

      child: Padding(

        padding: const EdgeInsets.all(14),

        child: Row(

          crossAxisAlignment:
              CrossAxisAlignment.start,

          children: [

            // ==================================================
            // FRUIT ICON
            // ==================================================

            Container(

              width: 75,
              height: 75,

              decoration: BoxDecoration(
                color: Colors.green.shade100,
                borderRadius:
                    BorderRadius.circular(15),
              ),

              child: const Icon(
                Icons.apple,
                size: 45,
                color: Colors.green,
              ),
            ),

            const SizedBox(width: 15),

            // ==================================================
            // FRUIT INFORMATION
            // ==================================================

            Expanded(

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  // Fruit name
                  Text(
                    fruit.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Family
                  Text(
                    'Family: ${fruit.family}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  // Genus
                  Text(
                    'Genus: ${fruit.genus}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Nutrition
                  Text(
                    'Calories: ${fruit.calories}',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    'Protein: ${fruit.protein}g',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    'Carbohydrates: ${fruit.carbohydrates}g',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),

                  Text(
                    'Fat: ${fruit.fat}g',
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}