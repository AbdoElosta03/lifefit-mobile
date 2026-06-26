import 'profile_user.dart';
import 'client_profile_data.dart';
import 'current_body_stats.dart';

/// Root response from GET/PUT `/api/client/profile`.
//root for profile bundle contains user, profile, and current stats
class ClientProfileBundle {
  final ProfileUser user; //user details
  final ClientProfileData profile; //profile details
  final CurrentBodyStats currentStats; //current body stats

  const ClientProfileBundle({
    required this.user,
    required this.profile,
    required this.currentStats,
  });

  factory ClientProfileBundle.fromJson(Map<String, dynamic> json) {
    return ClientProfileBundle(
      user: ProfileUser.fromJson(
        Map<String, dynamic>.from(json['user'] as Map? ?? {}),
      ),
      profile: ClientProfileData.fromJson(
        Map<String, dynamic>.from(json['profile'] as Map? ?? {}),
      ),
      currentStats: CurrentBodyStats.fromJson(
        Map<String, dynamic>.from(json['current_stats'] as Map? ?? {}),
      ),
    );
  }
}
