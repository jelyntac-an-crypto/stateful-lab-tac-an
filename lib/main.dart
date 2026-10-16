
import 'package:flutter/material.dart';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: CartScreen(),
  ));
}

class CartItem {
  String name;
  double price;
  int quantity;
  bool gotIt;

  CartItem({
    required this.name,
    required this.price,
    this.quantity = 1,
    this.gotIt = false,
  });
}

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final List<CartItem> _items = [];

  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _priceController =
      TextEditingController();

  String? _nameError;
  String? _priceError;

  @override
  void initState() {
    super.initState();

    _items.addAll([
      CartItem(name: 'Rice', price: 60.00, quantity: 2),
      CartItem(name: 'Eggs', price: 8.00, quantity: 12),
      CartItem(name: 'Milk', price: 95.00, quantity: 1),
    ]);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  double get _total {
    return _items.fold(
      0.0,
      (sum, item) => sum + item.price * item.quantity,
    );
  }

  void _increase(int index) {
    setState(() {
      if (_items[index].quantity < 99) {
        _items[index].quantity++;
      }
    });
  }

  void _decrease(int index) {
    setState(() {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      }
    });
  }

  void _toggle(int index, bool? value) {
    setState(() {
      _items[index].gotIt = value ?? false;
    });
  }

  void _addItem() {
    final String name = _nameController.text.trim();
    final double? price =
        double.tryParse(_priceController.text.trim());

    setState(() {
      _nameError =
          name.isEmpty ? 'Please enter an item name.' : null;

      _priceError = price == null || price <= 0
          ? 'Enter a price greater than 0.'
          : null;

      if (_nameError != null || _priceError != null) {
        return;
      }

      _items.add(
        CartItem(name: name, price: price!),
      );

      _nameController.clear();
      _priceController.clear();
      _nameError = null;
      _priceError = null;
    });
  }

  void _clearChecked() {
    setState(() {
      _items.removeWhere((item) => item.gotIt);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Checked items cleared.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final int gotItCount =
        _items.where((item) => item.gotIt).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Shopping Cart'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              color: Colors.teal.shade50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Items: ${_items.length}'),
                  Text('Got it: $gotItCount'),
                  const SizedBox(height: 6),
                  Text(
                    'Total: PHP ${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: _items.isEmpty
                  ? const Center(
                      child: Text('Your cart is empty.'),
                    )
                  : ListView.builder(
                      itemCount: _items.length,
                      itemBuilder: (context, index) {
                        return CartItemTile(
                          item: _items[index],
                          onIncrease: () => _increase(index),
                          onDecrease: () => _decrease(index),
                          onToggle: (value) =>
                              _toggle(index, value),
                        );
                      },
                    ),
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Item name',
                      hintText: 'e.g. Bread',
                      errorText: _nameError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _priceController,
                    keyboardType:
                        const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: InputDecoration(
                      labelText: 'Price',
                      hintText: 'e.g. 45.00',
                      prefixText: 'PHP ',
                      errorText: _priceError,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add),
                          label: const Text('Add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: _clearChecked,
                          icon: const Icon(Icons.delete_outline),
                          label: const Text('Clear checked'),
                        ),
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
  }
}

class CartItemTile extends StatelessWidget {
  final CartItem item;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<bool?> onToggle;

  const CartItemTile({
    super.key,
    required this.item,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 5,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          children: [
            Checkbox(
              value: item.gotIt,
              onChanged: onToggle,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: item.gotIt
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                    ),
                  ),
                  Text(
                    'PHP ${item.price.toStringAsFixed(2)} each',
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onDecrease,
              icon: const Icon(Icons.remove_circle_outline),
            ),
            Text(
              '${item.quantity}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: onIncrease,
              icon: const Icon(Icons.add_circle_outline),
            ),
          ],
        ),
      ),
    );
  }
}
