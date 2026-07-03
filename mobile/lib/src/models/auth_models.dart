class AuthResponse {
  AuthResponse({
    required this.userId,
    required this.email,
    required this.isAdmin,
    required this.accessToken,
    this.name = '',
    this.bio = '',
  });

  final int userId;
  final String email;
  final bool isAdmin;
  final String accessToken;
  final String name;
  final String bio;

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return AuthResponse(
      userId: user['id'] as int,
      email: user['email'] as String,
      isAdmin: user['is_admin'] as bool? ?? false,
      accessToken: json['access_token'] as String? ?? '',
      name: user['name'] as String? ?? '',
      bio: user['bio'] as String? ?? '',
    );
  }
}

class UserProfile {
  UserProfile({
    required this.name,
    required this.bio,
  });

  final String name;
  final String bio;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>;
    return UserProfile(
      name: user['name'] as String? ?? '',
      bio: user['bio'] as String? ?? '',
    );
  }
}
