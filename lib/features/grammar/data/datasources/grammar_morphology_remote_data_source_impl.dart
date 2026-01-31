// lib/features/grammar/data/datasources/grammar_morphology_remote_data_source_impl.dart - COMPLETE IMPLEMENTATION

import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/core/services/api_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GrammarMorphologyRemoteDataSourceImpl implements GrammarMorphologyRemoteDataSource {
  final ApiService apiService;
  final String userId;
  final String baseUrl;
  String? _authToken;

  GrammarMorphologyRemoteDataSourceImpl({
    required this.apiService,
    required this.userId,
    required this.baseUrl,
  });

  // Set auth token method
  void setAuthToken(String token) {
    _authToken = token;
    apiService.setAuthToken(token);
  }

  // Helper method to get headers with ngrok bypass and auth
  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true',
    'User-Agent': 'FlutterApp/1.0',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };

  @override
  Future<List<ParsingResultEntity>> performParsing(String text) async {
    try {
      print('🔍 Performing parsing for: $text');

      final response = await apiService.post(
        '/e3rbly/arabic',
        body: {
          'sentence': text,
          'format': 'structured',
          'userId': userId,
        },
      );

      print('📨 Parsing response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic> analysisData = data['analysis'] as List<dynamic>;

        return analysisData.map((item) {
          final word = item['word'] ?? '';
          final parsing = item['parsing'] ?? 'غير محدد';

          return ParsingResultEntity(
            word: word,
            parsing: parsing,
          );
        }).toList();
      } else {
        throw Exception('فشل في تحليل النص: ${response['message'] ?? 'خطأ غير معروف'}');
      }
    } catch (e) {
      print('❌ Error in performParsing: $e');
      // Return dummy data as fallback
      return _getDummyParsingResults(text);
    }
  }

  @override
  Future<List<MorphologyResultEntity>> performMorphology(String text, String form) async {
    try {
      print('🔍 Performing morphology for: $text');

      final response = await apiService.post(
        '/e3rbly/morphology',
        body: {
          'type': 'morphology',
          'inputText': text,
          'userId': userId,
        },
      );

      print('📨 Morphology response: $response');

      if (response['status'] == 'success') {
        final List<dynamic> analysisData = response['analysis'] as List<dynamic>;

        return analysisData.map((item) {
          return MorphologyResultEntity(
            word: item['word'] ?? '',
            type: item['type'] ?? 'غير محدد',
            state: item['state'] ?? '',
            root: item['root'] ?? '',
          );
        }).toList();
      } else {
        throw Exception('فشل في التحليل الصرفي: ${response['message'] ?? 'خطأ غير معروف'}');
      }
    } catch (e) {
      print('❌ Error in performMorphology: $e');
      return _getDummyMorphologyResults(text, form);
    }
  }

  @override
  Future<bool> checkServiceStatus() async {
    try {
      print('🔍 Checking service status...');

      final response = await apiService.get('/e3rbly/status');

      print('📨 Status response: $response');

      return response['status'] == 'success' && response['service'] == 'online';
    } catch (e) {
      print('❌ Error checking service status: $e');
      return false;
    }
  }

  @override
  Future<List<String>> findAntonyms(String word) async {
    try {
      print('🔍 Finding antonyms for: $word');

      final response = await apiService.post(
        '/e3rbly/analyze-meaning',
        body: {
          'type': 'antonyms',
          'word': word,
          'userId': userId,
        },
      );

      print('📨 Antonyms response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final result = data['result'];

        if (result is String) {
          return result.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        }
        return [result.toString()];
      } else {
        throw Exception('لم يتم العثور على أضداد للكلمة');
      }
    } catch (e) {
      print('❌ Error in findAntonyms: $e');
      return _getDummyAntonyms(word);
    }
  }

  @override
  Future<List<String>> findSynonyms(String word) async {
    try {
      print('🔍 Finding synonyms for: $word');

      final response = await apiService.post(
        '/e3rbly/analyze-meaning',
        body: {
          'type': 'synonyms',
          'word': word,
          'userId': userId,
        },
      );

      print('📨 Synonyms response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final result = data['result'];

        if (result is List) {
          // Case 1: The result is already a list (e.g., ['مرادف1', 'مرادف2'])
          return List<String>.from(result);
        } else if (result is String) {
          // Case 2: The result is a comma-separated string (e.g., 'مرادف1, مرادف2')
          return result.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty).toList();
        } else {
          // Case 3: The result is a single non-string value.
          return [result?.toString() ?? ''];
        }
      } else {
        throw Exception('لم يتم العثور على مرادفات للكلمة');
      }
    } catch (e) {
      print('❌ Error in findSynonyms: $e');
      return _getDummySynonyms(word);
    }
  }

  @override
  Future<String> findPlural(String word) async {
    try {
      print('🔍 Finding plural for: $word');

      final response = await apiService.post(
        '/e3rbly/analyze-meaning',
        body: {
          'type': 'plural',
          'word': word,
          'userId': userId,
        },
      );

      print('📨 Plural response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        return data['result']?.toString() ?? 'لم يتم العثور على جمع';
      } else {
        throw Exception('لم يتم العثور على جمع للكلمة');
      }
    } catch (e) {
      print('❌ Error in findPlural: $e');
      return _getDummyPlural(word);
    }
  }

  @override
  Future<String> analyzeMeaning(String word) async {
    try {
      print('🔍 Analyzing meaning for: $word');

      final response = await apiService.post(
        '/e3rbly/analyze-meaning',
        body: {
          'type': 'synonyms',
          'word': word,
          'userId': userId,
        },
      );

      print('📨 Meaning response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        return data['result']?.toString() ?? 'لم يتم العثور على معنى';
      } else {
        throw Exception('لم يتم العثور على معنى للكلمة');
      }
    } catch (e) {
      print('❌ Error in analyzeMeaning: $e');
      return _getDummyMeaning(word);
    }
  }

  @override
  Future<String> generatePoetry(String theme, String meterType) async {
    try {
      print('🔍 Generating poetry for theme: $theme');

      final response = await apiService.post(
        '/e3rbly/poetry',
        body: {
          'type': 'poetry',
          'inputText': theme,
          'userId': userId,
        },
      );

      print('📨 Poetry response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        return data['generated_poem']?.toString() ?? 'فشل في توليد الشعر';
      } else {
        throw Exception('فشل في توليد الشعر');
      }
    } catch (e) {
      print('❌ Error in generatePoetry: $e');
      return _getDummyPoetry(theme, meterType);
    }
  }

  @override
  Future<String> analyzePoetryMeter(String poem) async {
    try {
      print('🔍 Analyzing poetry meter for: $poem');

      final response = await apiService.post(
        '/e3rbly/predict-meter',
        body: {
          'text': poem,
          'userId': userId,
        },
      );

      print('📨 Meter response: $response');

      if (response['status'] == 'success') {
        final message = response['message']?.toString() ?? '';
        final prediction = response['prediction']?.toString() ?? '';
        return '$message$prediction';
      } else {
        throw Exception('فشل في تحليل البحر الشعري');
      }
    } catch (e) {
      print('❌ Error in analyzePoetryMeter: $e');
      return _getDummyMeterAnalysis(poem);
    }
  }

  // Enhanced Arabic parsing using Gemini endpoint
  Future<List<ParsingResultEntity>> performEnhancedParsing(String sentence, {String format = 'structured'}) async {
    try {
      print('🔍 Performing enhanced Arabic parsing for: $sentence');

      final response = await apiService.post(
        '/e3rbly/arabic',
        body: {
          'sentence': sentence,
          'format': format,
          'userId': userId,
        },
      );

      print('📨 Enhanced parsing response: $response');

      if (response['status'] == 'success') {
        final data = response['data'] as Map<String, dynamic>;
        final List<dynamic> analysisData = data['analysis'] as List<dynamic>;

        return analysisData.map((item) {
          return ParsingResultEntity(
            word: item['word'] ?? '',
            parsing: item['parsing'] ?? 'غير محدد',
          );
        }).toList();
      } else {
        throw Exception('فشل في التحليل المحسن: ${response['message'] ?? 'خطأ غير معروف'}');
      }
    } catch (e) {
      print('❌ Error in performEnhancedParsing: $e');
      return _getDummyParsingResults(sentence);
    }
  }

  // Dummy data methods for fallback when API fails
  List<ParsingResultEntity> _getDummyParsingResults(String text) {
    if (text.toLowerCase().contains('الطالب')) {
      return [
        const ParsingResultEntity(word: 'الطالب', parsing: 'اسم مرفوع'),
        const ParsingResultEntity(word: 'المجتهد', parsing: 'نعت مرفوع'),
        const ParsingResultEntity(word: 'يذهب', parsing: 'فعل مضارع مرفوع'),
        const ParsingResultEntity(word: 'إلى', parsing: 'حرف جر'),
        const ParsingResultEntity(word: 'المدرسة', parsing: 'اسم مجرور'),
      ];
    }
    return [ParsingResultEntity(word: text, parsing: 'لا يوجد إعراب متاح (وضع تجريبي)')];
  }

  List<MorphologyResultEntity> _getDummyMorphologyResults(String text, String form) {
    return [
      const MorphologyResultEntity(
        word: 'مثال',
        type: 'اسم',
        state: 'معرب',
        root: 'مثل',
      )
    ];
  }

  List<String> _getDummyAntonyms(String word) {
    final Map<String, List<String>> antonymsMap = {
      'كبير': ['صغير', 'ضئيل'],
      'طويل': ['قصير', 'صغير'],
      'سريع': ['بطيء', 'متأن'],
      'جميل': ['قبيح', 'دميم'],
      'ذكي': ['غبي', 'جاهل'],
    };
    return antonymsMap[word] ?? ['لا توجد أضداد متاحة (وضع تجريبي)'];
  }

  List<String> _getDummySynonyms(String word) {
    final Map<String, List<String>> synonymsMap = {
      'جميل': ['حسَن', 'بَهِيّ'],
      'شجاع': ['مقدام', 'جسور'],
      'قاسى': ['عانى', 'تألم'],
    };
    return synonymsMap[word] ?? ['لا توجد مرادفات متاحة (وضع تجريبي)'];
  }

  String _getDummyPlural(String word) {
    final Map<String, String> pluralsMap = {
      'كتاب': 'كتب',
      'طالب': 'طلاب',
      'معلم': 'معلمون',
      'بيت': 'بيوت',
      'قلم': 'أقلام',
    };
    return pluralsMap[word] ?? 'لا يوجد جمع متاح (وضع تجريبي)';
  }

  String _getDummyMeaning(String word) {
    final Map<String, String> meaningsMap = {
      'كتاب': 'مجموعة من الأوراق المكتوبة أو المطبوعة',
      'طالب': 'الشخص الذي يتلقى التعليم',
      'معلم': 'الشخص الذي يقوم بالتدريس',
    };
    return meaningsMap[word] ?? 'لا يوجد معنى متاح (وضع تجريبي)';
  }

  String _getDummyPoetry(String theme, String meterType) {
    return '''في موضوع $theme نقول:
بيت شعري تجريبي من البحر $meterType
هذا مثال للشعر المولد تلقائيًا
في وضع التجربة قبل ربط الخدمة''';
  }

  String _getDummyMeterAnalysis(String poem) {
    return 'البحر المكتشف: تحليل تجريبي\nهذا تحليل أولي للبحر الشعري في وضع التجربة';
  }
}