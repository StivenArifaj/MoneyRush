import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../core/services/supabase_service.dart';

class PlayerProvider extends ChangeNotifier {
  Map<String, dynamic>? _playerData;
  Map<String, dynamic>? _gameState;
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic>? get playerData => _playerData;
  Map<String, dynamic>? get gameState => _gameState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => SupabaseService.currentUser != null;
  String get username => (_playerData?['username'] as String?) ?? 'Player';

  Future<void> loadPlayer() async {
    final user = SupabaseService.currentUser;
    if (user == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _playerData = await SupabaseService.getPlayer(user.id);
      _gameState = await SupabaseService.getGameState(user.id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Returns null on success, error message on failure.
  Future<String?> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await SupabaseService.signUp(
        email: email,
        password: password,
        username: username,
      );

      if (response.user != null) {
        final userId = response.user!.id;
        await SupabaseService.createPlayerRecord(
            userId: userId, username: username);
        await SupabaseService.createGameState(userId);
        await SupabaseService.initKnowledgeMap(userId);
        await loadPlayer();
      }
      return null;
    } on AuthException catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = e.toString();
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Returns null on success, error message on failure.
  Future<String?> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await SupabaseService.signIn(email: email, password: password);
      await loadPlayer();
      return null;
    } on AuthException catch (e) {
      _error = e.message;
      return e.message;
    } catch (e) {
      _error = e.toString();
      return e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await SupabaseService.signOut();
    _playerData = null;
    _gameState = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
