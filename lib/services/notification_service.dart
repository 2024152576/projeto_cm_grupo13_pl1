import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../models/review_model.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  StreamSubscription<QuerySnapshot<Map<String, dynamic>>>? _reviewSub;
  final Set<String> _knownReviewIds = {};
  bool _initialized = false;
  bool _initialLoad = true;
  String? _currentUserId;

  Future<void> initialize() async {
    if (kIsWeb || _initialized) return;

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      await _plugin.initialize(
        const InitializationSettings(
          android: androidSettings,
          iOS: iosSettings,
        ),
      );

      final androidPlugin =
          _plugin.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();
      await androidPlugin?.requestNotificationsPermission();

      _initialized = true;
    } catch (_) {

    }
  }

  Future<void> startListening(String? currentUserId) async {
    if (kIsWeb || currentUserId == null) return;

    try {
      await initialize();
      await stopListening();

      _currentUserId = currentUserId;
      _initialLoad = true;
      _knownReviewIds.clear();

      _reviewSub = _db
          .collection('reviews')
          .orderBy('timestamp', descending: true)
          .snapshots()
          .listen(_onReviewsUpdate);
    } catch (_) {

    }
  }

  void _onReviewsUpdate(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (_currentUserId == null) return;

    if (_initialLoad) {
      for (final doc in snapshot.docs) {
        _knownReviewIds.add(doc.id);
      }
      _initialLoad = false;
      return;
    }

    for (final change in snapshot.docChanges) {
      if (change.type != DocumentChangeType.added) continue;

      final data = change.doc.data();
      if (data == null) continue;

      final review = ReviewModel.fromMap(data);
      if (review.userId == _currentUserId) continue;
      if (_knownReviewIds.contains(review.reviewId)) continue;

      _knownReviewIds.add(review.reviewId);
      _showNewReviewNotification(review);
    }
  }

  Future<void> _showNewReviewNotification(ReviewModel review) async {
    const androidDetails = AndroidNotificationDetails(
      'decibel_reviews',
      'Novas Reviews',
      channelDescription: 'Avisos quando outros utilizadores publicam reviews',
      importance: Importance.high,
      priority: Priority.high,
    );

    const iosDetails = DarwinNotificationDetails();

    await _plugin.show(
      review.reviewId.hashCode,
      'Nova Review',
      '${review.userName} adicionou uma review',
      const NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      ),
    );
  }

  Future<void> stopListening() async {
    await _reviewSub?.cancel();
    _reviewSub = null;
    _currentUserId = null;
    _initialLoad = true;
    _knownReviewIds.clear();
  }
}
