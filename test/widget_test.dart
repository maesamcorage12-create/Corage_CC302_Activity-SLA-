import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:sla_api_activity/main.dart';

Map<String, dynamic> fruitJson(String name, {String family = 'Rosaceae'}) {
  return {
    'id': 1,
    'name': name,
    'family': family,
    'genus': 'Malus',
    'nutritions': {
      'calories': 52,
      'protein': 0.3,
      'carbohydrates': 13.8,
      'fat': 0.2,
    },
  };
}

void main() {
  group('Fruit model', () {
    test('fromJson maps every field', () {
      final fruit = Fruit.fromJson(fruitJson('Apple'));

      expect(fruit.id, 1);
      expect(fruit.name, 'Apple');
      expect(fruit.family, 'Rosaceae');
      expect(fruit.genus, 'Malus');
      expect(fruit.calories, 52);
      expect(fruit.protein, 0.3);
      expect(fruit.carbohydrates, 13.8);
      expect(fruit.fat, 0.2);
    });

    test('fromJson defaults a missing nutrition value to 0', () {
      final json = fruitJson('Banana');
      (json['nutritions'] as Map<String, dynamic>).remove('fat');

      final fruit = Fruit.fromJson(json);

      expect(fruit.fat, 0);
      expect(fruit.calories, 52);
    });
  });

  group('Widgets', () {
    testWidgets('FruitCard renders name, family, genus and nutrition', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: FruitCard(fruit: Fruit.fromJson(fruitJson('Apple'))),
          ),
        ),
      );

      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Family: Rosaceae'), findsOneWidget);
      expect(find.text('Genus: Malus'), findsOneWidget);
      expect(find.text('Calories: 52.0'), findsOneWidget);
      expect(find.text('Protein: 0.3g'), findsOneWidget);
      expect(find.text('Carbohydrates: 13.8g'), findsOneWidget);
      expect(find.text('Fat: 0.2g'), findsOneWidget);
    });

    testWidgets('FruitHeader shows the welcome text and button', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: FruitHeader())),
      );

      expect(find.text('Welcome to Fruit Directory'), findsOneWidget);
      expect(find.text('View Fruits'), findsOneWidget);
    });

    testWidgets('ListView.builder renders one card per fruit', (
      tester,
    ) async {
      final fruits = [
        Fruit.fromJson(fruitJson('Apple')),
        Fruit.fromJson(fruitJson('Banana', family: 'Musaceae')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView(
              children: [
                const FruitHeader(),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: fruits.length,
                  itemBuilder: (context, index) => FruitCard(
                    fruit: fruits[index],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(FruitCard), findsNWidgets(2));
      expect(find.text('Apple'), findsOneWidget);
      expect(find.text('Banana'), findsOneWidget);
    });

    testWidgets('MyApp renders the Fruit Directory home page', (
      tester,
    ) async {
      await tester.pumpWidget(const MyApp());
      await tester.pump();

      expect(find.text('Fruit Directory'), findsOneWidget);
      expect(find.byType(FutureBuilder<List<Fruit>>), findsOneWidget);
    });
  });
}