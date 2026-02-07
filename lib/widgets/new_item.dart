import 'package:flutter/material.dart';
import 'package:shopping_list_flutter_app/data/categories.dart';
import 'package:shopping_list_flutter_app/models/category.dart';
import 'package:shopping_list_flutter_app/models/grocery_item.dart';

import 'package:http/http.dart' as http;

class NewItem extends StatefulWidget {
  const NewItem({super.key});

  @override
  State<StatefulWidget> createState() {
    return _NewItemState();
  }
}

class _NewItemState extends State<NewItem> {
  final _formKey = GlobalKey<FormState>();
  String _enteredName = '';
  int _enteredQuantity = 1;
  var _selectedCategory = categories[Categories.carbs];

  void _saveItem() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final uri = Uri.https(
        'flutter-shopping-list-ap-66bb2-default-rtdb.asia-southeast1.firebasedatabase.app',
        'shopping-list.json',
      );
      http.post(uri);
      Navigator.of(context).pop(
        GroceryItem(
          id: DateTime.now().toString(),
          name: _enteredName,
          quantity: _enteredQuantity,
          category: _selectedCategory!,
        ),
      );
    }
  }

  @override
  Widget build(context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a new item')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: _formKey,
          child: Column(
            spacing: 8,
            children: [
              TextFormField(
                maxLength: 50,
                decoration: InputDecoration(label: Text("Name")),
                validator: (value) {
                  if (value == null ||
                      value.isEmpty ||
                      value.trim().length <= 1 ||
                      value.trim().length > 50) {
                    return 'Must be between 1 and 50 characters';
                  }
                  return null;
                },
                onSaved: (newValue) => _enteredName = newValue!,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        label: Text("Quantity"),
                      ),
                      initialValue: _enteredQuantity.toString(),
                      validator: (value) {
                        if (value == null ||
                            value.isEmpty ||
                            int.tryParse(value) == null ||
                            int.parse(value) <= 0) {
                          return 'Must be a valid positive number';
                        }
                        return null;
                      },
                      onSaved: (newValue) =>
                          _enteredQuantity = int.parse(newValue!),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonFormField(
                      initialValue: _selectedCategory,
                      onSaved: (newValue) => _selectedCategory = newValue,
                      items: [
                        for (final category in categories.entries)
                          DropdownMenuItem(
                            value: category.value,
                            child: Row(
                              children: [
                                Icon(Icons.square, color: category.value.color),
                                Text(category.value.name),
                              ],
                            ),
                          ),
                      ],
                      onChanged: (value) {},
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () {
                      _formKey.currentState!.reset();
                    },
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: _saveItem,
                    child: const Text('Add Item'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
