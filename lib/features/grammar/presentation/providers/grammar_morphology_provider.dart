// lib/features/grammar_morphology/presentation/providers/grammar_morphology_provider.dart

import 'package:flutter/material.dart';
import 'package:grad_project/features/grammar/domain/entities/grammar_morphology_entity.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_parsing_usecase.dart';
import 'package:grad_project/features/grammar/domain/usecases/perform_morphology_usecase.dart';

class GrammarMorphologyProvider extends ChangeNotifier {
  final PerformParsingUseCase _performParsingUseCase;
  final PerformMorphologyUseCase _performMorphologyUseCase;

  GrammarMorphologyProvider(this._performParsingUseCase, this._performMorphologyUseCase);

  bool _isLoading = false;
  String? _error;
  String? _resultMessage; // For general messages like "تم الإعراب بنجاح!"
  List<ParsingResultEntity> _parsingResults = [];
  List<MorphologyResultEntity> _morphologyResults = [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get resultMessage => _resultMessage;
  List<ParsingResultEntity> get parsingResults => _parsingResults;
  List<MorphologyResultEntity> get morphologyResults => _morphologyResults;

  Future<void> performParsing(String text) async {
    _isLoading = true;
    _error = null;
    _resultMessage = null;
    _parsingResults = [];
    _morphologyResults = []; // Clear morphology results when parsing
    notifyListeners();

    try {
      final results = await _performParsingUseCase(text);
      _parsingResults = results;
      _resultMessage = 'تم الإعراب بنجاح!';
    } catch (e) {
      _error = 'خطأ في الإعراب: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performMorphology(String text, String form) async {
    _isLoading = true;
    _error = null;
    _resultMessage = null;
    _parsingResults = []; // Clear parsing results when morphing
    _morphologyResults = [];
    notifyListeners();

    try {
      final results = await _performMorphologyUseCase(text, form);
      _morphologyResults = results;
      _resultMessage = 'تم التصريف بنجاح!';
    } catch (e) {
      _error = 'خطأ في التصريف: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _parsingResults = [];
    _morphologyResults = [];
    _resultMessage = null;
    _error = null;
    notifyListeners();
  }
}
