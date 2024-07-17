import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';
import 'user_screen.dart';
import 'camera_screen.dart';
import 'exchange_screen.dart';
import 'chart_screen.dart';  // chart_screen.dart를 import
import 'google_map_screen.dart';  // google_map_screen.dart를 import

class HomeScreen extends StatefulWidget {
  final String login_method;
  final String token;

  HomeScreen({required this.login_method, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  String profileImageUrl = '';
  late Future<void> _loadProfileDataFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileDataFuture = _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url') ?? '';
    });
  }

  late List<Widget> _widgetOptions = [];

  void _initializeWidgetOptions() {
    _widgetOptions = <Widget>[
      GoogleMapScreen(),  // 구글 맵 위젯 추가
      CameraScreen(token: widget.token),  // token 전달
      UserScreen(token: widget.token, profileImageUrl: profileImageUrl, loginMethod: widget.login_method),
      TimeSeriesChart(token: widget.token),  // 차트 위젯에 token 전달
      ExchangeScreen(token: widget.token), // 기프티콘(ExchangeScreen) 위젯 추가
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadProfileDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          _initializeWidgetOptions();
          return Scaffold(
            appBar: AppBar(
              title: Text('CashTrash', style: TextStyle(fontFamily: 'Jua-Regular',)),
            ),
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: 'Camera',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Chart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Exchange',
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xFF50C878),
              unselectedItemColor: Colors.grey,  // 기본값으로 회색으로 설정
              onTap: _onItemTapped,
            ),
          );
        } else {
          return Center(child: Text('Error loading profile data', style: TextStyle(fontFamily: 'Jua-Regular',)));
        }
      },
    );
  }
}
