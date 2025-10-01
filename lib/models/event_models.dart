import 'package:cloud_firestore/cloud_firestore.dart';

class GameEvent {
  final String id;
  final String name;
  final String description;
  final DateTime startDate;
  final DateTime endDate;
  final String imageUrl;
  final EventType type;
  final List<String> rewards;
  final bool isActive;
  final Map<String, dynamic> requirements;

  GameEvent({
    required this.id,
    required this.name,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.imageUrl,
    required this.type,
    required this.rewards,
    required this.isActive,
    required this.requirements,
  });

  factory GameEvent.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GameEvent(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: (data['endDate'] as Timestamp).toDate(),
      imageUrl: data['imageUrl'] ?? '',
      type: EventType.values.firstWhere(
        (e) => e.toString() == 'EventType.${data['type']}',
        orElse: () => EventType.campaign,
      ),
      rewards: List<String>.from(data['rewards'] ?? []),
      isActive: data['isActive'] ?? false,
      requirements: Map<String, dynamic>.from(data['requirements'] ?? {}),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
      'rewards': rewards,
      'isActive': isActive,
      'requirements': requirements,
    };
  }
}

class GameUpdate {
  final String id;
  final String version;
  final String title;
  final String description;
  final DateTime releaseDate;
  final List<String> newFeatures;
  final List<String> bugFixes;
  final List<String> newCharacters;
  final String imageUrl;
  final UpdateType type;

  GameUpdate({
    required this.id,
    required this.version,
    required this.title,
    required this.description,
    required this.releaseDate,
    required this.newFeatures,
    required this.bugFixes,
    required this.newCharacters,
    required this.imageUrl,
    required this.type,
  });

  factory GameUpdate.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return GameUpdate(
      id: doc.id,
      version: data['version'] ?? '',
      title: data['title'] ?? '',
      description: data['description'] ?? '',
      releaseDate: (data['releaseDate'] as Timestamp).toDate(),
      newFeatures: List<String>.from(data['newFeatures'] ?? []),
      bugFixes: List<String>.from(data['bugFixes'] ?? []),
      newCharacters: List<String>.from(data['newCharacters'] ?? []),
      imageUrl: data['imageUrl'] ?? '',
      type: UpdateType.values.firstWhere(
        (e) => e.toString() == 'UpdateType.${data['type']}',
        orElse: () => UpdateType.minor,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'version': version,
      'title': title,
      'description': description,
      'releaseDate': Timestamp.fromDate(releaseDate),
      'newFeatures': newFeatures,
      'bugFixes': bugFixes,
      'newCharacters': newCharacters,
      'imageUrl': imageUrl,
      'type': type.toString().split('.').last,
    };
  }
}

enum EventType {
  campaign,
  race,
  training,
  gacha,
  collaboration,
}

enum UpdateType {
  major,
  minor,
  hotfix,
  maintenance,
}

