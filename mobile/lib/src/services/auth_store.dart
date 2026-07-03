import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthStore extends ChangeNotifier {
  static const _tokenKey = 'auth_token';
  static const _emailKey = 'auth_email';
  static const _nameKey = 'auth_name';
  static const _bioKey = 'auth_bio';
  static const _isAdminKey = 'auth_is_admin';
  static const _onboardingSeenKey = 'onboarding_seen';
  static const _notificationPromptSeenKey = 'notification_prompt_seen';

  String? token;
  String? email;
  String? name;
  String? bio;
  bool isAdmin = false;
  bool onboardingSeen = false;
  bool notificationPromptSeen = false;

  bool get isAuthenticated => token != null && token!.isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString(_tokenKey);
    email = prefs.getString(_emailKey);
    name = prefs.getString(_nameKey);
    bio = prefs.getString(_bioKey);
    isAdmin = prefs.getBool(_isAdminKey) ?? false;
    onboardingSeen = prefs.getBool(_onboardingSeenKey) ?? false;
    notificationPromptSeen = prefs.getBool(_notificationPromptSeenKey) ?? false;
    notifyListeners();
  }

  Future<void> save({
    required String tokenValue,
    required String emailValue,
    required bool isAdminValue,
    String? nameValue,
    String? bioValue,
  }) async {
    token = tokenValue;
    email = emailValue;
    name = nameValue ?? '';
    bio = bioValue ?? '';
    isAdmin = isAdminValue;
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, tokenValue);
    await prefs.setString(_emailKey, emailValue);
    await prefs.setString(_nameKey, name ?? '');
    await prefs.setString(_bioKey, bio ?? '');
    await prefs.setBool(_isAdminKey, isAdminValue);
    notifyListeners();
  }
  
  Future<void> updateProfile({required String newName, required String newBio}) async {
    name = newName;
    bio = newBio;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_nameKey, newName);
    await prefs.setString(_bioKey, newBio);
    notifyListeners();
  }

  Future<void> markOnboardingSeen() async {
    onboardingSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingSeenKey, true);
    notifyListeners();
  }

  Future<void> markNotificationPromptSeen() async {
    notificationPromptSeen = true;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationPromptSeenKey, true);
    notifyListeners();
  }

  Future<void> clear() async {
    token = null;
    email = null;
    name = null;
    bio = null;
    isAdmin = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_emailKey);
    await prefs.remove(_nameKey);
    await prefs.remove(_bioKey);
    await prefs.remove(_isAdminKey);
    await prefs.remove(_onboardingSeenKey);
    await prefs.remove(_notificationPromptSeenKey);
    notifyListeners();
  }
}
