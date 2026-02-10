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
  var _isLoading = true;
  String _error = "";

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

  void _loadItems() async {
    final uri = Uri.https(
      'flutter-shopping-list-ap-66bb2-default-rtdb.asia-southeast1.firebasedatabase.app',
      'shopping-list.json',
    );

    try {
      final response = await http.get(uri);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to retreive items. Try again later.';
        });
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
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
      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (err) {
      _error = "Something went wrong! Please try again later.";
    }
  }

  @override
  void initState() {
    _loadItems();
    super.initState();
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
      body: _error.isNotEmpty
          ? Center(child: Text(_error))
          : _groceryItems.isNotEmpty
          ? ListView.builder(
              itemBuilder: (ctx, index) => Dismissible(
                key: ValueKey(_groceryItems[index].id),
                child: ListTile(
                  leading: Icon(
                    Icons.square,
                    color: _groceryItems[index].category.color,
                  ),
                  title: Text(_groceryItems[index].name),
                  trailing: Text(_groceryItems[index].quantity.toString()),
                ),
                onDismissed: (direction) {
                  _removeItem(_groceryItems[index], index);
                  setState(() {
                    _groceryItems.remove(_groceryItems[index]);
                  });
                },
              ),
              itemCount: _groceryItems.length,
            )
          : _isLoading
          ? Center(child: CircularProgressIndicator())
          : Center(
              child: Text(
                'Add grocery items to see this view',
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
    );
  }
}
