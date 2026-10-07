import 'package:flutter/material.dart';
import 'poker_otp.dart';
import 'scattered_text.dart';

class PokerOtpScreen extends StatefulWidget {
  final String title;
  final String subtitle;
  final Future<bool> Function(String) onVerify;
  final int length;
  final VoidCallback? onSuccess; // 1. Add this line

  // Customization
  final Color backgroundColor;
  final TextStyle titleStyle;
  final TextStyle subtitleStyle;
  final String resendText;
  final VoidCallback? onResend;

  const PokerOtpScreen({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onVerify,
    this.length = 4,
    this.backgroundColor = const Color(0xFF0F0F1A),
    this.titleStyle = const TextStyle(fontSize: 32, color: Colors.white, fontWeight: FontWeight.bold),
    this.subtitleStyle = const TextStyle(fontSize: 16, color: Colors.white70),
    this.resendText = "Didn't get a code?",
    this.onResend,
    this.onSuccess, // 2. Add this line
  }) : super(key: key);

  @override
  State<PokerOtpScreen> createState() => _PokerOtpScreenState();
}

class _PokerOtpScreenState extends State<PokerOtpScreen> {
  bool _isChecking = false;

  Future<bool> _handleVerify(String otp) async {
    setState(() => _isChecking = true);

    // Pass the OTP to the user's custom validation function
    bool isValid = await widget.onVerify(otp);

    setState(() => _isChecking = false);
    await Future.delayed(const Duration(milliseconds: 300));

    return isValid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SizedBox(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScatteredText(
              text: widget.title,
              isScattered: _isChecking,
              textStyle: widget.titleStyle,
            ),
            const SizedBox(height: 16),
            ScatteredText(
              text: widget.subtitle,
              isScattered: _isChecking,
              textStyle: widget.subtitleStyle,
            ),
            const SizedBox(height: 64),
            PokerOtpField(
              length: widget.length,
              onVerify: _handleVerify,
            ),
            const SizedBox(height: 48),
            AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _isChecking ? 0.0 : 1.0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${widget.resendText} ",
                    style: TextStyle(color: widget.subtitleStyle.color),
                  ),
                  TextButton(
                    onPressed: _isChecking ? null : widget.onResend,
                    child: const Text(
                      "Resend",
                      style: TextStyle(color: Color(0xFF6366F1), fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}