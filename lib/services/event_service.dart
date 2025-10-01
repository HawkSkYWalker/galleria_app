import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/event_models.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get all events
  Stream<List<GameEvent>> getAllEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameEvent.fromFirestore(doc))
            .toList());
  }

  // Get active events only - FIXED: Removed compound query limitations
  Stream<List<GameEvent>> getActiveEvents() {
    return _firestore
        .collection('events')
        .where('isActive', isEqualTo: true)
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => GameEvent.fromFirestore(doc))
              .where((event) => 
                event.startDate.isBefore(now) || event.startDate.isAtSameMomentAs(now))
              .where((event) => 
                event.endDate.isAfter(now) || event.endDate.isAtSameMomentAs(now))
              .toList();
        });
  }

  // Get completed events
  Stream<List<GameEvent>> getCompletedEvents() {
    return _firestore
        .collection('events')
        .orderBy('endDate', descending: true)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => GameEvent.fromFirestore(doc))
              .where((event) => event.endDate.isBefore(now))
              .toList();
        });
  }

  // Get upcoming events
  Stream<List<GameEvent>> getUpcomingEvents() {
    return _firestore
        .collection('events')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
          final now = DateTime.now();
          return snapshot.docs
              .map((doc) => GameEvent.fromFirestore(doc))
              .where((event) => event.startDate.isAfter(now))
              .toList();
        });
  }

  // Get events by type
  Stream<List<GameEvent>> getEventsByType(EventType type) {
    return _firestore
        .collection('events')
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameEvent.fromFirestore(doc))
            .toList());
  }

  // Add new event (admin only)
  Future<void> addEvent(GameEvent event) async {
    try {
      await _firestore.collection('events').add(event.toMap());
    } catch (e) {
      throw Exception('Failed to add event: $e');
    }
  }

  // Update event
  Future<void> updateEvent(String eventId, GameEvent event) async {
    try {
      await _firestore.collection('events').doc(eventId).update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update event: $e');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore.collection('events').doc(eventId).delete();
    } catch (e) {
      throw Exception('Failed to delete event: $e');
    }
  }

  // Track user event participation
  Future<void> trackEventParticipation(String eventId, Map<String, dynamic> progressData) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('eventProgress')
          .doc(eventId)
          .set({
        'eventId': eventId,
        'progress': progressData,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to track event participation: $e');
    }
  }

  // Get user's event progress
  Stream<Map<String, dynamic>?> getUserEventProgress(String eventId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value(null);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('eventProgress')
        .doc(eventId)
        .snapshots()
        .map((doc) => doc.exists ? doc.data() : null);
  }

  // HELPER: Add sample events to Firestore (for testing)
  Future<void> addSampleEvents() async {
    try {
      final batch = _firestore.batch();
      
      // Sample events for 2025
      final sampleEvents = [
        {
          'name': 'Summer Training Camp 2025',
          'description': 'อีเวนต์ฝึกฤดูร้อนพิเศษ เพิ่มประสบการณ์และรางวัลเพียบ!',
          'startDate': Timestamp.fromDate(DateTime(2025, 6, 1, 0, 0, 0)),
          'endDate': Timestamp.fromDate(DateTime(2025, 6, 30, 23, 59, 59)),
          'imageUrl': 'https://umamusume.com/_app/immutable/assets/kv.DlQKMfGs.png',
          'type': 'training',
          'rewards': ['Special Support Card', 'Training Points x1000'],
          'isActive': true,
          'requirements': {
            'minLevel': 10,
            'dailyMissions': 5,
          },
        },
        {
          'name': 'Autumn Festival 2025',
          'description': 'เทศกาลฤดูใบไม้ร่วงสุดพิเศษ! ท้าทายภารกิจใหม่และรับรางวัลมากมาย',
          'startDate': Timestamp.fromDate(DateTime(2025, 10, 1, 0, 0, 0)),
          'endDate': Timestamp.fromDate(DateTime(2025, 10, 31, 23, 59, 59)),
          'imageUrl': 'https://umamusume.com/_app/immutable/assets/autumn-festival.png',
          'type': 'collaboration',
          'rewards': ['Limited Edition Card Pack', 'Golden Coins x2500', 'Exclusive Avatar Frame'],
          'isActive': false,
          'requirements': {
            'minLevel': 15,
            'dailyMissions': 3,
          },
        },
        {
          'name': 'Winter Championship 2025',
          'description': 'การแข่งขันฤดูหนาวครั้งยิ่งใหญ่ พิสูจน์ความแข็งแกร่งของคุณ!',
          'startDate': Timestamp.fromDate(DateTime(2025, 12, 15, 0, 0, 0)),
          'endDate': Timestamp.fromDate(DateTime(2025, 12, 31, 23, 59, 59)),
          'imageUrl': 'https://umamusume.com/_app/immutable/assets/winter-championship.png',
          'type': 'race',
          'rewards': ['Champion Trophy', 'Rare Skill Cards x5', 'Premium Gems x3000'],
          'isActive': false,
          'requirements': {
            'minLevel': 20,
            'dailyMissions': 7,
          },
        },
        {
          'name': 'Spring Blossom Gacha 2025',
          'description': 'สุ่มการ์ดพิเศษฤดูใบไม้ผลิ รับโอกาสพิเศษในการได้การ์ดหายาก!',
          'startDate': Timestamp.fromDate(DateTime(2025, 3, 20, 0, 0, 0)),
          'endDate': Timestamp.fromDate(DateTime(2025, 4, 10, 23, 59, 59)),
          'imageUrl': 'https://umamusume.com/_app/immutable/assets/spring-gacha.png',
          'type': 'gacha',
          'rewards': ['SSR Support Card', 'Gacha Tickets x10', 'Bonus Points x500'],
          'isActive': true,
          'requirements': {
            'minLevel': 5,
            'dailyMissions': 2,
          },
        },
      ];

      for (var eventData in sampleEvents) {
        final docRef = _firestore.collection('events').doc();
        batch.set(docRef, eventData);
      }

      await batch.commit();
      print('Sample events added successfully!');
    } catch (e) {
      throw Exception('Failed to add sample events: $e');
    }
  }
}

class UpdateService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all updates
  Stream<List<GameUpdate>> getAllUpdates() {
    return _firestore
        .collection('updates')
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameUpdate.fromFirestore(doc))
            .toList());
  }

  // Get latest updates (last 10)
  Stream<List<GameUpdate>> getLatestUpdates() {
    return _firestore
        .collection('updates')
        .orderBy('releaseDate', descending: true)
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameUpdate.fromFirestore(doc))
            .toList());
  }

  // Get updates by type
  Stream<List<GameUpdate>> getUpdatesByType(UpdateType type) {
    return _firestore
        .collection('updates')
        .where('type', isEqualTo: type.toString().split('.').last)
        .orderBy('releaseDate', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => GameUpdate.fromFirestore(doc))
            .toList());
  }

  // Add new update (admin only)
  Future<void> addUpdate(GameUpdate update) async {
    try {
      await _firestore.collection('updates').add(update.toMap());
    } catch (e) {
      throw Exception('Failed to add update: $e');
    }
  }

  // Update existing update
  Future<void> updateGameUpdate(String updateId, GameUpdate update) async {
    try {
      await _firestore.collection('updates').doc(updateId).update(update.toMap());
    } catch (e) {
      throw Exception('Failed to update game update: $e');
    }
  }

  // Delete update
  Future<void> deleteUpdate(String updateId) async {
    try {
      await _firestore.collection('updates').doc(updateId).delete();
    } catch (e) {
      throw Exception('Failed to delete update: $e');
    }
  }

  // Mark update as read by user
  Future<void> markUpdateAsRead(String updateId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('readUpdates')
          .doc(updateId)
          .set({
        'updateId': updateId,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark update as read: $e');
    }
  }

  // Check if update is read by user
  Stream<bool> isUpdateRead(String updateId) {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return Stream.value(false);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('readUpdates')
        .doc(updateId)
        .snapshots()
        .map((doc) => doc.exists);
  }
}