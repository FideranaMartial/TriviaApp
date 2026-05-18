import 'package:equatable/equatable.dart';
import '../../domain/entities/player.dart';

abstract class AuthState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class OtpSentState extends AuthState {
  final String email;
   OtpSentState(this.email);
  @override
  List<Object?> get props => [email];
}

class AuthenticatedState extends AuthState {
  final Player player;
   AuthenticatedState(this.player);
  @override
  List<Object?> get props => [player];
}

class UnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String message;
   AuthErrorState(this.message);
  @override
  List<Object?> get props => [message];
}