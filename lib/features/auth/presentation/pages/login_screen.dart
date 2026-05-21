import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
      setState(
          () => _errorMessage = 'Mot de passe : 6 caractères minimum.');
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
    // BlocListener écoute les changements d'état
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthErrorState) {
          if (mounted) setState(() => _errorMessage = state.message);
        } else if (state is AuthLoading) {
          if (mounted) setState(() => _errorMessage = null);
        }
      },
      // BlocBuilder reconstruit le widget selon l'état
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Scaffold(
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    const Icon(Icons.quiz,
                        size: 72, color: Colors.deepPurple),
                    const SizedBox(height: 12),
                    const Text(
                      'Trivia App',
                      style: TextStyle(
                          fontSize: 30, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    TabBar(
                      controller: _tabController,
                      tabs: const [
                        Tab(text: 'Connexion'),
                        Tab(text: 'Inscription'),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Bloc d'erreur visible
                    if (_errorMessage != null)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border:
                              Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline,
                                color: Colors.red.shade700, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                    color: Colors.red.shade700,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => setState(
                                  () => _errorMessage = null),
                              child: Icon(Icons.close,
                                  color: Colors.red.shade700,
                                  size: 18),
                            ),
                          ],
                        ),
                      ),

                    // Contenu des onglets
                    SizedBox(
                      height: 320,
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
          );
        },
      ),
    );
  }

  Widget _buildSignIn(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _emailCtrl,
          onChanged: (_) =>
              setState(() => _errorMessage = null),
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscureIn,
          onChanged: (_) =>
              setState(() => _errorMessage = null),
          decoration: InputDecoration(
            labelText: 'Mot de passe',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureIn
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () =>
                  setState(() => _obscureIn = !_obscureIn),
            ),
          ),
          onSubmitted: (_) => _signIn(context),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isLoading ? null : () => _signIn(context),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Se connecter',
                  style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildSignUp(BuildContext context, bool isLoading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 12),
        TextField(
          controller: _pseudoCtrl,
          onChanged: (_) =>
              setState(() => _errorMessage = null),
          decoration: const InputDecoration(
            labelText: 'Pseudo',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _emailSignUpCtrl,
          onChanged: (_) =>
              setState(() => _errorMessage = null),
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email_outlined),
          ),
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 14),
        TextField(
          controller: _passwordSignUpCtrl,
          obscureText: _obscureUp,
          onChanged: (_) =>
              setState(() => _errorMessage = null),
          decoration: InputDecoration(
            labelText: 'Mot de passe (min. 6 caractères)',
            border: const OutlineInputBorder(),
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscureUp
                  ? Icons.visibility
                  : Icons.visibility_off),
              onPressed: () =>
                  setState(() => _obscureUp = !_obscureUp),
            ),
          ),
          onSubmitted: (_) => _signUp(context),
        ),
        const SizedBox(height: 24),
        FilledButton(
          onPressed: isLoading ? null : () => _signUp(context),
          style: FilledButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14)),
          child: isLoading
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text("S'inscrire",
                  style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }
}