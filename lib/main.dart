import 'package:budget_tracker_notion_ng/budget_repository.dart';
import 'package:budget_tracker_notion_ng/failure_model.dart';
import 'package:budget_tracker_notion_ng/item_model.dart';
import 'package:budget_tracker_notion_ng/spending_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:intl/intl.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Notion Budget Tracker',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(color: Colors.white),
      ),
      home: const BudgetScreen(),
    );
  }
}

class BudgetScreen extends StatefulWidget {
  const BudgetScreen({Key? key}) : super(key: key);

  @override
  State<BudgetScreen> createState() => _BudgetScreenState();
}

class _BudgetScreenState extends State<BudgetScreen> {
  late Future<List<Item>> _futureItems;

  @override
  void initState() {
    _futureItems = BudgetRepository().getItems();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Budget Tracker', style: TextStyle(color: Colors.black)),
      ),
      body: FutureBuilder(
        future: _futureItems,
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (snapshot.hasData) {
            // Show pie chart and list view of items.
            final items = snapshot.data!;

            return ListView.builder(
              itemCount: items.length + 1,
              itemBuilder: (BuildContext context, int index) {
                if (index == 0) return SpendingChart(items: items);
                final item = items[index - 1];
                return Container(
                  margin: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(
                      width: 2.0,
                      color: getCategoryColor(item.category),
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 6.0,
                      )
                    ],
                  ),
                  child: ListTile(
                    title: Text(item.name),
                    subtitle: Text(
                        '${item.category} • ${DateFormat.yMd().format(item.date)}'),
                    trailing: Text('-\$${item.price.toStringAsFixed(2)}'),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            // Show failure error message.
            final failure = snapshot.error as Failure;
            return Center(child: Text(failure.message));
          }
          // Show a loading spinner.
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

Color getCategoryColor(String category) {
  switch (category) {
    case 'Entertainment':
      return Colors.red[400]!;
    case 'Food':
      return Colors.green[400]!;
    case 'Personal':
      return Colors.blue[400]!;
    case 'Transportation':
      return Colors.purple[400]!;
    default:
      return Colors.orange[400]!;
  }
}
