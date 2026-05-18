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
      appBar: AppBar(
        title: Text('Bonjour, $pseudo !'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Se déconnecter',
            onPressed: () =>
                context.read<AuthBloc>().add(SignOutEvent()),
          ),
        ],
      ),
      body: BlocBuilder<CategoryCubit, CategoryState>(
        builder: (context, state) {
          if (state is CategoryLoading || state is CategoryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is CategoryError) {
            return Center(child: Text(state.message));
          }
          if (state is CategoryLoaded) {
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.1,
              ),
              itemCount: state.categories.length,
              itemBuilder: (_, i) =>
                  _CategoryCard(category: state.categories[i]),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _CategoryCard extends StatelessWidget {
  final Category category;
  const _CategoryCard({required this.category});

  Color get _color => Color(
      int.parse(category.colorHex.replaceFirst('#', '0xFF')));

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDifficultyDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: _color.withOpacity(0.1),
          border: Border.all(color: _color, width: 1.5),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.quiz, color: _color, size: 44),
            const SizedBox(height: 10),
            Text(
              category.name,
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: _color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showDifficultyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(category.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DifficultyTile(
              label: '🟢  Facile',
              diff: 'easy',
              category: category,
            ),
            _DifficultyTile(
              label: '🟡  Moyen',
              diff: 'medium',
              category: category,
            ),
            _DifficultyTile(
              label: '🔴  Difficile',
              diff: 'hard',
              category: category,
            ),
          ],
        ),
      ),
    );
  }
}

class _DifficultyTile extends StatelessWidget {
  final String label;
  final String diff;
  final Category category;
  const _DifficultyTile({
    required this.label,
    required this.diff,
    required this.category,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(label),
      onTap: () {
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => GameScreen(
              category: category,
              difficulty: diff,
            ),
          ),
        );
      },
    );
  }
}