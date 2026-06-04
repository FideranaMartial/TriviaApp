import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../../category/domain/entities/category.dart';
import '../cubit/category_cubit.dart';
import '../cubit/category_state.dart';
import '../../../game/presentation/pages/game_screen.dart';
import '../../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<CategoryCubit>()..loadCategories(),
      child: const _HomeView(),
    );
  }
}

class _HomeView extends StatelessWidget {
  const _HomeView();

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthBloc>().state;
    final pseudo = authState is AuthenticatedState
        ? authState.player.pseudo
        : '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          'Bonjour, $pseudo !',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // ── Bouton Déconnexion ─────────────────────────────────
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => context.read<AuthBloc>().add(SignOutEvent()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.primaryGradient),
        child: SafeArea(
          child: BlocBuilder<CategoryCubit, CategoryState>(
            builder: (context, state) {
              if (state is CategoryLoading || state is CategoryInitial) {
                return const Center(child: _AnimatedLoader());
              }
              if (state is CategoryError) {
                return _buildErrorWidget(context, state.message);
              }
              if (state is CategoryLoaded) {
                return _buildCategoryGrid(state.categories);
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryGrid(List<Category> categories) {
    return Padding(
      padding: const EdgeInsets.only(top: 80),
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.0,
        ),
        itemCount: categories.length,
        itemBuilder: (_, i) => _CategoryCard(category: categories[i]),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              gradient: AppTheme.errorGradient,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.error_outline,
              size: 50,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => context.read<CategoryCubit>().loadCategories(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text('Réessayer'),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Retourne l'icône Material qui correspond au nom de la catégorie.
// La comparaison est insensible à la casse.
// Ajoute / modifie des entrées selon les catégories de ta base de données.
// ─────────────────────────────────────────────────────────────────────────────
IconData _iconForCategory(String name) {
  final key = name.toLowerCase().trim();
  final map = <String, IconData>{
    // Sciences
    'science': Icons.science_rounded,
    'sciences': Icons.science_rounded,
    'biologie': Icons.biotech_rounded,
    'physique': Icons.electric_bolt_rounded,
    'chimie': Icons.water_drop_rounded,
    'mathématiques': Icons.calculate_rounded,
    'maths': Icons.calculate_rounded,
    'astronomie': Icons.nights_stay_rounded,
    'espace': Icons.rocket_launch_rounded,
    'informatique': Icons.computer_rounded,
    'technologie': Icons.developer_board_rounded,
    'électronique': Icons.memory_rounded,
    'robotique': Icons.smart_toy_rounded,
    'intelligence artificielle': Icons.psychology_rounded,
    'ia': Icons.psychology_rounded,

    // Culture générale & humanités
    'histoire': Icons.menu_book_rounded,
    'géographie': Icons.public_rounded,
    'politique': Icons.account_balance_rounded,
    'économie': Icons.trending_up_rounded,
    'philosophie': Icons.lightbulb_rounded,
    'religion': Icons.temple_hindu_rounded,
    'mythologie': Icons.shield_rounded,
    'archéologie': Icons.explore_rounded,

    // Arts & divertissement
    'cinéma': Icons.movie_rounded,
    'film': Icons.movie_rounded,
    'films': Icons.movie_rounded,
    'musique': Icons.music_note_rounded,
    'art': Icons.palette_rounded,
    'arts': Icons.palette_rounded,
    'peinture': Icons.brush_rounded,
    'sculpture': Icons.format_shapes_rounded,
    'architecture': Icons.domain_rounded,
    'photographie': Icons.photo_camera_rounded,
    'danse': Icons.directions_walk_rounded,
    'théâtre': Icons.theater_comedy_rounded,
    'littérature': Icons.auto_stories_rounded,
    'livres': Icons.library_books_rounded,
    'manga': Icons.import_contacts_rounded,
    'animation': Icons.animation_rounded,
    'dessin animé': Icons.animation_rounded,
    'série': Icons.live_tv_rounded,
    'séries': Icons.live_tv_rounded,
    'télévision': Icons.tv_rounded,
    'podcast': Icons.podcasts_rounded,

    // Jeux
    'jeux vidéo': Icons.sports_esports_rounded,
    'jeu vidéo': Icons.sports_esports_rounded,
    'gaming': Icons.sports_esports_rounded,
    'jeux de société': Icons.casino_rounded,
    'échecs': Icons.grid_on_rounded,

    // Mode & lifestyle
    'mode': Icons.checkroom_rounded,
    'cuisine': Icons.restaurant_rounded,
    'gastronomie': Icons.restaurant_rounded,
    'nourriture': Icons.fastfood_rounded,
    'boissons': Icons.local_drink_rounded,
    'voyage': Icons.flight_rounded,
    'tourisme': Icons.luggage_rounded,
    'automobile': Icons.directions_car_rounded,
    'voiture': Icons.directions_car_rounded,

    // Sport
    'sport': Icons.sports_rounded,
    'football': Icons.sports_soccer_rounded,
    'basketball': Icons.sports_basketball_rounded,
    'tennis': Icons.sports_tennis_rounded,
    'natation': Icons.pool_rounded,
    'athlétisme': Icons.directions_run_rounded,
    'cyclisme': Icons.directions_bike_rounded,
    'formule 1': Icons.speed_rounded,
    'f1': Icons.speed_rounded,
    'rugby': Icons.sports_rugby_rounded,
    'golf': Icons.golf_course_rounded,
    'boxe': Icons.sports_mma_rounded,
    'arts martiaux': Icons.sports_martial_arts_rounded,
    'ski': Icons.downhill_skiing_rounded,
    'surf': Icons.surfing_rounded,
    'escalade': Icons.hiking_rounded,

    // Nature & environnement
    'nature': Icons.park_rounded,
    'animaux': Icons.pets_rounded,
    'environnement': Icons.eco_rounded,
    'océan': Icons.waves_rounded,
    'mer': Icons.waves_rounded,
    'météo': Icons.wb_sunny_rounded,
    'climat': Icons.thermostat_rounded,

    // Santé & sciences humaines
    'médecine': Icons.medical_services_rounded,
    'santé': Icons.favorite_rounded,
    'psychologie': Icons.psychology_alt_rounded,
    'sociologie': Icons.group_rounded,

    // Langues
    'langue': Icons.translate_rounded,
    'langues': Icons.translate_rounded,
    'linguistique': Icons.spellcheck_rounded,
  };

  // Recherche exacte d'abord
  if (map.containsKey(key)) return map[key]!;

  // Recherche partielle : si le nom de catégorie contient un mot-clé connu
  for (final entry in map.entries) {
    if (key.contains(entry.key) || entry.key.contains(key)) {
      return entry.value;
    }
  }

  // Fallback
  return Icons.quiz_rounded;
}

// ─────────────────────────────────────────────────────────────────────────────

class _AnimatedLoader extends StatelessWidget {
  const _AnimatedLoader();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.4),
                  blurRadius: 20,
                ),
              ],
            ),
            child: const SizedBox(
              height: 40,
              width: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: Colors.white,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  const _CategoryCard({required this.category});

  Color get _color =>
      Color(int.parse(category.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: GestureDetector(
            onTap: () => _showDifficultyDialog(context),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_color.withOpacity(0.15), _color.withOpacity(0.05)],
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: _color.withOpacity(0.4), width: 2),
                boxShadow: [
                  BoxShadow(
                    color: _color.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _buildAnimatedIcon(_color),
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      category.name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: _color,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedIcon(Color color) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [color, color.withOpacity(0.6)]),
              shape: BoxShape.circle,
            ),
            // ── Icône dynamique selon la catégorie ───────────────
            child: Icon(
              _iconForCategory(category.name),
              color: Colors.white,
              size: 36,
            ),
          ),
        );
      },
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => _DifficultyDialog(category: category, color: _color),
    );
  }
}

class _DifficultyDialog extends StatelessWidget {
  final Category category;
  final Color color;

  const _DifficultyDialog({required this.category, required this.color});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: color.withOpacity(0.5), width: 2),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(_iconForCategory(category.name), color: color, size: 22),
                  const SizedBox(width: 8),
                  Text(
                    category.name,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _DifficultyTile(
              label: 'Facile',
              emoji: '🟢',
              diff: 'easy',
              category: category,
              color: Colors.green,
            ),
            _DifficultyTile(
              label: 'Moyen',
              emoji: '🟡',
              diff: 'medium',
              category: category,
              color: Colors.orange,
            ),
            _DifficultyTile(
              label: 'Difficile',
              emoji: '🔴',
              diff: 'hard',
              category: category,
              color: Colors.red,
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String label;
  final String emoji;
  final String diff;
  final Category category;
  final Color color;

  const _DifficultyTile({
    required this.label,
    required this.emoji,
    required this.diff,
    required this.category,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.2),
          shape: BoxShape.circle,
        ),
        child: Text(emoji, style: const TextStyle(fontSize: 20)),
      ),
      title: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
          fontSize: 16,
        ),
      ),
      trailing: Icon(Icons.chevron_right, color: color.withOpacity(0.7)),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(category: category, difficulty: diff),
          ),
        );
      },
    );
  }
}
