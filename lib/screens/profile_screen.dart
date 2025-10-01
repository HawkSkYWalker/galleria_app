import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'hawkskywalker',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  'https://www.giantbomb.com/a/uploads/scale_medium/34/343619/3008232-5011171718-cd29a.png',
                ),
              ),
            ),
            const SizedBox(height: 24),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.symmetric(horizontal: 32),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.blueGrey[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Nice to meet you, Lets have fun!.',
                style: TextStyle(fontSize: 16, color: Colors.black87),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            const Divider(
              thickness: 2,
              indent: 32,
              endIndent: 32,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Trainees',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
            ),
            const Divider(
              thickness: 2,
              indent: 32,
              endIndent: 32,
            ),
            _profileRow(
              imageUrl: 'https://static.wikia.nocookie.net/umamusume/images/a/a3/Dream_Journey_%28Main%29.png/revision/latest?cb=20240731182621',
              description: 'Dream Journey',
            ),
            const SizedBox(height: 16),
            _profileRow(
              imageUrl: 'https://static.wikia.nocookie.net/umamusume/images/f/fd/Kitasan_Black_%28Main%29.png/revision/latest?cb=20240731191210',
              description: 'Kitasan Black',
            ),
            const SizedBox(height: 16),
            _profileRow(
              imageUrl: 'https://static.wikia.nocookie.net/umamusume/images/d/dc/Satono_Diamond_%28Main%29.png/revision/latest?cb=20240731202024',
              description: 'Satono Diamond',
            ),
            const SizedBox(height: 16),
            _profileRow(
              imageUrl: 'https://static.wikia.nocookie.net/umamusume/images/2/26/Rice_Shower_%28Main%29.png/revision/latest?cb=20240731194837',
              description: 'Rice Shower',
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _profileRow({required String imageUrl, required String description}) {
    return Container(
      height: 180,
      width: double.infinity,
      color: Colors.green[200],
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                height: double.infinity,
                width: double.infinity,
              ),
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            flex: 5,
            child: Text(
              description,
              style: const TextStyle(fontSize: 18, color: Colors.black),
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}