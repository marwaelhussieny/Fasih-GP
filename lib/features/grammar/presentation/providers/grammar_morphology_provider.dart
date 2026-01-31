// lib/features/grammar/presentation/providers/grammar_morphology_provider.dart - COMPLETE E3RBLY INTEGRATION

import 'package:flutter/material.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_parsing_usecase.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_morphology_usecase.dart';
import 'package:grad_project/features/grammar/data/datasources/grammar_morphology_remote_data_source_impl.dart';

class GrammarMorphologyProvider with ChangeNotifier {
  final PerformParsingUseCase _performParsingUseCase;
  final PerformMorphologyUseCase _performMorphologyUseCase;
  final GrammarMorphologyRemoteDataSourceImpl _dataSource;

  // State variables
  List<ParsingResultEntity> _parsingResults = [];
  List<MorphologyResultEntity> _morphologyResults = [];
  bool _isLoading = false;
  String? _error;
  String? _resultMessage;
  bool _isServiceOnline = false;

  // Additional feature results
  List<String> _synonyms = [];
  List<String> _antonyms = [];
  String _plural = '';
  String _meaning = '';
  String _generatedPoetry = '';
  String _poetryMeter = '';
  PoetryGenerationEntity? _poetryEntity;
  PoetryMeterEntity? _meterEntity;

  GrammarMorphologyProvider(
      this._performParsingUseCase,
      this._performMorphologyUseCase,
      this._dataSource,
      );

  // Getters
  List<ParsingResultEntity> get parsingResults => _parsingResults;
  List<MorphologyResultEntity> get morphologyResults => _morphologyResults;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get resultMessage => _resultMessage;
  bool get isServiceOnline => _isServiceOnline;

  // Additional feature getters
  List<String> get synonyms => _synonyms;
  List<String> get antonyms => _antonyms;
  String get plural => _plural;
  String get meaning => _meaning;
  String get generatedPoetry => _generatedPoetry;
  String get poetryMeter => _poetryMeter;
  PoetryGenerationEntity? get poetryEntity => _poetryEntity;
  PoetryMeterEntity? get meterEntity => _meterEntity;

  // Set authentication token
  void setAuthToken(String token) {
    _dataSource.setAuthToken(token);
    print('🔑 Auth token set for grammar service');
  }

  // Clear authentication token
  void clearAuthToken() {
    _dataSource.setAuthToken('');
    print('🔓 Auth token cleared for grammar service');
  }

  // Set loading state
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error state
  void _setError(String? error) {
    _error = error;
    _resultMessage = null;
    notifyListeners();
  }

  // Set success state
  void _setSuccess(String message) {
    _error = null;
    _resultMessage = message;
    notifyListeners();
  }

  // Clear all results
  void clearResults() {
    _parsingResults = [];
    _morphologyResults = [];
    _synonyms = [];
    _antonyms = [];
    _plural = '';
    _meaning = '';
    _generatedPoetry = '';
    _poetryMeter = '';
    _poetryEntity = null;
    _meterEntity = null;
    _error = null;
    _resultMessage = null;
    notifyListeners();
  }

  // Check service status
  Future<void> checkServiceStatus() async {
    try {
      print('🔍 Checking service status...');
      _isServiceOnline = await _dataSource.checkServiceStatus();
      print('📊 Service status: ${_isServiceOnline ? "Online" : "Offline"}');
      notifyListeners();
    } catch (e) {
      print('❌ Error checking service status: $e');
      _isServiceOnline = false;
      notifyListeners();
    }
  }

  // Perform parsing using enhanced Gemini endpoint
  Future<void> performParsing(String text, {bool useEnhanced = true}) async {
    if (text.trim().isEmpty) {
      _setError('يرجى إدخال نص للتحليل');
      return;
    }

    try {
      _setLoading(true);
      clearResults();

      print('🔍 Starting parsing for: $text (enhanced: $useEnhanced)');

      List<ParsingResultEntity> results;
      if (useEnhanced) {
        // Use enhanced Gemini Arabic parser
        results = await _dataSource.performEnhancedParsing(text);
      } else {
        // Use regular parsing
        results = await _performParsingUseCase.call(text);
      }

      _parsingResults = results;
      _setSuccess('تم تحليل النص بنجاح - عدد الكلمات: ${results.length}');
      print('✅ Parsing completed successfully: ${results.length} words');

    } catch (e) {
      print('❌ Parsing failed: $e');
      _setError('فشل في تحليل النص: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Perform morphology analysis
  Future<void> performMorphology(String text, String form) async {
    if (text.trim().isEmpty) {
      _setError('يرجى إدخال نص للتحليل الصرفي');
      return;
    }

    try {
      _setLoading(true);
      clearResults();

      print('🔍 Starting morphology analysis for: $text');
      final results = await _performMorphologyUseCase.call(text, form);

      _morphologyResults = results;
      _setSuccess('تم التحليل الصرفي بنجاح - عدد العناصر: ${results.length}');
      print('✅ Morphology completed successfully: ${results.length} items');

    } catch (e) {
      print('❌ Morphology failed: $e');
      _setError('فشل في التحليل الصرفي: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Find synonyms
  Future<void> findSynonyms(String word) async {
    if (word.trim().isEmpty) {
      _setError('يرجى إدخال كلمة للبحث عن المرادفات');
      return;
    }

    try {
      _setLoading(true);
      _synonyms = [];

      print('🔍 Finding synonyms for: $word');
      final results = await _dataSource.findSynonyms(word);

      _synonyms = results;
      _setSuccess('تم العثور على ${results.length} مرادف للكلمة "$word"');
      print('✅ Found ${results.length} synonyms');

    } catch (e) {
      print('❌ Finding synonyms failed: $e');
      _setError('فشل في العثور على مرادفات: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Find antonyms
  Future<void> findAntonyms(String word) async {
    if (word.trim().isEmpty) {
      _setError('يرجى إدخال كلمة للبحث عن الأضداد');
      return;
    }

    try {
      _setLoading(true);
      _antonyms = [];

      print('🔍 Finding antonyms for: $word');
      final results = await _dataSource.findAntonyms(word);

      _antonyms = results;
      _setSuccess('تم العثور على ${results.length} ضد للكلمة "$word"');
      print('✅ Found ${results.length} antonyms');

    } catch (e) {
      print('❌ Finding antonyms failed: $e');
      _setError('فشل في العثور على أضداد: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Find plural
  Future<void> findPlural(String word) async {
    if (word.trim().isEmpty) {
      _setError('يرجى إدخال كلمة للبحث عن الجمع');
      return;
    }

    try {
      _setLoading(true);
      _plural = '';

      print('🔍 Finding plural for: $word');
      final result = await _dataSource.findPlural(word);

      _plural = result;
      _setSuccess('تم العثور على جمع للكلمة "$word": $result');
      print('✅ Found plural: $result');

    } catch (e) {
      print('❌ Finding plural failed: $e');
      _setError('فشل في العثور على الجمع: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Analyze meaning
  Future<void> analyzeMeaning(String word) async {
    if (word.trim().isEmpty) {
      _setError('يرجى إدخال كلمة لتحليل المعنى');
      return;
    }

    try {
      _setLoading(true);
      _meaning = '';

      print('🔍 Analyzing meaning for: $word');
      final result = await _dataSource.analyzeMeaning(word);

      _meaning = result;
      _setSuccess('تم تحليل معنى الكلمة "$word"');
      print('✅ Meaning analyzed successfully');

    } catch (e) {
      print('❌ Analyzing meaning failed: $e');
      _setError('فشل في تحليل المعنى: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Generate poetry
  Future<void> generatePoetry(String theme, String meterType) async {
    if (theme.trim().isEmpty) {
      _setError('يرجى إدخال موضوع لتوليد الشعر');
      return;
    }

    try {
      _setLoading(true);
      _generatedPoetry = '';
      _poetryEntity = null;

      print('🔍 Generating poetry for theme: $theme');
      final result = await _dataSource.generatePoetry(theme, meterType);

      _generatedPoetry = result;

      // Create poetry entity
      _poetryEntity = PoetryGenerationEntity(
        userId: 'current_user',
        type: 'poetry',
        inputText: theme,
        generatedPoem: result,
        grammarResult: [],
        createdAt: DateTime.now(),
        id: DateTime.now().millisecondsSinceEpoch.toString(),
      );

      _setSuccess('تم توليد الشعر بموضوع "$theme"');
      print('✅ Poetry generated successfully');

    } catch (e) {
      print('❌ Generating poetry failed: $e');
      _setError('فشل في توليد الشعر: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Analyze poetry meter
  Future<void> analyzePoetryMeter(String poem) async {
    if (poem.trim().isEmpty) {
      _setError('يرجى إدخال بيت شعري لتحليل البحر');
      return;
    }

    try {
      _setLoading(true);
      _poetryMeter = '';
      _meterEntity = null;

      print('🔍 Analyzing poetry meter for: $poem');
      final result = await _dataSource.analyzePoetryMeter(poem);

      _poetryMeter = result;

      // Parse result to create meter entity
      String detectedMeter = 'غير محدد';
      String confidence = 'منخفض';

      if (result.contains('البحر المكتشف:')) {
        final parts = result.split('-');
        if (parts.isNotEmpty) {
          detectedMeter = parts[0].replaceAll('البحر المكتشف:', '').trim();
        }
        if (parts.length > 1) {
          confidence = parts[1].replaceAll('الثقة:', '').trim();
        }
      } else {
        detectedMeter = result;
      }

      _meterEntity = PoetryMeterEntity(
        text: poem,
        detectedMeter: detectedMeter,
        confidence: confidence,
        pattern: '',
      );

      _setSuccess('تم تحليل البحر الشعري بنجاح');
      print('✅ Poetry meter analyzed successfully');

    } catch (e) {
      print('❌ Analyzing poetry meter failed: $e');
      _setError('فشل في تحليل البحر الشعري: ${e.toString().replaceAll('Exception: ', '')}');
    } finally {
      _setLoading(false);
    }
  }

  // Test all features
  Future<void> testAllFeatures() async {
    try {
      _setLoading(true);
      clearResults();

      // Test service status first
      await checkServiceStatus();

      if (!_isServiceOnline) {
        _setError('الخدمة غير متصلة. يرجى المحاولة لاحقاً');
        return;
      }

      // Test enhanced parsing
      await performParsing('الطالب المجتهد يذهب إلى المدرسة', useEnhanced: true);

      // Test synonyms
      await findSynonyms('جميل');

      // Test antonyms
      await findAntonyms('كبير');

      // Test plural
      await findPlural('كتاب');

      _setSuccess('تم اختبار جميع الميزات بنجاح');

    } catch (e) {
      print('❌ Testing all features failed: $e');
      _setError('فشل في اختبار الميزات: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  /// Get appropriate success message based on operation type
  String getSuccessMessage(String operationType) {
    switch (operationType) {
      case 'parsing':
        return 'تم إعراب النص بنجاح! ✅';
      case 'morphology':
        return 'تم تصريف الكلمة بنجاح! ✅';
      case 'poetry':
        return 'تم إنتاج الشعر بنجاح! 🎭';
      case 'meaning':
        return 'تم تحليل المعنى بنجاح! 💡';
      case 'meter':
        return 'تم تحديد البحر الشعري بنجاح! 🎵';
      case 'plural':
        return 'تم إيجاد الجمع بنجاح! 📝';
      case 'antonyms':
        return 'تم إيجاد الأضداد بنجاح! ⚡';
      case 'synonyms':
        return 'تم إيجاد المرادفات بنجاح! 🔄';
      default:
        return 'تمت العملية بنجاح! ✅';
    }
  }

  /// Get appropriate error message based on operation type
  String getErrorMessage(String operationType, String error) {
    switch (operationType) {
      case 'parsing':
        return 'فشل في إعراب النص: $error ❌';
      case 'morphology':
        return 'فشل في تصريف الكلمة: $error ❌';
      case 'poetry':
        return 'فشل في إنتاج الشعر: $error ❌';
      case 'meaning':
        return 'فشل في تحليل المعنى: $error ❌';
      case 'meter':
        return 'فشل في تحديد البحر: $error ❌';
      case 'plural':
        return 'فشل في إيجاد الجمع: $error ❌';
      case 'antonyms':
        return 'فشل في إيجاد الأضداد: $error ❌';
      case 'synonyms':
        return 'فشل في إيجاد المرادفات: $error ❌';
      default:
        return 'حدث خطأ: $error ❌';
    }
  }
}