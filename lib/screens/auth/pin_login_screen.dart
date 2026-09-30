import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_colors.dart';
import '../../models/app_user.dart';
import '../../providers/providers.dart';
import '../home/home_screen.dart';

/// Step 3 of the login flow: Enter PIN for the selected user.
class PinLoginScreen extends ConsumerStatefulWidget {
  final AppUser user;

  const PinLoginScreen({super.key, required this.user});

  @override
  ConsumerState<PinLoginScreen> createState() => _PinLoginScreenState();
}

class _PinLoginScreenState extends ConsumerState<PinLoginScreen> {
  final List<String> _pin = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _shake = false;

  static const int _pinLength = 4;

  void _onKeyPressed(String digit) {
    if (_pin.length >= _pinLength || _isLoading) return;
    setState(() {
      _pin.add(digit);
      _errorMessage = null;
    });
    if (_pin.length == _pinLength) _verifyPin();
  }

  void _onDelete() {
    if (_pin.isEmpty || _isLoading) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 500));

    final repo = ref.read(userRepositoryProvider);
    final verified = await repo.verifyPin(widget.user.id!, _pin.join());

    if (!mounted) return;

    if (verified != null) {
      // Set the logged-in user in global state
      ref.read(currentUserProvider.notifier).state = verified;
      Navigator.of(context).pushAndRemoveUntil(
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) =>
              FadeTransition(opacity: animation, child: child),
          transitionDuration: const Duration(milliseconds: 500),
        ),
        (route) => false,
      );
    } else {
      setState(() {
        _isLoading = false;
        _pin.clear();
        _errorMessage = 'Incorrect PIN. Try again.';
        _shake = true;
      });
      await Future.delayed(const Duration(milliseconds: 600));
      if (mounted) setState(() => _shake = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.oceanGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const ClampingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Back button
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        icon: const Icon(Icons.arrow_back_ios_rounded,
                            color: AppColors.white),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeader(),
                    const Spacer(),
                    _buildPinDots(),
                    if (_errorMessage != null) ...[
                      const SizedBox(height: 12),
                      _buildError(),
                    ],
                    const Spacer(),
                    _buildKeypad(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final initials = widget.user.name
        .split(' ')
        .take(2)
        .map((w) => w.isNotEmpty ? w[0] : '')
        .join()
        .toUpperCase();

    return Column(
      children: [
        // Avatar
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.aqua, AppColors.teal],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.aqua.withOpacity(0.4),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ).animate().scale(
              begin: const Offset(0.5, 0.5),
              duration: 500.ms,
              curve: Curves.elasticOut,
            ),
        const SizedBox(height: 14),
        Text(
          widget.user.name,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 150.ms),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            widget.user.role.displayName,
            style: const TextStyle(
              color: AppColors.aquaLight,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
        ).animate().fadeIn(delay: 250.ms),
        const SizedBox(height: 20),
        Text(
          'Enter your 4-digit PIN',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ).animate().fadeIn(delay: 300.ms),
      ],
    );
  }

  Widget _buildPinDots() {
    return AnimatedSlide(
      offset: _shake ? const Offset(0.03, 0) : Offset.zero,
      duration: const Duration(milliseconds: 80),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(_pinLength, (i) {
          final filled = i < _pin.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            margin: const EdgeInsets.symmetric(horizontal: 10),
            width: 18,
            height: 18,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: filled ? AppColors.aquaLight : Colors.transparent,
              border: Border.all(
                color: filled
                    ? AppColors.aquaLight
                    : AppColors.white.withOpacity(0.4),
                width: 2,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildError() {
    return Text(
      _errorMessage!,
      style: const TextStyle(
        color: Color(0xFFFF8A80),
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    ).animate().fadeIn(duration: 200.ms).shakeX(amount: 4, hz: 4);
  }

  Widget _buildKeypad() {
    if (_isLoading) {
      return const SizedBox(
        height: 48,
        child: Center(
          child: CircularProgressIndicator(
            color: AppColors.aquaLight,
            strokeWidth: 2.5,
          ),
        ),
      );
    }

    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: keys.map((row) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row.map((key) => _buildKey(key)).toList(),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 72, height: 72);

    final isDel = key == 'del';

    return GestureDetector(
      onTap: isDel ? _onDelete : () => _onKeyPressed(key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        width: 72,
        height: 72,
        margin: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.12),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.15)),
        ),
        child: Center(
          child: isDel
              ? Icon(Icons.backspace_outlined,
                  color: AppColors.white.withOpacity(0.8), size: 22)
              : Text(
                  key,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
        ),
      ),
    );
  }
}
