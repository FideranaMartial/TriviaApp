import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/category.dart';

class CategoryRemoteDataSource {
  final SupabaseClient _client;
  const CategoryRemoteDataSource(this._client);

  Future<List<Category>> getCategories() async {
    final data = await _client
        .from('categories')
        .select()
        .order('id');

    return (data as List)
        .map((e) => _mapToCategory(e as Map<String, dynamic>))
        .toList();
  }

  Category _mapToCategory(Map<String, dynamic> json) => Category(
        id: json['id'] as int,
        name: json['name'] as String,
        iconName: json['icon_name'] as String? ?? 'quiz',
        colorHex: json['color_hex'] as String? ?? '#378ADD',
      );
}