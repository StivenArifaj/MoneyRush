import 'package:supabase_flutter/supabase_flutter.dart';

// All Supabase interactions are funneled through this class.
// No screen or widget may call Supabase directly.
class SupabaseService {
  static SupabaseClient get _client => Supabase.instance.client;

  // ─── Auth ──────────────────────────────────────────────────────────────────

  static Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {'username': username},
    );
    return response;
  }

  static Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  static Future<void> signOut() async {
    await _client.auth.signOut();
  }

  static User? get currentUser => _client.auth.currentUser;

  static Session? get currentSession => _client.auth.currentSession;

  static Stream<AuthState> get authStateChanges =>
      _client.auth.onAuthStateChange;

  // ─── Player ────────────────────────────────────────────────────────────────

  static Future<void> createPlayerRecord({
    required String userId,
    required String username,
  }) async {
    await _client.from('players').insert({
      'id': userId,
      'username': username,
    });
  }

  static Future<Map<String, dynamic>?> getPlayer(String userId) async {
    final data = await _client
        .from('players')
        .select()
        .eq('id', userId)
        .maybeSingle();
    return data;
  }

  // ─── Game State ────────────────────────────────────────────────────────────

  static Future<void> createGameState(String userId) async {
    await _client.from('game_states').insert({'player_id': userId});
  }

  static Future<Map<String, dynamic>?> getGameState(String userId) async {
    final data = await _client
        .from('game_states')
        .select()
        .eq('player_id', userId)
        .maybeSingle();
    return data;
  }

  static Future<void> updateGameState({
    required String userId,
    required Map<String, dynamic> updates,
  }) async {
    await _client
        .from('game_states')
        .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
        .eq('player_id', userId);
  }

  // ─── Knowledge Map ─────────────────────────────────────────────────────────

  static Future<void> initKnowledgeMap(String userId) async {
    const domains = [
      'budgeting', 'saving', 'credit', 'interest', 'investing',
      'risk_insurance', 'tax', 'career_income', 'retirement',
      'entrepreneurship', 'digital_economy',
    ];
    final rows = domains.map((d) => {
      'player_id': userId,
      'domain': d,
      'score': 0,
    }).toList();
    await _client.from('knowledge_maps').upsert(rows);
  }

  static Future<List<Map<String, dynamic>>> getKnowledgeMap(
      String userId) async {
    final data = await _client
        .from('knowledge_maps')
        .select()
        .eq('player_id', userId);
    return List<Map<String, dynamic>>.from(data);
  }

  static Future<void> updateKnowledgeScore({
    required String userId,
    required String domain,
    required int score,
  }) async {
    await _client.from('knowledge_maps').upsert({
      'player_id': userId,
      'domain': domain,
      'score': score.clamp(0, 100),
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // ─── Scenarios ─────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getNextScenario({
    required String userId,
    required int currentChapter,
    required List<String> weakDomains,
  }) async {
    // Falls back to any domain if weak-domain filter returns nothing
    var query = _client
        .from('scenarios')
        .select()
        .lte('chapter', currentChapter)
        .eq('is_active', true);

    if (weakDomains.isNotEmpty) {
      query = query.inFilter('domain', weakDomains);
    }

    final data = await query.limit(20);
    if (data.isEmpty) return null;

    // Exclude scenarios already seen and not yet due for review
    final seen = await _client
        .from('player_scenarios')
        .select('scenario_id')
        .eq('player_id', userId)
        .gt('next_review_at', DateTime.now().toIso8601String());

    final seenIds =
        (seen as List).map((r) => r['scenario_id'] as String).toSet();

    final unseen = (data as List)
        .where((s) => !seenIds.contains(s['id']))
        .toList();

    if (unseen.isEmpty) return data.isNotEmpty ? data.first : null;

    unseen.shuffle();
    return Map<String, dynamic>.from(unseen.first);
  }

  static Future<void> recordDecision({
    required String userId,
    required String scenarioId,
    required int choiceIndex,
    required bool wasOptimal,
    required Map<String, dynamic> financialImpact,
    required DateTime inGameDate,
  }) async {
    await _client.from('decision_log').insert({
      'player_id': userId,
      'scenario_id': scenarioId,
      'choice_index': choiceIndex,
      'was_optimal': wasOptimal,
      'financial_impact': financialImpact,
      'in_game_date': inGameDate.toIso8601String().split('T').first,
    });
  }

  static Future<void> upsertPlayerScenario({
    required String userId,
    required String scenarioId,
    required int choiceIndex,
    required bool wasOptimal,
    required double easeFactor,
    required int intervalDays,
  }) async {
    final nextReview = DateTime.now().add(Duration(days: intervalDays));
    await _client.from('player_scenarios').upsert({
      'player_id': userId,
      'scenario_id': scenarioId,
      'choice_index': choiceIndex,
      'was_optimal': wasOptimal,
      'ease_factor': easeFactor,
      'interval_days': intervalDays,
      'next_review_at': nextReview.toIso8601String(),
    });
  }

  // ─── Knowledge Base (RAG) ──────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getRelevantKnowledgeEntry(
      List<String> conceptTags) async {
    if (conceptTags.isEmpty) return null;
    final data = await _client
        .from('knowledge_entries')
        .select()
        .overlaps('domain', conceptTags)
        .limit(1)
        .maybeSingle();
    return data;
  }

  // ─── Health Check ──────────────────────────────────────────────────────────

  static Future<bool> testConnection() async {
    try {
      // Auth service responds even before schema is deployed.
      await _client.from('players').select('id').limit(0);
      return true;
    } catch (_) {
      return false;
    }
  }
}
