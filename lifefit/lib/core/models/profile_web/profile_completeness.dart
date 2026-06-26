import 'client_profile_bundle.dart';

/// Whether the client still needs first-time profile setup.

/// Extension is used to add a method or attribute with out modifying the original class.


extension ProfileCompleteness on ClientProfileBundle {
  bool get needsOnboarding {
    final birth = profile.birthDate?.trim();
    final notes = profile.goalNotes?.trim();

    return birth == null ||
        birth.isEmpty ||
        profile.heightCm == null ||
        currentStats.weightKg == null ||
        notes == null ||
        notes.isEmpty;
  }
}
