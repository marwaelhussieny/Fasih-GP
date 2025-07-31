// lib/core/services/seed_data_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:grad_project/features/home/domain/entities/lesson_entity.dart';
import 'package:grad_project/features/home/domain/entities/lesson_activity_entity.dart';

class SeedDataService {
  final FirebaseFirestore _firestore;

  SeedDataService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> initializeLessons() async {
    final lessonsCollection = _firestore.collection('lessons');

    try {
      // Check if the lessons collection is empty
      final querySnapshot = await lessonsCollection.limit(1).get();
      if (querySnapshot.docs.isNotEmpty) {
        print('Lessons collection already contains data. Skipping seed.');
        return; // Collection is not empty, no need to seed
      }

      print('Lessons collection is empty. Seeding initial data...');

      final List<Map<String, dynamic>> lessonsData = [
        {
          "id": "lesson_1_id",
          "title": "بداية رحلة التعلم و الأساسيات",
          "description": "تعلم أساسيات اللغة العربية",
          "order": 1,
          "isCompleted": false,
          "activities": [
            {
              "id": "activity_1_1_quiz",
              "title": "اختبار المفردات",
              "type": "quiz",
              "isCompleted": false,
              "associatedRoute": "/quiz",
              "associatedDataId": "quiz_id_1"
            },
            {
              "id": "activity_1_2_writing",
              "title": "تمرين الكتابة",
              "type": "writing",
              "isCompleted": false,
              "associatedRoute": "/writing",
              "associatedDataId": "writing_id_1"
            },
            {
              "id": "activity_1_3_speaking",
              "title": "تمرين التحدث",
              "type": "speaking",
              "isCompleted": false,
              "associatedRoute": "/speaking",
              "associatedDataId": "speaking_id_1"
            }
          ]
        },
        {
          "id": "lesson_2_id",
          "title": "همزة الوصل والقطع",
          "description": "فهم قواعد الهمزات",
          "order": 2,
          "isCompleted": false,
          "activities": [
            {
              "id": "activity_2_1_quiz",
              "title": "اختبار الهمزات",
              "type": "quiz",
              "isCompleted": false,
              "associatedRoute": "/quiz",
              "associatedDataId": "quiz_id_2"
            },
            {
              "id": "activity_2_2_grammar",
              "title": "قاعدة إعراب",
              "type": "grammar",
              "isCompleted": false,
              "associatedRoute": "/grammar",
              "associatedDataId": "grammar_id_1"
            }
          ]
        },
        {
          "id": "lesson_3_id",
          "title": "أنواع الجمل",
          "description": "تعرف على الجمل الاسمية والفعلية",
          "order": 3,
          "isCompleted": false,
          "activities": [
            {
              "id": "activity_3_1_quiz",
              "title": "اختبار الجمل",
              "type": "quiz",
              "isCompleted": false,
              "associatedRoute": "/quiz",
              "associatedDataId": "quiz_id_3"
            },
            {
              "id": "activity_3_2_writing",
              "title": "تكوين جمل",
              "type": "writing",
              "isCompleted": false,
              "associatedRoute": "/writing",
              "associatedDataId": "writing_id_2"
            }
          ]
        },
        {
          "id": "lesson_4_id",
          "title": "الفعل الماضي والمضارع",
          "description": "تصريف الأفعال",
          "order": 4,
          "isCompleted": false,
          "activities": [
            {
              "id": "activity_4_1_quiz",
              "title": "اختبار تصريف الأفعال",
              "type": "quiz",
              "isCompleted": false,
              "associatedRoute": "/quiz",
              "associatedDataId": "quiz_id_4"
            },
            {
              "id": "activity_4_2_speaking",
              "title": "قراءة نصوص",
              "type": "speaking",
              "isCompleted": false,
              "associatedRoute": "/speaking",
              "associatedDataId": "speaking_id_2"
            }
          ]
        }
      ];

      final batch = _firestore.batch();
      for (var lessonMap in lessonsData) {
        final docId = lessonMap['id'];
        final docRef = lessonsCollection.doc(docId);
        final dataToSet = Map<String, dynamic>.from(lessonMap)..remove('id');
        batch.set(docRef, dataToSet);
      }

      await batch.commit();
      print('Initial lesson data seeded successfully!');
    } catch (e) {
      print('Error seeding initial lesson data: $e');
      // Re-throw to be handled by the caller (e.g., HomeProvider)
      throw Exception('Failed to seed initial lessons: $e');
    }
  }
}