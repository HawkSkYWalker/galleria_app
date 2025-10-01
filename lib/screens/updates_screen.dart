import 'package:flutter/material.dart';
import '../models/event_models.dart';
import '../services/event_service.dart';
import 'package:intl/intl.dart';

class UpdatesScreen extends StatefulWidget {
  const UpdatesScreen({super.key});

  @override
  State<UpdatesScreen> createState() => _UpdatesScreenState();
}

class _UpdatesScreenState extends State<UpdatesScreen> {
  final UpdateService _updateService = UpdateService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('อัปเดต', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.pink,
      ),
      body: StreamBuilder<List<GameUpdate>>(
        stream: _updateService.getAllUpdates(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('เกิดข้อผิดพลาด: ${snapshot.error}'));
          }

          final updates = snapshot.data ?? [];
          
          if (updates.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.update, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('ยังไม่มีอัปเดต'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: updates.length,
            itemBuilder: (context, index) => _buildUpdateCard(updates[index]),
          );
        },
      ),
    );
  }

  // Replace the problematic sections in your _buildUpdateCard method:

Widget _buildUpdateCard(GameUpdate update) {
  return Card(
    margin: const EdgeInsets.only(bottom: 16),
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    child: InkWell(
      onTap: () => _showUpdateDetail(update),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (update.imageUrl.isNotEmpty)
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: Image.network(
                update.imageUrl,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 160,
                  color: Colors.grey[300],
                  child: const Icon(Icons.update, size: 60, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getUpdateTypeColor(update.type),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        update.version,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.grey[600],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _getUpdateTypeText(update.type),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  update.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  update.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      DateFormat('dd/MM/yyyy').format(update.releaseDate),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                // Add null safety checks here
                if (update.newFeatures.isNotEmpty || update.newCharacters.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (update.newFeatures.isNotEmpty) ...[
                        Icon(Icons.new_releases, size: 16, color: Colors.green),
                        const SizedBox(width: 4),
                        Text(
                          '${update.newFeatures.length} ฟีเจอร์ใหม่',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ],
                      if (update.newFeatures.isNotEmpty && update.newCharacters.isNotEmpty)
                        const SizedBox(width: 12),
                      if (update.newCharacters.isNotEmpty) ...[
                        Icon(Icons.person_add, size: 16, color: Colors.blue),
                        const SizedBox(width: 4),
                        Text(
                          '${update.newCharacters.length} ตัวละครใหม่',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

  Color _getUpdateTypeColor(UpdateType type) {
    switch (type) {
      case UpdateType.major:
        return Colors.red;
      case UpdateType.minor:
        return Colors.blue;
      case UpdateType.hotfix:
        return Colors.orange;
      case UpdateType.maintenance:
        return Colors.grey;
    }
  }

  String _getUpdateTypeText(UpdateType type) {
    switch (type) {
      case UpdateType.major:
        return 'อัปเดตใหญ่';
      case UpdateType.minor:
        return 'อัปเดตเล็ก';
      case UpdateType.hotfix:
        return 'แก้ไขด่วน';
      case UpdateType.maintenance:
        return 'บำรุงรักษา';
    }
  }

  void _showUpdateDetail(GameUpdate update) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UpdateDetailModal(update: update),
    );
  }
}

class UpdateDetailModal extends StatelessWidget {
  final GameUpdate update;

  const UpdateDetailModal({super.key, required this.update});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            height: 4,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (update.imageUrl.isNotEmpty)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        update.imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.update, size: 60, color: Colors.grey),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _getUpdateTypeColor(update.type),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          update.version,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[600],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          _getUpdateTypeText(update.type),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    update.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'วันที่ปล่อย: ${DateFormat('dd MMM yyyy').format(update.releaseDate)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'รายละเอียด',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    update.description,
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                  if (update.newFeatures.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'ฟีเจอร์ใหม่',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...update.newFeatures.map((feature) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.new_releases, color: Colors.green, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(feature)),
                        ],
                      ),
                    )).toList(),
                  ],
                  if (update.newCharacters.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'ตัวละครใหม่',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...update.newCharacters.map((character) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.person_add, color: Colors.blue, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(character)),
                        ],
                      ),
                    )).toList(),
                  ],
                  if (update.bugFixes.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'แก้ไขบัก',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...update.bugFixes.map((fix) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.bug_report, color: Colors.orange, size: 16),
                          const SizedBox(width: 8),
                          Expanded(child: Text(fix)),
                        ],
                      ),
                    )).toList(),
                  ],
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.pink,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: const Text(
                        'ปิด',
                        style: TextStyle(fontSize: 18, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getUpdateTypeColor(UpdateType type) {
    switch (type) {
      case UpdateType.major:
        return Colors.red;
      case UpdateType.minor:
        return Colors.blue;
      case UpdateType.hotfix:
        return Colors.orange;
      case UpdateType.maintenance:
        return Colors.grey;
    }
  }

  String _getUpdateTypeText(UpdateType type) {
    switch (type) {
      case UpdateType.major:
        return 'อัปเดตใหญ่';
      case UpdateType.minor:
        return 'อัปเดตเล็ก';
      case UpdateType.hotfix:
        return 'แก้ไขด่วน';
      case UpdateType.maintenance:
        return 'บำรุงรักษา';
    }
  }
}