import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_model.dart';
import 'favorites_manager.dart';
import 'movie_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Movie> _favorites = [];
  bool _isLoading = true;
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      _favorites = favorites;
      _isLoading = false;
    });
  }

  Future<void> _removeFavorite(Movie movie) async {
    await FavoritesManager.removeFavorite(movie.id);
    setState(() => _favorites.remove(movie));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: const Row(
            children: [
              Icon(Icons.favorite_border, color: Colors.white, size: 16),
              SizedBox(width: 8),
              Text('Dihapus dari Favorites'),
            ],
          ),
          backgroundColor: const Color(0xFF1A3A5C),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  Future<void> _clearAllFavorites() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFF1A3A5C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Hapus Semua?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Semua film favorit akan dihapus.',
          style: TextStyle(color: Color(0xFF7A9BBF)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Color(0xFF01B4E4)),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Hapus',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await FavoritesManager.clearFavorites();
      setState(() => _favorites.clear());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Favorites',
              style: TextStyle(
                color: Color(0xFF01B4E4),
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            Text(
              '${_favorites.length} film tersimpan',
              style: const TextStyle(
                color: Color(0xFF7A9BBF),
                fontSize: 12,
              ),
            ),
          ],
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
          // Hapus semua
          if (_favorites.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_rounded, color: Colors.red),
              onPressed: _clearAllFavorites,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF01B4E4)),
            )
          : _favorites.isEmpty
              ? _buildEmptyState()
              : _isGridView
                  ? _buildGridView()
                  : _buildListView(),
    );
  }

  // Empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: Color(0xFF1A3A5C),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              size: 52,
              color: Color(0xFF7A9BBF),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Belum ada film favorit',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap ❤️ di halaman detail\nuntuk menyimpan film',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF7A9BBF),
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF01B4E4),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text(
              'Jelajahi Film',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // Grid view
  Widget _buildGridView() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final movie = _favorites[index];
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
                // Poster + tombol hapus
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(12),
                      ),
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
                    // Tombol hapus
                    Positioned(
                      top: 6,
                      right: 6,
                      child: GestureDetector(
                        onTap: () => _removeFavorite(movie),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
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
                              color: Color(0xFF90CEA1), size: 12),
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
      padding: const EdgeInsets.all(16),
      itemCount: _favorites.length,
      itemBuilder: (context, index) {
        final movie = _favorites[index];
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
                    left: Radius.circular(12),
                  ),
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
                                color: Color(0xFF90CEA1), size: 13),
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
                // Tombol hapus
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: GestureDetector(
                    onTap: () => _removeFavorite(movie),
                    child: const Icon(
                      Icons.favorite_rounded,
                      color: Colors.red,
                      size: 22,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}