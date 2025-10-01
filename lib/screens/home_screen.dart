import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:galleria_app/screens/profile_screen.dart';
import '../constant/app_constant.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:galleria_app/screens/events_screen.dart';
import 'package:galleria_app/screens/updates_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pageIndex = 0;
  final List<Widget> _pages = [
    FeedScreen(),
    Center(child: Text('Search Page', style: headingTextStyle)),
    Center(child: Text('Notifications Page', style: headingTextStyle)),
    ProfileScreen(),
    const EventsScreen(),      // Add this
    const UpdatesScreen()     // Add this 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Umamusume Trainer Guide', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFFF69B4), Color(0xFFFFB6C1)], // Hot pink to light pink
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFF8FFAE), Color(0xFF43E97B), Color(0xFF38F9D7)],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: _pages[_pageIndex],
        ),
        bottomNavigationBar: CurvedNavigationBar(
          backgroundColor: Colors.transparent,
          color: primaryColor,
          items: [
            Icon(Icons.home, size: 30, color: secondaryColor),
            Icon(Icons.search, size: 30, color: secondaryColor),
            Icon(Icons.notifications, size: 30, color: secondaryColor),
            Icon(Icons.person, size: 30, color: secondaryColor),
            Icon(Icons.event, size: 30, color: secondaryColor),   // For EventsScreen
            Icon(Icons.update, size: 30, color: secondaryColor),  // For UpdatesScreen
],
          onTap: (index) {
            setState(() {
              _pageIndex = index;
            });
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF43E97B),
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            // Add your action here
          },
        ),
    );
  }
}

// Instagram-like feed widget
class FeedScreen extends StatelessWidget {
  final List<Map<String, String>> posts = const [
    {
      'image': 'https://static.wikia.nocookie.net/umamusume/images/2/2a/Matikanetannhauser_%28Main%29.png/revision/latest?cb=20240731192543',
      'text': 'How to build mambo.',
    },
    {
      'image': 'https://static.wikia.nocookie.net/umamusume/images/a/a3/Dream_Journey_%28Main%29.png/revision/latest?cb=20240731182621',
      'text': 'How to build Dream Journey.',
    },
    {
      'image': 'https://static.wikia.nocookie.net/umamusume/images/f/fd/Kitasan_Black_%28Main%29.png/revision/latest?cb=20240731191210',
      'text': 'How to build Kitasan Black.',
    },
    {
      'image': 'https://static.wikia.nocookie.net/umamusume/images/d/dc/Satono_Diamond_%28Main%29.png/revision/latest?cb=20240731202024',
      'text': 'How to build Satobo Diamond.',
    },
    {
      'image': 'https://static.wikia.nocookie.net/umamusume/images/2/26/Rice_Shower_%28Main%29.png/revision/latest?cb=20240731194837',
      'text': 'How to build Rice Shower.',
    },
  ];

  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double topPadding = MediaQuery.of(context).padding.top + kToolbarHeight + 16;
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(top: topPadding),
        child: Column(
          children: posts.map((post) => _feedBox(post['image']!, post['text']!)).toList(),
        ),
      ),
    );
  }

  Widget _feedBox(String imageUrl, String description) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      height: 180,
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.85),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.greenAccent.withOpacity(0.2),
              blurRadius: 16,
              offset: Offset(0, 8),
            ),
          ],
        ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16),
              bottomLeft: Radius.circular(16),
            ),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              height: 180,
              width: 120,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                description,
                style: const TextStyle(fontSize: 18, color: Colors.black),
                textAlign: TextAlign.left,
              ),
            ),
          ),
        ],
      ),
    );
  }
}