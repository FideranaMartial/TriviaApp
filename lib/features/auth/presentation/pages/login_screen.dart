import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_theme.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _emailCtrl          = TextEditingController();
  final _passwordCtrl       = TextEditingController();
  final _pseudoCtrl         = TextEditingController();
  final _emailSignUpCtrl    = TextEditingController();
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
  }

  @override
  void dispose() {
    _tabController.dispose();
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
    context.read<AuthBloc>().add(SignInEvent(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    ));
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
      setState(() =>
          _errorMessage = 'Mot de passe : 6 caractères minimum.');
      return;
    }
    context.read<AuthBloc>().add(SignUpEvent(
      email: _emailSignUpCtrl.text.trim(),
      password: _passwordSignUpCtrl.text,
      pseudo: _pseudoCtrl.text.trim(),
    ));
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
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF2D1B69),
                    Color(0xFF1A1A2E),
                  ],
                ),
              ),
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),
                      // Logo
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: AppColors.primary, width: 2),
                        ),
                        child: const Icon(Icons.quiz,
                            size: 48, color: AppColors.orange),
                      ),
                      const SizedBox(height: 16),
                      const Text('Trivia App',
                          style: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary)),
                      const SizedBox(height: 6),
                      const Text('Testez vos connaissances !',
                          style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textSecondary)),
                      const SizedBox(height: 32),

                      // Tabs
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tabs: const [
                            Tab(text: 'Connexion'),
                            Tab(text: 'Inscription'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Erreur
                      if (_errorMessage != null)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppColors.wrong.withOpacity(0.15),
                            border: Border.all(
                                color: AppColors.wrong.withOpacity(0.5)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline,
                                  color: AppColors.wrong, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(_errorMessage!,
                                    style: const TextStyle(
                                        color: AppColors.wrong,
                                        fontSize: 13)),
                              ),
                              GestureDetector(
                                onTap: () => setState(
                                    () => _errorMessage = null),
                                child: const Icon(Icons.close,
                                    color: AppColors.wrong, size: 18),
                              ),
                            ],
                          ),
                        ),

                      SizedBox(
                        height: 340,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildSignIn(context, isLoading),
                            _buildSignUp(context, isLoading),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _buildTextField(
          controller: _emailCtrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        _buildTextField(
          controller: _passwordCtrl,
          label: 'Mot de passe',
          icon: Icons.lock_outline,
          obscure: _obscureIn,
          toggleObscure: () =>
              setState(() => _obscureIn = !_obscureIn),
          onSubmitted: (_) => _signIn(context),
        ),
        const SizedBox(height: 28),
        _buildButton(
          label: 'Se connecter',
          isLoading: isLoading,
          onPressed: () => _signIn(context),
        ),
      ],
    );
  }

  Widget _buildSignUp(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 8),
        _buildTextField(
          controller: _pseudoCtrl,
          label: 'Pseudo',
          icon: Icons.person_outline,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emailSignUpCtrl,
          label: 'Email',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _passwordSignUpCtrl,
          label: 'Mot de passe (min. 6 caractères)',
          icon: Icons.lock_outline,
          obscure: _obscureUp,
          toggleObscure: () =>
              setState(() => _obscureUp = !_obscureUp),
          onSubmitted: (_) => _signUp(context),
        ),
        const SizedBox(height: 24),
        _buildButton(
          label: "S'inscrire",
          isLoading: isLoading,
          onPressed: () => _signUp(context),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscure = false,
    VoidCallback? toggleObscure,
    TextInputType keyboardType = TextInputType.text,
    ValueChanged<String>? onSubmitted,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      onSubmitted: onSubmitted,
      onChanged: (_) => setState(() => _errorMessage = null),
      style: const TextStyle(color: AppColors.textPrimary),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility : Icons.visibility_off,
                  color: AppColors.textSecondary,
                ),
                onPressed: toggleObscure,
              )
            : null,
      ),
    );
  }

  Widget _buildButton({
    required String label,
    required bool isLoading,
    required VoidCallback onPressed,
  }) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label),
      ),
    );
  }
}