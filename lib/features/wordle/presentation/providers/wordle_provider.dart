// lib/features/wordle/presentation/providers/wordle_provider.dart

import 'package:flutter/foundation.dart';
import '../../domain/entities/wordle_entity.dart';
import '../../domain/usecases/wordle_usecases.dart';

class WordleProvider with ChangeNotifier {
  final GetDailyWordleUseCase getDailyWordleUseCase;
  final GetRandomWordleUseCase getRandomWordleUseCase;
  final SubmitGuessUseCase submitGuessUseCase;
  final GetWordleHistoryUseCase getWordleHistoryUseCase;
  final SaveWordleProgressUseCase saveWordleProgressUseCase;

  WordleProvider({
    required this.getDailyWordleUseCase,
    required this.getRandomWordleUseCase,
    required this.submitGuessUseCase,
    required this.getWordleHistoryUseCase,
    required this.saveWordleProgressUseCase,
  });

  // State variables
  WordleEntity? _currentWordle;
  List<WordleEntity> _wordleHistory = [];
  String _currentGuess = '';
  List<List<WordleLetterResult>> _guessResults = [];
  Map<String, LetterStatus> _keyboardState = {};
  bool _isLoading = false;
  String? _error;
  bool _isSubmittingGuess = false;

  // Getters
  WordleEntity? get currentWordle => _currentWordle;
  List<WordleEntity> get wordleHistory => _wordleHistory;
  String get currentGuess => _currentGuess;
  List<List<WordleLetterResult>> get guessResults => _guessResults;
  Map<String, LetterStatus> get keyboardState => _keyboardState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isSubmittingGuess => _isSubmittingGuess;
  bool get canSubmitGuess => _currentGuess.length == 5 && !_isSubmittingGuess;
  bool get isGameCompleted => _currentWordle?.isCompleted ?? false;
  bool get isGameWon => _currentWordle?.isWon ?? false;

  // Arabic keyboard layout
  static const List<List<String>> arabicKeyboard = [
    ['ض', 'ص', 'ث', 'ق', 'ف', 'غ', 'ع', 'ه', 'خ', 'ح', 'ج', 'د'],
    ['ش', 'س', 'ي', 'ب', 'ل', 'ا', 'ت', 'ن', 'م', 'ك', 'ط'],
    ['ئ', 'ء', 'ؤ', 'ر', 'لا', 'ى', 'ة', 'و', 'ز', 'ظ'],
  ];

  // Load daily wordle
  Future<void> loadDailyWordle() async {
    try {
      _setLoading(true);
      _error = null;

      _currentWordle = await getDailyWordleUseCase();
      _initializeGameState();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Load random wordle
  Future<void> loadRandomWordle() async {
    try {
      _setLoading(true);
      _error = null;

      _currentWordle = await getRandomWordleUseCase();
      _initializeGameState();

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  // Add letter to current guess
  void addLetter(String letter) {
    if (_currentGuess.length < 5 && !isGameCompleted) {
      _currentGuess += letter;
      notifyListeners();
    }
  }

  // Remove last letter from current guess
  void removeLetter() {
    if (_currentGuess.isNotEmpty) {
      _currentGuess = _currentGuess.substring(0, _currentGuess.length - 1);
      notifyListeners();
    }
  }

  // Submit current guess
  Future<void> submitGuess() async {
    if (!canSubmitGuess || _currentWordle == null) return;

    try {
      _isSubmittingGuess = true;
      notifyListeners();

      final updatedWordle = await submitGuessUseCase(_currentWordle!.id, _currentGuess);
      _currentWordle = updatedWordle;

      // Update guess results and keyboard state
      _updateGuessResults();
      _updateKeyboardState();

      // Clear current guess
      _currentGuess = '';

      // Save progress
      await saveWordleProgressUseCase(updatedWordle);

      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isSubmittingGuess = false;
      notifyListeners();
    }
  }

  // Load wordle history
  Future<void> loadWordleHistory() async {
    try {
      _wordleHistory = await getWordleHistoryUseCase();
      notifyListeners();
    } catch (e) {
      // Handle error silently for history
      debugPrint('Failed to load wordle history: $e');
    }
  }

  // Reset game
  void resetGame() {
    _currentWordle = null;
    _currentGuess = '';
    _guessResults = [];
    _keyboardState = {};
    _error = null;
    notifyListeners();
  }

  // Private methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _initializeGameState() {
    _currentGuess = '';
    _guessResults = [];
    _keyboardState = {};

    // Initialize keyboard state
    for (final row in arabicKeyboard) {
      for (final letter in row) {
        _keyboardState[letter] = LetterStatus.unknown;
      }
    }

    // If wordle has existing attempts, rebuild game state
    if (_currentWordle != null && _currentWordle!.attempts.isNotEmpty) {
      _rebuildGameState();
    }
  }

  void _rebuildGameState() {
    // This would rebuild the game state from existing attempts
    // Implementation depends on how the API returns attempt results
    _guessResults = [];
    _keyboardState = {};

    // Initialize keyboard
    for (final row in arabicKeyboard) {
      for (final letter in row) {
        _keyboardState[letter] = LetterStatus.unknown;
      }
    }

    // TODO: Process existing attempts to rebuild visual state
    // This requires the API to return letter-by-letter results for each attempt
  }

  void _updateGuessResults() {
    // This method would process the latest guess result
    // Implementation depends on API response format
    if (_currentWordle != null && _currentWordle!.attempts.isNotEmpty) {
      final latestAttempt = _currentWordle!.attempts.last;
      // TODO: Process attempt result and add to _guessResults
    }
  }

  void _updateKeyboardState() {
    // Update keyboard colors based on all guesses so far
    // Implementation depends on having letter-by-letter results
    for (final results in _guessResults) {
      for (final result in results) {
        final currentStatus = _keyboardState[result.letter] ?? LetterStatus.unknown;

        // Update with better status (correct > present > absent > unknown)
        if (result.status == LetterStatus.correct) {
          _keyboardState[result.letter] = LetterStatus.correct;
        } else if (result.status == LetterStatus.present &&
            currentStatus != LetterStatus.correct) {
          _keyboardState[result.letter] = LetterStatus.present;
        } else if (result.status == LetterStatus.absent &&
            currentStatus == LetterStatus.unknown) {
          _keyboardState[result.letter] = LetterStatus.absent;
        }
      }
    }
  }

  // Get letter status for keyboard display
  LetterStatus getLetterStatus(String letter) {
    return _keyboardState[letter] ?? LetterStatus.unknown;
  }

  // Get current guess letters as list for display
  List<String> getCurrentGuessLetters() {
    final letters = _currentGuess.split('');
    while (letters.length < 5) {
      letters.add('');
    }
    return letters;
  }

  // Get attempt results for display
  List<WordleLetterResult> getAttemptResults(int attemptIndex) {
    if (attemptIndex < _guessResults.length) {
      return _guessResults[attemptIndex];
    }
    return List.generate(5, (index) => const WordleLetterResult(
      letter: '',
      status: LetterStatus.unknown,
    ));
  }
}