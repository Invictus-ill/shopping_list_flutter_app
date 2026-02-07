import 'package:flutter/material.dart';
import 'package:shopping_list_flutter_app/data/dummy_items.dart';
import 'package:shopping_list_flutter_app/models/grocery_item.dart';
import 'package:shopping_list_flutter_app/widgets/new_item.dart';

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  final List<GroceryItem> _groceryItems = [];

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Groceries'),
        actions: [
          IconButton(
            onPressed: () async {
              final GroceryItem? newItem = await Navigator.of(context)
                  .push<GroceryItem>(
                    MaterialPageRoute(builder: (ctx) => NewItem()),
                  );
              if (newItem == null) {
                return;
              }
              setState(() {
                _groceryItems.add(newItem);
              });
            },
            icon: Icon(Icons.add),
          ),
        ],
      ),
      body: _groceryItems.isNotEmpty
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
                  setState(() {
                    _groceryItems.remove(_groceryItems[index]);
                  });
                },
              ),
              itemCount: _groceryItems.length,
            )
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
