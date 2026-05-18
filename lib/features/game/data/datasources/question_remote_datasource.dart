import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/option.dart';
import '../../domain/entities/question.dart';

class QuestionRemoteDataSource {
  final SupabaseClient _client;
  const QuestionRemoteDataSource(this._client);

  Future<List<Question>> getQuestions({
    required int categoryId,
    required String difficulty,
    int limit = 10,
  }) async {
    final data = await _client
        .from('questions')
        .select('*, options(*)')
        .eq('category_id', categoryId)
        .eq('difficulty', difficulty)
        .limit(limit);

    final questions = (data as List)
        .map((e) => _mapToQuestion(e as Map<String, dynamic>))
        .toList();

    questions.shuffle();
    return questions;
  }

  Question _mapToQuestion(Map<String, dynamic> json) => Question(
        id: json['id'] as int,
        categoryId: json['category_id'] as int,
        text: json['text'] as String,
        difficulty: json['difficulty'] as String,
        timeLimit: json['time_limit'] as int? ?? 30,
        options: (json['options'] as List<dynamic>? ?? [])
            .map((o) => _mapToOption(o as Map<String, dynamic>))
            .toList(),
      );

  Option _mapToOption(Map<String, dynamic> json) => Option(
        id: json['id'] as int,
        questionId: json['question_id'] as int,
        text: json['text'] as String,
        isCorrect: json['is_correct'] as bool,
      );
}