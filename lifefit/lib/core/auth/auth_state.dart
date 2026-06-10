import '../models/user.dart';

/// Immutable snapshot consumed by routing, drawer, and auth screens.
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

  /// Derived from [user]; token alone does not count as authenticated until restore completes.
  bool get isAuthenticated => user != null;

  /// Pass [clearUser: true] to log out without replacing other fields individually.
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
