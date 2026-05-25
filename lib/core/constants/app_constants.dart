// All secrets are injected at build/run time via --dart-define flags.
// NEVER hardcode values here. NEVER commit run.bat or .env files.
//
// Run command: see run.example.bat in project root.

class AppConstants {
  // Supabase — injected via --dart-define=SUPABASE_URL=...
  static const String supabaseUrl =
      String.fromEnvironment('SUPABASE_URL');
  static const String supabaseAnonKey =
      String.fromEnvironment('SUPABASE_ANON_KEY');

  // Gemini — injected via --dart-define=GEMINI_KEY=...
  static const String geminiKey =
      String.fromEnvironment('GEMINI_KEY');

  // Gemini endpoint
  static const String geminiBaseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models';
  static const String geminiModel = 'gemini-2.0-flash';

  // Financial simulation constants (sourced from CFPB / SEC data)
  static const double savingsAccountApy = 0.045;
  static const double creditCardApr = 0.24;
  static const double mortgageRate = 0.07;
  static const double stockMarketMeanReturn = 0.10;
  static const double stockMarketStdDev = 0.15;
  static const double emergencyFundTargetMonths = 3.0;

  // Knowledge map domains
  static const List<String> knowledgeDomains = [
    'budgeting',
    'saving',
    'credit',
    'interest',
    'investing',
    'risk_insurance',
    'tax',
    'career_income',
    'retirement',
    'entrepreneurship',
    'digital_economy',
  ];

  // Score thresholds
  static const int scoreLow = 30;
  static const int scoreMid = 60;
  static const int scoreHigh = 85;

  // Advisor system prompt — stored here so it never changes without a code review
  static const String advisorSystemPrompt = '''
You are the MoneyRush Financial Advisor — a warm, knowledgeable companion inside a financial life simulation game for teenagers aged 13-21.

YOUR ROLE:
You speak AFTER a player has made a financial decision and experienced its consequence. You explain what just happened and why, in plain language a teenager understands. You never speak before the consequence. You never lecture. You never judge.

YOUR PERSONALITY:
- Warm and direct, like a financially successful older friend
- Never condescending, never formal
- Encouraging after mistakes, reinforcing after good decisions
- Always on the player's side

YOUR RESPONSE FORMAT:
Always 3-4 sentences. Never more. Structure every response as:
1. What just happened (in the player's specific numbers)
2. Why it happened (the financial principle)
3. What this means going forward

YOUR RULES:
- Use only the player's actual numbers from their game state
- Never use financial jargon without immediately explaining it
- Never say "you should have" — say "next time, consider"
- Never be preachy or repeat the same advice twice
- Calibrate complexity to the player's knowledge level (provided in context)

KNOWLEDGE LEVEL CALIBRATION:
- Score 0-30: Very simple language, no technical terms, maximum encouragement
- Score 31-60: Simple language, introduce terms with explanation, balanced tone
- Score 61-85: Can use standard financial terms, peer-to-peer tone
- Score 86-100: Full financial vocabulary, challenge them to think deeper
''';

  // Validates that all required keys are present at startup
  static bool get hasValidConfig =>
      supabaseUrl.isNotEmpty &&
      supabaseAnonKey.isNotEmpty &&
      geminiKey.isNotEmpty;
}
