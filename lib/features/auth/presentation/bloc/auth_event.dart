import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class CheckAuthEvent extends AuthEvent {}

class SignInEvent extends AuthEvent {
  final String email;
  final String password;
  SignInEvent({required this.email, required this.password});
  @override
  List<Object?> get props => [email];
}

class SignUpEvent extends AuthEvent {
  final String email;
  final String password;
  final String pseudo;
  SignUpEvent({
    required this.email,
    required this.password,
    required this.pseudo,
  });
  @override
  List<Object?> get props => [email, pseudo];
}

class SignOutEvent extends AuthEvent {}