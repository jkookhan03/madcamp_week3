import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'user_screen.dart';
import 'camera_screen.dart';
import 'exchange_screen.dart';
import 'chart_screen.dart';  // chart_screen.dart를 import
import 'google_map_screen.dart';  // google_map_screen.dart를 import
import 'package:shared_preferences/shared_preferences.dart';

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
  late Future<void> _loadProfileImageFuture;

  @override
  void initState() {
    super.initState();
    _loadProfileImageFuture = _loadProfileImage();
  }

  Future<void> _loadProfileImage() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      profileImageUrl = prefs.getString('profile_image_url') ?? '';
    });
  }

  late List<Widget> _widgetOptions = [];

  void _initializeWidgetOptions() {
    _widgetOptions = <Widget>[
      Text(
        'Home Tab Content',
        style: TextStyle(fontSize: 24),
      ),
      UserScreen(token: widget.token, profileImageUrl: profileImageUrl, loginMethod: widget.login_method),
      CameraScreen(),
      ExchangeScreen(token: widget.token),
      TimeSeriesChart(),  // 차트 위젯 추가
      GoogleMapScreen(),  // 구글 맵 위젯 추가
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
      future: _loadProfileImageFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.connectionState == ConnectionState.done) {
          _initializeWidgetOptions();
          return Scaffold(
            appBar: AppBar(
              title: Text('Home Screen with Tabs'),
            ),
            body: Center(
              child: _widgetOptions.elementAt(_selectedIndex),
            ),
            bottomNavigationBar: BottomNavigationBar(
              items: const <BottomNavigationBarItem>[
                BottomNavigationBarItem(
                  icon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.person),
                  label: 'User',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.camera),
                  label: 'Camera',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.shopping_cart),
                  label: 'Exchange',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.show_chart),
                  label: 'Chart',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: 'Map',  // 구글 맵 탭 추가
                ),
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Color(0xFF50C878),
              unselectedItemColor: Colors.grey,  // 기본값으로 회색으로 설정
              onTap: _onItemTapped,
            ),
          );
        } else {
          return Center(child: Text('Error loading profile image'));
        }
      },
    );
  }
}
