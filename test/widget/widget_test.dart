import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Basic Widget Tests', () {
    testWidgets('Text widget should display', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Text('Hello World'),
          ),
        ),
      );

      expect(find.text('Hello World'), findsOneWidget);
    });

    testWidgets('Button should be tappable', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ElevatedButton(
              onPressed: () => wasPressed = true,
              child: const Text('Press Me'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Press Me'));
      expect(wasPressed, true);
    });

    testWidgets('List should display items', (WidgetTester tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: items.length,
              itemBuilder: (context, index) {
                return ListTile(title: Text(items[index]));
              },
            ),
          ),
        ),
      );

      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(ListTile), findsWidgets);
      
      for (final item in items) {
        expect(find.text(item), findsOneWidget);
      }
    });

    testWidgets('Card should contain content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: const [
                    Text('Card Title'),
                    Text('Card Content'),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(Card), findsOneWidget);
      expect(find.text('Card Title'), findsOneWidget);
      expect(find.text('Card Content'), findsOneWidget);
    });

    testWidgets('Icon should be displayed', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Icon(Icons.star),
          ),
        ),
      );

      expect(find.byIcon(Icons.star), findsOneWidget);
    });

    testWidgets('TextField should accept input', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TextField(
              key: const Key('test_field'),
              decoration: const InputDecoration(
                labelText: 'Test Field',
                hintText: 'Enter text here',
              ),
            ),
          ),
        ),
      );

      await tester.enterText(find.byKey(const Key('test_field')), 'Hello');
      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('Container should have properties', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Container(
              width: 100,
              height: 100,
              color: Colors.blue,
              child: const Text('Container'),
            ),
          ),
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.text('Container'), findsOneWidget);
    });

    testWidgets('Row and Column should layout children', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                Row(
                  children: const [
                    Text('Row Item 1'),
                    Text('Row Item 2'),
                  ],
                ),
                const Text('Column Item 1'),
                const Text('Column Item 2'),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.text('Row Item 1'), findsOneWidget);
      expect(find.text('Row Item 2'), findsOneWidget);
      expect(find.text('Column Item 1'), findsOneWidget);
      expect(find.text('Column Item 2'), findsOneWidget);
    });

    testWidgets('Stack should overlay widgets', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Stack(
              children: [
                Container(
                  width: 200,
                  height: 200,
                  color: Colors.grey[300],
                ),
                const Center(
                  child: Text('Stacked Text'),
                ),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(Stack), findsAtLeastNWidgets(1));
      expect(find.byType(Container), findsAtLeastNWidgets(1));
      expect(find.text('Stacked Text'), findsOneWidget);
    });

    testWidgets('AlertDialog should show', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Alert Title'),
                      content: const Text('Alert Content'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );
                },
                child: const Text('Show Alert'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show Alert'));
      await tester.pumpAndSettle();

      expect(find.text('Alert Title'), findsOneWidget);
      expect(find.text('Alert Content'), findsOneWidget);
      expect(find.text('OK'), findsOneWidget);
    });
  });
}
