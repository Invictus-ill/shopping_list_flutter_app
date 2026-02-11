import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shopping_list_flutter_app/data/categories.dart';
import 'package:shopping_list_flutter_app/models/grocery_item.dart';
import 'package:shopping_list_flutter_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  late Future<List<GroceryItem>> _loadedItems;

  @override
  initState() {
    _loadedItems = _loadItems();
    super.initState();
  }

  void _removeItem(GroceryItem item, int index) async {
    final uri = Uri.https(
      'flutter-shopping-list-ap-66bb2-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list/${item.id}.json',
    );

    final response = await http.delete(uri);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });
    }
  }

  Future<List<GroceryItem>> _loadItems() async {
    final uri = Uri.https(
      'flutter-shopping-list-ap-66bb2-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    final response = await http.get(uri);
    if (response.statusCode >= 400) {
      throw Exception('Failed to retreive Grocery Items');
    }

    if (response.body == 'null') {
      return [];
    }

    final Map<String, dynamic> listData = json.decode(response.body);

    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere((cat) => cat.value.name == item.value['category'])
          .value;
      loadedItems.add(
        GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category,
        ),
      );
    }
    return loadedItems;
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final data = await Navigator.of(context).push<GroceryItem>(
                MaterialPageRoute(builder: (ctx) => NewItem()),
              );

              if (data == null) {
                return;
              } else {
                setState(() {
                  _groceryItems.add(data);
                });
              }
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: FutureBuilder(
        future: _loadedItems,
        builder: (ctx, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text(snapshot.error.toString()));
          } else if (snapshot.hasData) {
            if (snapshot.data!.isEmpty) {
              return Center(
                child: Text(
                  'Add grocery items to see this view',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
                ),
              );
            }
          }
          return ListView.builder(
            itemBuilder: (ctx, index) => Dismissible(
              key: ValueKey(snapshot.data![index].id),
              child: ListTile(
                leading: Icon(
                  Icons.square,
                  color: snapshot.data![index].category.color,
                ),
                title: Text(snapshot.data![index].name),
                trailing: Text(snapshot.data![index].quantity.toString()),
              ),
              onDismissed: (direction) {
                _removeItem(snapshot.data![index], index);
                setState(() {
                  snapshot.data!.remove(snapshot.data![index]);
                });
              },
            ),
            itemCount: snapshot.data!.length,
          );
        },
      ),
    );
  }
}
