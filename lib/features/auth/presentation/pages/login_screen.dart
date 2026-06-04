import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';
import '../../../../core/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _pseudoCtrl = TextEditingController();
  final _emailSignUpCtrl = TextEditingController();
  final _passwordSignUpCtrl = TextEditingController();
  bool _obscureIn = true;
  bool _obscureUp = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() => _errorMessage = null);
    });

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _pseudoCtrl.dispose();
    _emailSignUpCtrl.dispose();
    _passwordSignUpCtrl.dispose();
    super.dispose();
  }

  void _signIn(BuildContext context) {
    setState(() => _errorMessage = null);

    if (_emailCtrl.text.trim().isEmpty || _passwordCtrl.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }
    if (!_emailCtrl.text.contains('@')) {
      setState(() => _errorMessage = 'Adresse email invalide.');
      return;
    }

    context.read<AuthBloc>().add(
      SignInEvent(email: _emailCtrl.text.trim(), password: _passwordCtrl.text),
    );
  }

  void _signUp(BuildContext context) {
    setState(() => _errorMessage = null);

    if (_pseudoCtrl.text.trim().isEmpty ||
        _emailSignUpCtrl.text.trim().isEmpty ||
        _passwordSignUpCtrl.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }
    if (!_emailSignUpCtrl.text.contains('@')) {
      setState(() => _errorMessage = 'Adresse email invalide.');
      return;
    }
    if (_passwordSignUpCtrl.text.length < 6) {
      setState(() => _errorMessage = 'Mot de passe : 6 caractères minimum.');
      return;
    }

    context.read<AuthBloc>().add(
      SignUpEvent(
        email: _emailSignUpCtrl.text.trim(),
        password: _passwordSignUpCtrl.text,
        pseudo: _pseudoCtrl.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          if (mounted) setState(() => _errorMessage = state.message);
        } else if (state is AuthLoading) {
          if (mounted) setState(() => _errorMessage = null);
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            body: Container(
              decoration: BoxDecoration(gradient: AppTheme.primaryGradient),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Column(
                            children: [
                              const SizedBox(height: 40),
                              _buildAnimatedLogo(),
                              const SizedBox(height: 24),
                              _buildGlassContainer(isLoading),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedLogo() {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 600),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: AppTheme.secondaryGradient,
              boxShadow: [
                BoxShadow(
                  color: Color(
                    0xFF7C3AED,
                  ).withOpacity(0.4), // violet au lieu de deepPurple
                  blurRadius: 30,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.quiz_rounded,
              size: 60,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }

  Widget _buildGlassContainer(bool isLoading) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.1),
            Colors.white.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                gradient: AppTheme.secondaryGradient, // orange
                borderRadius: BorderRadius.circular(30),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white70,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              tabs: const [
                Tab(text: 'Connexion'),
                Tab(text: 'Inscription'),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  if (_errorMessage != null) _buildErrorWidget(),
                  SizedBox(
                    height: 380,
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildSignIn(isLoading),
                        _buildSignUp(isLoading),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: AppTheme.errorGradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.red.withOpacity(0.3), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          GestureDetector(
            onTap: () => setState(() => _errorMessage = null),
            child: const Icon(Icons.close, color: Colors.white, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSignIn(bool isLoading) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          onChanged: (_) => setState(() => _errorMessage = null),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscureIn,
          onChanged: (_) => setState(() => _errorMessage = null),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureIn ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscureIn = !_obscureIn),
            ),
          ),
          onSubmitted: (_) => _signIn(context),
        ),
        const SizedBox(height: 28),
        _buildAnimatedButton(
          onPressed: isLoading ? null : () => _signIn(context),
          text: 'Se connecter',
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildSignUp(bool isLoading) {
    return Column(
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _pseudoCtrl,
          onChanged: (_) => setState(() => _errorMessage = null),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Pseudo',
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.person_outline, color: Colors.white70),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _emailSignUpCtrl,
          onChanged: (_) => setState(() => _errorMessage = null),
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Email',
            labelStyle: TextStyle(color: Colors.white70),
            prefixIcon: Icon(Icons.email_outlined, color: Colors.white70),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _passwordSignUpCtrl,
          obscureText: _obscureUp,
          onChanged: (_) => setState(() => _errorMessage = null),
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: 'Mot de passe (min. 6 caractères)',
            labelStyle: const TextStyle(color: Colors.white70),
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.white70),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureUp ? Icons.visibility : Icons.visibility_off,
                color: Colors.white70,
              ),
              onPressed: () => setState(() => _obscureUp = !_obscureUp),
            ),
          ),
          onSubmitted: (_) => _signUp(context),
        ),
        const SizedBox(height: 28),
        _buildAnimatedButton(
          onPressed: isLoading ? null : () => _signUp(context),
          text: "S'inscrire",
          isLoading: isLoading,
        ),
      ],
    );
  }

  Widget _buildAnimatedButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isLoading,
  }) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 400),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: Container(
            decoration: BoxDecoration(
              gradient: AppTheme.secondaryGradient, // orange
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFFF97316).withOpacity(0.4),
                  blurRadius: 15,
                ),
              ],
            ),
            child: ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      text,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        );
      },
    );
  }
}
