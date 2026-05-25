@echo off
REM Copy this file to run.bat and fill in your actual keys.
REM run.bat is in .gitignore and will NEVER be committed to GitHub.
REM
REM How to get your keys:
REM   SUPABASE_URL    : supabase.com -> your project -> Settings -> API -> Project URL
REM   SUPABASE_ANON_KEY : supabase.com -> your project -> Settings -> API -> anon/public key
REM   GEMINI_KEY      : aistudio.google.com -> Get API key

flutter run ^
  --dart-define=SUPABASE_URL=YOUR_SUPABASE_PROJECT_URL_HERE ^
  --dart-define=SUPABASE_ANON_KEY=YOUR_SUPABASE_ANON_KEY_HERE ^
  --dart-define=GEMINI_KEY=YOUR_GEMINI_API_KEY_HERE ^
  -d chrome
