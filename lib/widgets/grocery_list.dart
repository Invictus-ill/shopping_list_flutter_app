import 'package:flutter/material.dart';
import 'package:shopping_list_flutter_app/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(context) {
    // return Column(
    //   children: [
    //     for (GroceryItem groceryItem in groceryItems)
    //       GroceryListItem(groceryItem: groceryItem),
    //   ],
    // );
    return ListView.builder(
      itemBuilder: (ctx, index) =>
          // GroceryListItem(groceryItem: groceryItems[index]),
          ListTile(
            leading: Icon(
              Icons.square,
              color: groceryItems[index].category.color,
            ),
            title: Text(groceryItems[index].name),
            trailing: Text(groceryItems[index].quantity.toString()),
          ),
      itemCount: groceryItems.length,
    );
  }
}
