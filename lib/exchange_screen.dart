import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ExchangeScreen extends StatefulWidget {
  final String token;

  ExchangeScreen({required this.token});

  @override
  _ExchangeScreenState createState() => _ExchangeScreenState();
}

class _ExchangeScreenState extends State<ExchangeScreen> {
  List<String> purchasedItems = [];
  bool isLoading = true;
  bool showPurchaseOptions = false;
  int currentCoins = 0;

  @override
  void initState() {
    super.initState();
    _fetchPurchasedItems();
    _fetchUserCoins();
  }

  Future<void> _fetchPurchasedItems() async {
    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/getPurchasedItems'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token_id': widget.token,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        purchasedItems = List<String>.from(data['items']);
        isLoading = false;
      });
    } else {
      // Handle error
      print('Failed to load purchased items');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _fetchUserCoins() async {
    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/getUserCoins'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token_id': widget.token,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        currentCoins = data['coins'];
      });
    } else {
      // Handle error
      print('Failed to load user coins');
    }
  }

  Future<void> _purchaseItem(String itemName, int itemCost) async {
    if (currentCoins < itemCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Purchase Failed'),
          content: Text('You do not have enough coins to purchase this item.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('http://172.10.7.88:80/purchaseItem'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'token_id': widget.token,
        'item_name': itemName,
        'item_cost': itemCost,
      }),
    );

    if (response.statusCode == 200) {
      // Purchase successful, update purchased items and coins
      _fetchPurchasedItems();
      _fetchUserCoins();
    } else {
      // Handle error
      print('Failed to purchase item');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Purchase Failed'),
          content: Text('Failed to purchase item. Please try again.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Exchange Items'),
        actions: [
          if (!showPurchaseOptions)
            IconButton(
              icon: Icon(Icons.shopping_cart),
              onPressed: () {
                setState(() {
                  showPurchaseOptions = true;
                });
              },
            ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : showPurchaseOptions
          ? Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current Coins: $currentCoins',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: _buildPurchaseOptions()),
        ],
      )
          : _buildPurchasedItems(),
    );
  }

  Widget _buildPurchasedItems() {
    return purchasedItems.isEmpty
        ? Center(child: Text('No items purchased yet.'))
        : ListView.builder(
      itemCount: purchasedItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(purchasedItems[index]),
        );
      },
    );
  }

  Widget _buildPurchaseOptions() {
    return ListView(
      children: [
        ListTile(
          leading: Image.asset('assets/images/banana_milk.jpg'),
          title: Text('Banana Milk'),
          subtitle: Text('Cost: 10 Coins'),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('Banana Milk', 10),
            child: Text('Purchase'),
          ),
        ),
        ListTile(
          leading: Image.asset('assets/images/pepero.jpg'),
          title: Text('Pepero'),
          subtitle: Text('Cost: 5 Coins'),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('Pepero', 5),
            child: Text('Purchase'),
          ),
        ),
        ListTile(
          leading: Image.asset('assets/images/cultureland_10000.jpg'),
          title: Text('Cultureland Gift Card 10000₩'),
          subtitle: Text('Cost: 50 Coins'),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('Cultureland Gift Card 10000₩', 50),
            child: Text('Purchase'),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showPurchaseOptions = false;
            });
          },
          child: Text('Back to Purchased Items'),
        ),
      ],
    );
  }
}
