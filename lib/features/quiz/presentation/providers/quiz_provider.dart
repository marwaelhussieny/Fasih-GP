// lib/features/quiz/presentation/providers/quiz_provider.dart
import 'package:flutter/foundation.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_entity.dart';
import 'package:grad_project/features/quiz/domain/entities/question_entity.dart';
import 'package:grad_project/features/quiz/domain/entities/quiz_result_entity.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_quiz_by_criteria.dart';
import 'package:grad_project/features/quiz/domain/usecases/submit_quiz_answers.dart';
import 'package:grad_project/features/quiz/domain/usecases/get_user_quiz_results.dart';
import 'package:grad_project/features/quiz/domain/usecases/generate_quiz_questions.dart'; // For AI integration

class QuizProvider with ChangeNotifier {
  final GetQuiz _getQuiz;
  final GetQuizzesByCriteria _getQuizzesByCriteria;
  final SubmitQuizAnswers _submitQuizAnswers;
  final GetUserQuizResults _getUserQuizResults;
  final GenerateQuizQuestions _generateQuizQuestions; // For AI integration

  QuizProvider({
    required GetQuiz getQuiz,
    required GetQuizzesByCriteria getQuizzesByCriteria,
    required SubmitQuizAnswers submitQuizAnswers,
    required GetUserQuizResults getUserQuizResults,
    required GenerateQuizQuestions generateQuizQuestions, // For AI integration
  })  : _getQuiz = getQuiz,
        _getQuizzesByCriteria = getQuizzesByCriteria,
        _submitQuizAnswers = submitQuizAnswers,
        _getUserQuizResults = getUserQuizResults,
        _generateQuizQuestions = generateQuizQuestions;

  // --- State Variables ---
  bool _isLoading = false;
  String? _errorMessage;
  List<QuizEntity> _availableQuizzes = [];
  QuizEntity? _currentQuiz;
  QuizResultEntity? _lastQuizResult;
  List<QuizResultEntity> _userQuizResults = [];

  // Quiz-taking specific state
  int _currentQuestionIndex = 0;
  Map<String, String> _userAnswers = {}; // Map of questionId -> selectedAnswer (for MCQs)
  Map<String, List<String>> _userFillInTheBlanks = {}; // Map of questionId -> ordered selected words (for Fill in the blank)
  bool _showAnswerFeedback = false; // <--- NEW: To control when to show correct/wrong feedback

  // --- Getters ---
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<QuizEntity> get availableQuizzes => _availableQuizzes;
  QuizEntity? get currentQuiz => _currentQuiz;
  QuizResultEntity? get lastQuizResult => _lastQuizResult;
  List<QuizResultEntity> get userQuizResults => _userQuizResults;
  int get currentQuestionIndex => _currentQuestionIndex;
  QuestionEntity? get currentQuestion =>
      _currentQuiz?.questions.isNotEmpty == true &&
          _currentQuestionIndex < _currentQuiz!.questions.length
          ? _currentQuiz!.questions[_currentQuestionIndex]
          : null;
  Map<String, String> get userAnswers => _userAnswers;
  Map<String, List<String>> get userFillInTheBlanks => _userFillInTheBlanks; // New getter for fill-in-the-blanks
  bool get showAnswerFeedback => _showAnswerFeedback; // <--- NEW GETTER

  // --- Helper Methods ---
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _setErrorMessage(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void resetQuizState() {
    _currentQuiz = null;
    _lastQuizResult = null;
    _currentQuestionIndex = 0;
    _userAnswers = {};
    _userFillInTheBlanks = {}; // Reset fill in the blanks
    _showAnswerFeedback = false; // Reset feedback state
    _setErrorMessage(null);
    notifyListeners();
  }

  // --- Core Quiz Logic ---

  Future<void> fetchAvailableQuizzes({String? topic, String? difficulty}) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _availableQuizzes = await _getQuizzesByCriteria.call(
        topic: topic,
        difficulty: difficulty,
      );
    } catch (e) {
      _setErrorMessage('Failed to fetch quizzes: ${e.toString()}');
      if (kDebugMode) print('Error fetching quizzes: $e');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> selectAndLoadQuiz(String quizId) async {
    _setLoading(true);
    _setErrorMessage(null);
    resetQuizState(); // Reset state for a new quiz
    try {
      _currentQuiz = await _getQuiz.call(quizId);
    } catch (e) {
      _setErrorMessage('Failed to load quiz: ${e.toString()}');
      if (kDebugMode) print('Error loading quiz: $e');
    } finally {
      _setLoading(false);
    }
  }

  void goToNextQuestion() {
    // Before moving, hide feedback for the current question
    _showAnswerFeedback = false;
    if (_currentQuiz != null &&
        _currentQuestionIndex < _currentQuiz!.questions.length - 1) {
      _currentQuestionIndex++;
      notifyListeners();
    }
  }

  void goToPreviousQuestion() {
    // Before moving, hide feedback for the current question
    _showAnswerFeedback = false;
    if (_currentQuestionIndex > 0) {
      _currentQuestionIndex--;
      notifyListeners();
    }
  }

  void answerQuestion(String questionId, String answer) {
    _userAnswers[questionId] = answer;
    _showAnswerFeedback = true; // Show feedback immediately after answering
    notifyListeners();
  }

  // For fill-in-the-blank where options are selected in order
  void setFillInTheBlankAnswer(String questionId, List<String> selectedWords) {
    _userFillInTheBlanks[questionId] = selectedWords;
    _showAnswerFeedback = true; // Show feedback immediately after "answering" (selecting words)
    notifyListeners();
  }


  Future<QuizResultEntity?> submitQuiz(String userId) async {
    if (_currentQuiz == null) {
      _setErrorMessage('No quiz selected to submit.');
      return null;
    }

    _setLoading(true);
    _setErrorMessage(null);

    // Prepare answers for submission.
    // Fill-in-the-blank answers need to be joined into a single string to match correctAnswer format.
    Map<String, String> answersForSubmission = Map.from(_userAnswers); // Start with MCQ answers

    _userFillInTheBlanks.forEach((questionId, words) {
      answersForSubmission[questionId] = words.join(' ').trim(); // Join words for fill-in-the-blank
    });

    try {
      _lastQuizResult = await _submitQuizAnswers.call(
        quizId: _currentQuiz!.id,
        userId: userId,
        userAnswers: answersForSubmission, // Use the combined map
      );
      return _lastQuizResult;
    } catch (e) {
      _setErrorMessage('Failed to submit quiz: ${e.toString()}');
      if (kDebugMode) print('Error submitting quiz: $e');
      return null;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchUserQuizResults(String userId) async {
    _setLoading(true);
    _setErrorMessage(null);
    try {
      _userQuizResults = await _getUserQuizResults.call(userId);
    } catch (e) {
      _setErrorMessage('Failed to fetch user quiz results: ${e.toString()}');
      if (kDebugMode) print('Error fetching user quiz results: $e');
    } finally {
      _setLoading(false);
    }
  }

  // --- AI Integration ---
  Future<void> generateAndLoadQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 10,
    String? language,
    String? specificConcept,
  }) async {
    _setLoading(true);
    _setErrorMessage(null);
    resetQuizState(); // Reset state for a new quiz
    try {
      _currentQuiz = await _generateQuizQuestions.call(
        topic: topic,
        difficulty: difficulty,
        numberOfQuestions: numberOfQuestions,
        language: language,
        specificConcept: specificConcept,
      );
    } catch (e) {
      _setErrorMessage('Failed to generate quiz: ${e.toString()}');
      if (kDebugMode) print('Error generating quiz: $e');
    } finally {
      _setLoading(false);
    }
  }
}