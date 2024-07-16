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
      print('구매한 상품을 불러오지 못했습니다.');
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
      print('코인 정보를 불러오지 못했습니다.');
    }
  }

  Future<void> _purchaseItem(String itemName, int itemCost) async {
    if (currentCoins < itemCost) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('구매 불가', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          content: Text('코인이 부족합니다', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
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
      print('구매 불가');
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('구매 불가', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          content: Text('코인이 부족합니다', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('확인', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
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
        title: Text('기프티콘', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
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
              style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 20, fontWeight: FontWeight.bold)
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
        ? Center(child: Text('보유한 상품이 없습니다.', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)))
        : ListView.builder(
      itemCount: purchasedItems.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(purchasedItems[index], style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
        );
      },
    );
  }

  Widget _buildPurchaseOptions() {
    return ListView(
      children: [
        ListTile(
          leading: Image.asset('assets/images/banana_milk.jpg'),
          title: Text('바나나 우유', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          subtitle: Text('Cost: 10 Coins', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('바나나 우유', 10),
            child: Text('구매하기', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          ),
        ),
        ListTile(
          leading: Image.asset('assets/images/pepero.jpg'),
          title: Text('빼빼로', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          subtitle: Text('Cost: 5 Coins', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('빼빼로', 5),
            child: Text('구매하기', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          ),
        ),
        ListTile(
          leading: Image.asset('assets/images/cultureland_10000.jpg'),
          title: Text('문화상품권 10000₩', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          subtitle: Text('Cost: 50 Coins', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          trailing: ElevatedButton(
            onPressed: () => _purchaseItem('문화상품권 10000₩', 50),
            child: Text('구매하기', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            setState(() {
              showPurchaseOptions = false;
            });
          },
          child: Text('Back to Purchased Items', style: TextStyle(fontFamily: 'Jua-Regular', fontSize: 16,)),
        ),
      ],
    );
  }
}
