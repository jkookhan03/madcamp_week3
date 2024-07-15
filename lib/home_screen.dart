import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'user_screen.dart';
import 'camera_screen.dart';
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
              ],
              currentIndex: _selectedIndex,
              selectedItemColor: Colors.blue,
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
