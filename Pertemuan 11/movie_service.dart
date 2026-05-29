import 'dart:convert';
import 'package:http/http.dart' as http;
import 'movie_model.dart';

class MovieService {
  final String _apiKey = '848e0422f269b706f418932ea0d70597';
  final String _baseUrl = 'https://api.themoviedb.org/3';

  Future<List<Movie>> fetchPopularMovies({int page = 1}) async =>
      _fetchMovies('$_baseUrl/movie/popular?api_key=$_apiKey&language=id-ID&page=$page');

  Future<List<Movie>> fetchNowPlaying({int page = 1}) async =>
      _fetchMovies('$_baseUrl/movie/now_playing?api_key=$_apiKey&language=id-ID&page=$page');

  Future<List<Movie>> fetchTopRated({int page = 1}) async =>
      _fetchMovies('$_baseUrl/movie/top_rated?api_key=$_apiKey&language=id-ID&page=$page');

  Future<List<Movie>> fetchUpcoming({int page = 1}) async =>
      _fetchMovies('$_baseUrl/movie/upcoming?api_key=$_apiKey&language=id-ID&page=$page');

  Future<List<Movie>> searchMovies(String query, {int page = 1}) async {
    if (query.isEmpty) return fetchPopularMovies();
    return _fetchMovies(
        '$_baseUrl/search/movie?api_key=$_apiKey&language=id-ID&query=${Uri.encodeComponent(query)}&page=$page');
  }

  Future<List<Movie>> fetchMoviesByGenre(int genreId, {int page = 1}) async =>
      _fetchMovies(
          '$_baseUrl/discover/movie?api_key=$_apiKey&language=id-ID&with_genres=$genreId&sort_by=popularity.desc&page=$page');

  Future<Movie> fetchMovieDetail(int id) async {
    final url = Uri.parse('$_baseUrl/movie/$id?api_key=$_apiKey&language=id-ID');
    final response = await http.get(url);
    if (response.statusCode == 200) return Movie.fromJson(jsonDecode(response.body));
    throw Exception('Gagal memuat detail film');
  }

  Future<List<Movie>> fetchSimilarMovies(int id) async =>
      _fetchMovies('$_baseUrl/movie/$id/similar?api_key=$_apiKey&language=id-ID&page=1');

  Future<String?> fetchTrailerKey(int movieId) async {
    final url = Uri.parse('$_baseUrl/movie/$movieId/videos?api_key=$_apiKey&language=id-ID');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final results = jsonDecode(response.body)['results'] as List;
      // Cari trailer YouTube
      final trailer = results.firstWhere(
        (v) => v['site'] == 'YouTube' && v['type'] == 'Trailer',
        orElse: () => results.isNotEmpty ? results.first : null,
      );
      return trailer?['key'];
    }
    return null;
  }

  Future<List<Movie>> _fetchMovies(String urlString) async {
    final response = await http.get(Uri.parse(urlString));
    if (response.statusCode == 200) {
      final List results = jsonDecode(response.body)['results'];
      return results.map((j) => Movie.fromJson(j)).toList();
    }
    throw Exception('Gagal memuat film');
  }
}