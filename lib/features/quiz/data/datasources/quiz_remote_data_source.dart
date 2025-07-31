// lib/features/quiz/data/datasources/quiz_remote_data_source.dart
import 'package:grad_project/features/quiz/data/models/quiz_model.dart';
import 'package:grad_project/features/quiz/data/models/quiz_result_model.dart';
import 'package:grad_project/features/quiz/data/models/question_model.dart'; // Import QuestionModel

abstract class QuizRemoteDataSource {
  Future<QuizModel> getQuiz(String quizId);
  Future<List<QuizModel>> getQuizzes({String? topic, String? difficulty});
  Future<QuizResultModel> submitQuizAnswers({
    required String quizId,
    required String userId,
    required Map<String, String> userAnswers,
  });
  Future<List<QuizResultModel>> getUserQuizResults(String userId);
  // For AI-generated quizzes
  Future<QuizModel> generateQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions,
    String? language,
    String? specificConcept,
  });
}

class QuizRemoteDataSourceImpl implements QuizRemoteDataSource {
  // Simulate network delay
  Future<void> _simulateNetworkDelay() =>
      Future.delayed(const Duration(milliseconds: 700));

  // --- Mock Data ---
  static final List<QuizModel> _mockQuizzes = [
    QuizModel(
      id: 'quiz1',
      title: 'Arabic Grammar Basics',
      topic: 'Arabic Grammar',
      difficulty: 'easy',
      durationMinutes: 10,
      questions: [
        QuestionModel(
          id: 'q1',
          text: 'أعرِب الجملة الآتية (بالترتيب). هذا الكتاب مفيد للتلميذ. (املأ الفراغ)',
          type: 'fillInTheBlank',
          // Correct answer is the combined words
          correctAnswer: 'هذا: اسم إشارة الكتاب: بدل مفيد: خبر للتلميذ: جار ومجرور',
          options: ['هذا:', 'الكتاب:', 'مفيد:', 'للتلميذ:', 'اسم إشارة', 'بدل', 'خبر', 'جار ومجرور'],
          audioUrl: 'https://example.com/audio/q1.mp3', // Example URL
          explanation: 'إعراب الجملة يتطلب تحديد كل كلمة ووظيفتها النحوية.',
        ),
        QuestionModel(
          id: 'q2',
          text: 'ما معنى كلمة "مشرقة"؟',
          type: 'multipleChoice',
          options: ['مظلمة', 'لامعة', 'باردة', 'غائمة'],
          correctAnswer: 'لامعة',
          explanation: '"مشرقة" تعني ساطعة أو لامعة.',
        ),
        QuestionModel(
          id: 'q3',
          text: 'ما نوع الخبر في جملة "الشمس مشرقة"؟',
          type: 'multipleChoice',
          options: ['مفرد', 'جملة فعلية', 'جملة اسمية', 'شبه جملة'],
          correctAnswer: 'مفرد',
          explanation: 'الخبر "مشرقة" كلمة واحدة وهو اسم، لذا هو خبر مفرد.',
        ),
      ],
    ),
    QuizModel(
      id: 'quiz2',
      title: 'Advanced Arabic Syntax',
      topic: 'Arabic Grammar',
      difficulty: 'hard',
      durationMinutes: 15,
      questions: [
        QuestionModel(
          id: 'aq1',
          text: 'حدد نوع "ما" في قوله تعالى: "وما رميت إذ رميت ولكن الله رمى"',
          type: 'multipleChoice',
          options: ['نافية', 'موصولة', 'استفهامية', 'شرطية'],
          correctAnswer: 'نافية',
          explanation: '"ما" هنا نافية تنفي الفعل.',
        ),
      ],
    ),
  ];

  static final List<QuizResultModel> _mockQuizResults = [
    QuizResultModel(
      quizId: 'quiz1',
      userId: '1', // Assuming user ID '1' from user_repository_impl
      completedAt: DateTime.now().subtract(const Duration(days: 2)),
      score: 60,
      totalQuestions: 3,
      correctAnswers: 2,
      incorrectAnswers: 1,
      questionResults: [
        {'questionId': 'q1', 'answeredOption': 'هذا: اسم إشارة', 'isCorrect': true, 'explanation': 'إعراب الجملة يتطلب تحديد كل كلمة ووظيفتها النحوية.'}, // Example
        {'questionId': 'q2', 'answeredOption': 'لامعة', 'isCorrect': true, 'explanation': '"مشرقة" تعني ساطعة أو لامعة.'},
        {'questionId': 'q3', 'answeredOption': 'جملة فعلية', 'isCorrect': false, 'explanation': 'The correct answer is singular noun.'},
      ],
    ),
  ];
  // --- End Mock Data ---


  @override
  Future<QuizModel> getQuiz(String quizId) async {
    await _simulateNetworkDelay();
    final quiz = _mockQuizzes.firstWhere(
          (q) => q.id == quizId,
      orElse: () => throw Exception('Quiz not found'),
    );
    return quiz;
  }

  @override
  Future<List<QuizModel>> getQuizzes({String? topic, String? difficulty}) async {
    await _simulateNetworkDelay();
    return _mockQuizzes.where((q) {
      bool matchesTopic = topic == null || q.topic.toLowerCase() == topic.toLowerCase();
      bool matchesDifficulty = difficulty == null || q.difficulty.toLowerCase() == difficulty.toLowerCase();
      return matchesTopic && matchesDifficulty;
    }).toList();
  }

  @override
  Future<QuizResultModel> submitQuizAnswers({
    required String quizId,
    required String userId,
    required Map<String, String> userAnswers,
  }) async {
    await _simulateNetworkDelay();
    // In a real app, this would send data to the backend for scoring.
    // Here, we'll simulate scoring based on mock data.
    final quiz = _mockQuizzes.firstWhere(
          (q) => q.id == quizId,
      orElse: () => throw Exception('Quiz not found for scoring'),
    );

    int correct = 0;
    List<Map<String, dynamic>> results = [];

    for (var question in quiz.questions) {
      // Normalize comparison by trimming and converting to lowercase
      final userAnswer = userAnswers[question.id]?.trim().toLowerCase();
      final correctAnswer = question.correctAnswer.trim().toLowerCase();

      final isCorrect = userAnswer == correctAnswer;
      if (isCorrect) {
        correct++;
      }
      results.add({
        'questionId': question.id,
        'answeredOption': userAnswers[question.id], // Store original user input
        'isCorrect': isCorrect,
        'correctAnswer': question.correctAnswer,
        'explanation': question.explanation,
      });
    }

    final score = (correct / quiz.questions.length * 100).round();
    final newResult = QuizResultModel(
      quizId: quizId,
      userId: userId,
      completedAt: DateTime.now(),
      score: score,
      totalQuestions: quiz.questions.length,
      correctAnswers: correct,
      incorrectAnswers: quiz.questions.length - correct,
      questionResults: results,
    );

    // Add to mock results (in a real app, this would be saved to DB)
    _mockQuizResults.add(newResult);
    return newResult;
  }

  @override
  Future<List<QuizResultModel>> getUserQuizResults(String userId) async {
    await _simulateNetworkDelay();
    return _mockQuizResults.where((r) => r.userId == userId).toList();
  }

  @override
  Future<QuizModel> generateQuiz({
    required String topic,
    required String difficulty,
    int numberOfQuestions = 10,
    String? language,
    String? specificConcept,
  }) async {
    await _simulateNetworkDelay();
    // Simulate AI generation. In a real scenario, this would call an AI service.
    // For now, we'll return a generic quiz or a filtered one.
    print('Simulating AI quiz generation for topic: $topic, difficulty: $difficulty');

    // Return a dummy generated quiz
    return QuizModel(
      id: 'generated_quiz_${DateTime.now().millisecondsSinceEpoch}',
      title: 'AI Generated Quiz: $topic ($difficulty)',
      topic: topic,
      difficulty: difficulty,
      durationMinutes: numberOfQuestions * 2, // 2 mins per question
      questions: List.generate(numberOfQuestions, (index) {
        return QuestionModel(
          id: 'gen_q${index + 1}',
          text: 'AI generated question ${index + 1} about $topic.',
          type: (index % 2 == 0) ? 'multipleChoice' : 'fillInTheBlank', // Alternate types
          options: (index % 2 == 0) ? ['Option A', 'Option B', 'Option C', 'Option D'] : ['word1', 'word2', 'word3', 'word4'], // Options for fill-in-blank
          correctAnswer: (index % 2 == 0) ? 'Option A' : 'word1 word2', // Correct answer for fill-in-blank (joined)
          explanation: 'This is an AI-generated explanation for question ${index + 1}.',
        );
      }),
    );
  }
}