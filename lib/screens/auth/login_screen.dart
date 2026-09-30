import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../theme/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../widgets/gradient_button.dart';
import '../home/home_screen.dart';

/// Login screen with water wave animation and PIN entry.
/// Uses the default PIN (1234) for demo purposes.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final List<String> _pin = [];
  bool _isLoading = false;
  String? _errorMessage;
  bool _shake = false;

  static const int _pinLength = 4;

  void _onKeyPressed(String digit) {
    if (_pin.length >= _pinLength) return;
    setState(() {
      _pin.add(digit);
      _errorMessage = null;
    });
    if (_pin.length == _pinLength) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_pin.isEmpty) return;
    setState(() => _pin.removeLast());
  }

  Future<void> _verifyPin() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 600));

    final entered = _pin.join();
    if (entered == AppConstants.defaultPin) {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const HomeScreen(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 500),
          ),
        );
      }
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
        child: Stack(
          children: [
            // Background decorative bubbles
            _buildBackground(),
            // Main content
            SafeArea(
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
                        const SizedBox(height: 32),
                        _buildHeader(),
                        const Spacer(),
                        _buildPinSection(),
                        const Spacer(),
                        _buildKeypad(),
                        const SizedBox(height: 24),
                        _buildDemoHint(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withOpacity(0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            Icons.water_drop_rounded,
            color: AppColors.white,
            size: 40,
          ),
        ).animate().scaleXY(begin: 0.5, end: 1.0, curve: Curves.elasticOut),
        const SizedBox(height: 16),
        const Text(
          'TOLERA',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 5,
          ),
        ).animate().fadeIn(delay: 300.ms),
        const SizedBox(height: 6),
        Text(
          'Enter your PIN to continue',
          style: TextStyle(
            color: AppColors.white.withOpacity(0.7),
            fontSize: 14,
          ),
        ).animate().fadeIn(delay: 450.ms),
      ],
    );
  }

  Widget _buildPinSection() {
    return Animate(
      target: _shake ? 1 : 0,
      effects: [
        ShakeEffect(
          duration: 600.ms,
          hz: 6,
          offset: const Offset(10, 0),
          curve: Curves.easeInOut,
        ),
      ],
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _pinLength,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                width: 18,
                height: 18,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: index < _pin.length
                      ? AppColors.white
                      : Colors.white.withOpacity(0.3),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.6),
                    width: 2,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: _errorMessage != null
                ? Text(
                    _errorMessage!,
                    key: ValueKey(_errorMessage),
                    style: const TextStyle(
                      color: Color(0xFFFF5252),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : const SizedBox(height: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildKeypad() {
    final keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 60),
      child: Column(
        children: keys
            .map(
              (row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: row.map(_buildKey).toList(),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildKey(String key) {
    if (key.isEmpty) return const SizedBox(width: 72);

    if (key == 'del') {
      return _KeyButton(
        onPressed: _onDelete,
        child: const Icon(Icons.backspace_outlined,
            color: AppColors.white, size: 22),
      );
    }

    return _KeyButton(
      onPressed: _isLoading ? null : () => _onKeyPressed(key),
      child: Text(
        key,
        style: const TextStyle(
          color: AppColors.white,
          fontSize: 24,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildDemoHint() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 40),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline,
              color: AppColors.white.withOpacity(0.7), size: 16),
          const SizedBox(width: 8),
          Text(
            'Demo PIN: ${AppConstants.defaultPin}',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.7),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Stack(
      children: [
        Positioned(
          top: -50,
          right: -50,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.teal.withOpacity(0.15),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          left: -60,
          child: Container(
            width: 250,
            height: 250,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.aqua.withOpacity(0.1),
            ),
          ),
        ),
      ],
    );
  }
}

class _KeyButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onPressed;

  const _KeyButton({required this.child, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 72,
      height: 72,
      child: Material(
        color: Colors.white.withOpacity(0.1),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          splashColor: Colors.white.withOpacity(0.2),
          child: Center(child: child),
        ),
      ),
    );
  }
}
