import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/services/supabase_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  _Status _status = _Status.checking;
  String _message = 'Connecting...';
  late AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _checkAndNavigate();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _checkAndNavigate() async {
    await Future.delayed(const Duration(milliseconds: 800));

    try {
      final connected = await SupabaseService.testConnection();

      if (!mounted) return;

      if (connected) {
        setState(() {
          _status = _Status.ok;
          _message = 'Supabase connected';
        });

        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;

        final session = Supabase.instance.client.auth.currentSession;
        context.go(session != null ? '/home' : '/auth/login');
      } else {
        setState(() {
          _status = _Status.error;
          _message = 'Connection failed — check Supabase project status';
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _status = _Status.error;
        _message = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo area
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) {
                    final scale = 0.95 + 0.05 * _pulseController.value;
                    return Transform.scale(scale: scale, child: child);
                  },
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.primary,
                        width: 2,
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        '\$',
                        style: TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                Text('MoneyRush', style: AppTextStyles.heading1),
                const SizedBox(height: 8),
                Text(
                  'To Learn. To Earn. To Return.',
                  style: AppTextStyles.bodySecondary,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),

                // Status indicator
                _StatusIndicator(status: _status, message: _message),

                if (_status == _Status.error) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _status = _Status.checking;
                        _message = 'Connecting...';
                      });
                      _checkAndNavigate();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                    child: const Text('Retry', style: AppTextStyles.button),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum _Status { checking, ok, error }

class _StatusIndicator extends StatelessWidget {
  final _Status status;
  final String message;

  const _StatusIndicator({required this.status, required this.message});

  @override
  Widget build(BuildContext context) {
    final icon = switch (status) {
      _Status.checking => const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: AppColors.accent,
            strokeWidth: 2,
          ),
        ),
      _Status.ok => const Icon(Icons.check_circle, color: AppColors.primary, size: 22),
      _Status.error => const Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 22),
    };

    final color = switch (status) {
      _Status.checking => AppColors.textSecondary,
      _Status.ok => AppColors.primary,
      _Status.error => const Color(0xFFE74C3C),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        icon,
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            message,
            style: AppTextStyles.body.copyWith(color: color),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }
}
