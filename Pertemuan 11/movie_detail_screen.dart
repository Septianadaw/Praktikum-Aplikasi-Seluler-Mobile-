import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'movie_model.dart';
import 'favorites_manager.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _checkFavorite();
  }

  Future<void> _checkFavorite() async {
    final isFav = await FavoritesManager.isFavorite(widget.movie.id);
    setState(() => _isFavorite = isFav);
  }

  Future<void> _toggleFavorite() async {
    if (_isFavorite) {
      await FavoritesManager.removeFavorite(widget.movie.id);
    } else {
      await FavoritesManager.addFavorite(widget.movie);
    }
    setState(() => _isFavorite = !_isFavorite);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          content: Row(
            children: [
              Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                _isFavorite
                    ? 'Ditambahkan ke Favorites'
                    : 'Dihapus dari Favorites',
              ),
            ],
          ),
          backgroundColor: const Color(0xFF1A3A5C),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final movie = widget.movie;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // AppBar dengan backdrop
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            backgroundColor: const Color(0xFF0D253F),
            foregroundColor: Colors.white,
            actions: [
              IconButton(
                icon: Icon(
                  _isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: _isFavorite ? Colors.red : Colors.white,
                ),
                onPressed: _toggleFavorite,
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Backdrop
                  CachedNetworkImage(
                    imageUrl: movie.backdropPath.isNotEmpty
                        ? 'https://image.tmdb.org/t/p/w780${movie.backdropPath}'
                        : 'https://image.tmdb.org/t/p/w780${movie.posterPath}',
                    fit: BoxFit.cover,
                    placeholder: (_, __) =>
                        Container(color: const Color(0xFF1A3A5C)),
                    errorWidget: (_, __, ___) =>
                        Container(color: const Color(0xFF1A3A5C)),
                  ),
                  // Gradient
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Color(0xCC0D253F),
                          Color(0xFF0D253F),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Konten
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Poster + Info
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Poster
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: CachedNetworkImage(
                          imageUrl:
                              'https://image.tmdb.org/t/p/w342${movie.posterPath}',
                          width: 100,
                          height: 150,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            width: 100,
                            height: 150,
                            color: const Color(0xFF1A3A5C),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            width: 100,
                            height: 150,
                            color: const Color(0xFF1A3A5C),
                            child: const Icon(Icons.movie,
                                color: Colors.grey),
                          ),
                        ),
                      ),

                      const SizedBox(width: 14),

                      // Info
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Judul
                            Text(
                              movie.title,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                height: 1.3,
                              ),
                            ),

                            const SizedBox(height: 10),

                            // Rating
                            Row(
                              children: [
                                const Icon(Icons.star_rounded,
                                    color: Color(0xFF90CEA1), size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  '${movie.voteAverage.toStringAsFixed(1)} / 10',
                                  style: const TextStyle(
                                    color: Color(0xFF90CEA1),
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Tanggal rilis
                            Row(
                              children: [
                                const Icon(Icons.calendar_today_rounded,
                                    color: Color(0xFF7A9BBF), size: 13),
                                const SizedBox(width: 6),
                                Text(
                                  movie.releaseDate,
                                  style: const TextStyle(
                                    color: Color(0xFF7A9BBF),
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Genre chips
                            Wrap(
                              spacing: 6,
                              runSpacing: 6,
                              children: movie.genreNames.map((genre) {
                                return Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF01B4E4)
                                        .withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(0xFF01B4E4)
                                          .withOpacity(0.4),
                                    ),
                                  ),
                                  child: Text(
                                    genre,
                                    style: const TextStyle(
                                      color: Color(0xFF01B4E4),
                                      fontSize: 11,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Tombol Favorite
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _toggleFavorite,
                      icon: Icon(
                        _isFavorite
                            ? Icons.favorite
                            : Icons.favorite_border,
                        size: 18,
                      ),
                      label: Text(
                        _isFavorite
                            ? 'Hapus dari Favorites'
                            : 'Tambah ke Favorites',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isFavorite
                            ? Colors.red.shade800
                            : const Color(0xFF01B4E4),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Divider
                  const Divider(color: Color(0xFF1A3A5C)),

                  const SizedBox(height: 16),

                  // Sinopsis
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    movie.overview.isNotEmpty
                        ? movie.overview
                        : 'Deskripsi tidak tersedia.',
                    style: const TextStyle(
                      color: Color(0xFF7A9BBF),
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}