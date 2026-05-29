import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'movie_model.dart';

class FavoritesManager {
  static const String _key = 'favorite_movies';

  // Ambil semua film favorit
  static Future<List<Movie>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];
    return jsonList
        .map((jsonStr) => Movie.fromJson(jsonDecode(jsonStr)))
        .toList();
  }

  // Tambah film ke favorit
  static Future<void> addFavorite(Movie movie) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];

    final movieJson = jsonEncode({
      'id': movie.id,
      'title': movie.title,
      'overview': movie.overview,
      'poster_path': movie.posterPath,
      'backdrop_path': movie.backdropPath,
      'vote_average': movie.voteAverage,
      'release_date': movie.releaseDate,
      'genre_ids': movie.genreIds,
    });

    // Cegah duplikat
    final exists = jsonList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == movie.id;
    });

    if (!exists) {
      jsonList.add(movieJson);
      await prefs.setStringList(_key, jsonList);
    }
  }

  // Hapus film dari favorit
  static Future<void> removeFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];

    jsonList.removeWhere((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == movieId;
    });

    await prefs.setStringList(_key, jsonList);
  }

  // Cek apakah film sudah difavoritkan
  static Future<bool> isFavorite(int movieId) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> jsonList = prefs.getStringList(_key) ?? [];

    return jsonList.any((item) {
      final decoded = jsonDecode(item);
      return decoded['id'] == movieId;
    });
  }

  // Hapus semua favorit
  static Future<void> clearFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}