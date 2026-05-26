import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../providers/player_provider.dart';

// Stage 1 authenticated home placeholder — replaced by city map in Stage 3.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Load player data if not already loaded.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<PlayerProvider>();
      if (provider.playerData == null) {
        provider.loadPlayer();
      }
    });
  }

  Future<void> _signOut() async {
    await context.read<PlayerProvider>().signOut();
    if (!mounted) return;
    context.go('/auth/login');
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PlayerProvider>();
    final game = provider.gameState;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: provider.isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              )
            : Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 32),
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back,',
                              style: AppTextStyles.bodySecondary,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              provider.username,
                              style: AppTextStyles.heading2,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: _signOut,
                          icon: const Icon(
                            Icons.logout_rounded,
                            color: AppColors.textMuted,
                          ),
                          tooltip: 'Sign out',
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    // Bank balance card
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.card, width: 1),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bank Balance',
                            style: AppTextStyles.bodySecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '\$${_formatNumber(game?['bank_balance'])}',
                            style: AppTextStyles.money.copyWith(fontSize: 32),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Five scores row
                    if (game != null) _ScoresRow(game: game),
                    const Spacer(),
                    // Stage indicator
                    Center(
                      child: Text(
                        'City Map coming in Stage 3',
                        style: AppTextStyles.caption,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
      ),
    );
  }

  String _formatNumber(dynamic value) {
    if (value == null) return '0.00';
    final num = double.tryParse(value.toString()) ?? 0.0;
    return num.toStringAsFixed(2);
  }
}

class _ScoresRow extends StatelessWidget {
  final Map<String, dynamic> game;

  const _ScoresRow({required this.game});

  @override
  Widget build(BuildContext context) {
    final scores = [
      _ScoreTile(
          label: 'Wealth',
          value: game['wealth_score'],
          color: AppColors.wealth),
      _ScoreTile(
          label: 'Stability',
          value: game['stability_score'],
          color: AppColors.stability),
      _ScoreTile(
          label: 'Growth',
          value: game['growth_score'],
          color: AppColors.growth),
      _ScoreTile(
          label: 'Freedom',
          value: game['freedom_score'],
          color: AppColors.freedom),
      _ScoreTile(
          label: 'Wellbeing',
          value: game['wellbeing_score'],
          color: AppColors.wellbeing),
    ];

    return Row(
      children: scores
          .map((s) => Expanded(child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: s,
              )))
          .toList(),
    );
  }
}

class _ScoreTile extends StatelessWidget {
  final String label;
  final dynamic value;
  final Color color;

  const _ScoreTile({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final score = (value as num?)?.toInt() ?? 50;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.card, width: 1),
      ),
      child: Column(
        children: [
          Text(
            '$score',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 9,
              color: AppColors.textMuted,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
