class Experts {
  String? name;
  String? bio;
  String? avatarUrl;
  String? type;
  int? yearsExperience;
  String? certifications;

  Experts({
    this.name,
    this.bio,
    this.avatarUrl,
    this.type,
    this.yearsExperience,
    this.certifications,
  });

  factory Experts.fromJson(Map<String, dynamic> json) {
    return Experts(
      name: json['name'] as String?,
      bio: json['bio'] as String?,
      avatarUrl: json['avatar'] as String?,
      type: json['type'] as String?,
      yearsExperience: json['years_experience'] as int?,
      certifications: json['certifications'] as String?,
    );
  }
}
