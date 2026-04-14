import '../models/user.dart';

class AuthState {
  /// True until [AuthNotifier.restoreSession] finishes (cold start / secure storage check).
  final bool isInitializing;
  final bool isLoading;
  final String? errorMessage;
  final User? user;

  const AuthState({
    this.isInitializing = true,
    this.isLoading = false,
    this.errorMessage,
    this.user,
  });

  bool get isAuthenticated => user != null;

  AuthState copyWith({
    bool? isInitializing,
    bool? isLoading,
    String? errorMessage,
    User? user,
    bool clearUser = false,
  }) {
    return AuthState(
      isInitializing: isInitializing ?? this.isInitializing,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      user: clearUser ? null : (user ?? this.user),
    );
  }
}
