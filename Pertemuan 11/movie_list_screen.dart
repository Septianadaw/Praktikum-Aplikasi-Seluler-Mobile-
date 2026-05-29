import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_model.dart';
import 'movie_service.dart';
import 'movie_detail_screen.dart';
import 'favorites_screen.dart';

class MovieListScreen extends StatefulWidget {
  const MovieListScreen({super.key});

  @override
  State<MovieListScreen> createState() => _MovieListScreenState();
}

class _MovieListScreenState extends State<MovieListScreen> {
  final MovieService _movieService = MovieService();
  final TextEditingController _searchController = TextEditingController();

  List<Movie> _movies = [];
  bool _isLoading = true;
  bool _isGridView = false;
  bool _isSearching = false;
  int? _selectedGenreId;

  final List<Map<String, dynamic>> _genres = [
    {'id': null, 'name': 'Semua'},
    {'id': 28, 'name': 'Action'},
    {'id': 12, 'name': 'Adventure'},
    {'id': 16, 'name': 'Animation'},
    {'id': 35, 'name': 'Comedy'},
    {'id': 80, 'name': 'Crime'},
    {'id': 18, 'name': 'Drama'},
    {'id': 27, 'name': 'Horror'},
    {'id': 10749, 'name': 'Romance'},
    {'id': 878, 'name': 'Sci-Fi'},
    {'id': 53, 'name': 'Thriller'},
  ];

  @override
  void initState() {
    super.initState();
    _loadMovies();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMovies() async {
    setState(() {
      _isLoading = true;
      _isSearching = false;
    });
    try {
      final movies = await _movieService.fetchPopularMovies();
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _searchMovies(String query) async {
    if (query.isEmpty) {
      _loadMovies();
      return;
    }
    setState(() {
      _isLoading = true;
      _isSearching = true;
    });
    try {
      final movies = await _movieService.searchMovies(query);
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _filterByGenre(int? genreId) async {
    setState(() {
      _isLoading = true;
      _selectedGenreId = genreId;
      _searchController.clear();
      _isSearching = false;
    });
    try {
      final movies = genreId == null
          ? await _movieService.fetchPopularMovies()
          : await _movieService.fetchMoviesByGenre(genreId);
      setState(() {
        _movies = movies;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🎬 CineDB',
          style: TextStyle(
            color: Color(0xFF01B4E4),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        actions: [
          // Toggle grid/list
          IconButton(
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: const Color(0xFF01B4E4),
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          // Favorites
          IconButton(
            icon: const Icon(Icons.favorite_rounded, color: Color(0xFF01B4E4)),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Cari film...',
                hintStyle: const TextStyle(color: Color(0xFF7A9BBF)),
                prefixIcon:
                    const Icon(Icons.search, color: Color(0xFF01B4E4)),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF7A9BBF)),
                        onPressed: () {
                          _searchController.clear();
                          _loadMovies();
                        },
                      )
                    : null,
                filled: true,
                fillColor: const Color(0xFF1A3A5C),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
              onChanged: (value) {
                setState(() {});
                _searchMovies(value);
              },
            ),
          ),

          // Genre chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _genres.length,
              itemBuilder: (context, index) {
                final genre = _genres[index];
                final isSelected = _selectedGenreId == genre['id'];
                return GestureDetector(
                  onTap: () => _filterByGenre(genre['id']),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF01B4E4)
                          : const Color(0xFF1A3A5C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      genre['name'],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : const Color(0xFF7A9BBF),
                        fontSize: 13,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 12),

          // Konten
          Expanded(
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF01B4E4),
                    ),
                  )
                : _movies.isEmpty
                    ? const Center(
                        child: Text(
                          'Film tidak ditemukan',
                          style: TextStyle(color: Color(0xFF7A9BBF)),
                        ),
                      )
                    : _isGridView
                        ? _buildGridView()
                        : _buildListView(),
          ),
        ],
      ),
    );
  }

  // Grid view
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            ),
          ),
          child: Card(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Poster
                ClipRRect(
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: const Color(0xFF0D253F),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF01B4E4),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 200,
                      color: const Color(0xFF0D253F),
                      child: const Icon(Icons.movie,
                          color: Colors.grey, size: 40),
                    ),
                  ),
                ),
                // Info
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        movie.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star_rounded,
                              color: Color(0xFF90CEA1), size: 13),
                          const SizedBox(width: 3),
                          Text(
                            movie.voteAverage.toStringAsFixed(1),
                            style: const TextStyle(
                              color: Color(0xFF90CEA1),
                              fontSize: 11,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            movie.releaseDate.length >= 4
                                ? movie.releaseDate.substring(0, 4)
                                : '',
                            style: const TextStyle(
                              color: Color(0xFF7A9BBF),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // List view
  Widget _buildListView() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _movies.length,
      itemBuilder: (context, index) {
        final movie = _movies[index];
        return GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MovieDetailScreen(movie: movie),
            ),
          ),
          child: Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                // Poster
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12)),
                  child: CachedNetworkImage(
                    imageUrl:
                        'https://image.tmdb.org/t/p/w200${movie.posterPath}',
                    width: 75,
                    height: 105,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      width: 75,
                      height: 105,
                      color: const Color(0xFF0D253F),
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF01B4E4),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      width: 75,
                      height: 105,
                      color: const Color(0xFF0D253F),
                      child: const Icon(Icons.movie,
                          color: Colors.grey, size: 30),
                    ),
                  ),
                ),
                // Info
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movie.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.star_rounded,
                                color: Color(0xFF90CEA1), size: 14),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Color(0xFF90CEA1),
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              movie.releaseDate,
                              style: const TextStyle(
                                color: Color(0xFF7A9BBF),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // Genre chips
                        Wrap(
                          spacing: 4,
                          children: movie.genreNames.take(2).map((genre) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0xFF01B4E4)
                                    .withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                genre,
                                style: const TextStyle(
                                  color: Color(0xFF01B4E4),
                                  fontSize: 10,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.chevron_right,
                      color: Color(0xFF7A9BBF)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}