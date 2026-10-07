import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum OtpState { idle, validating, success, error }

class PokerOtpField extends StatefulWidget {
  final int length;
  final Future<bool> Function(String) onVerify;

  final double cardWidth;
  final double cardHeight;
  final double spinRadius;
  final double fanSpread; // Controls how wide the hand fan opens

  final Color successColor;
  final Color errorColor;
  final Color activeBorderColor;
  final Color inactiveBorderColor;
  final Color cardBackgroundColor;
  final VoidCallback? onSuccess; // 1. Add this line

  const PokerOtpField({
    Key? key,
    this.length = 4,
    required this.onVerify,
    this.cardWidth = 55.0,
    this.cardHeight = 70.0,
    this.spinRadius = 75.0,
    this.fanSpread = 0.25,
    this.successColor = const Color(0xFF22C55E),
    this.errorColor = const Color(0xFFEF4444),
    this.activeBorderColor = const Color(0xFF6366F1),
    this.inactiveBorderColor = const Color(0xFF2A2A3C),
    this.cardBackgroundColor = const Color(0xFF181825),
    this.onSuccess, // 2. Add this line
  })  : assert(length == 4 || length == 6, 'Length must be 4 or 6'),
        super(key: key);

  @override
  State<PokerOtpField> createState() => _PokerOtpFieldState();
}

class _PokerOtpFieldState extends State<PokerOtpField>
    with TickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  OtpState _state = OtpState.idle;

  // Controllers for the distinct choreography steps
  late AnimationController _stackController;
  late AnimationController _circleController;
  late AnimationController _spinController;
  late AnimationController _fanController;
  late AnimationController _shakeController;
  late AnimationController _successPopController;

  final double _horizontalMargin = 6.0;

  @override
  void initState() {
    super.initState();

    _stackController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _circleController = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
    _spinController = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fanController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _shakeController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _successPopController = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _stackController.dispose();
    _circleController.dispose();
    _spinController.dispose();
    _fanController.dispose();
    _shakeController.dispose();
    _successPopController.dispose();
    super.dispose();
  }

  Future<void> _onTextChanged(String value) async {
    if (_state != OtpState.idle) return;

    setState(() {});

    if (value.length == widget.length) {
      _focusNode.unfocus();
      await _startVerificationFlow(value);
    }
  }

  Future<void> _startVerificationFlow(String value) async {
    setState(() => _state = OtpState.validating);

    // 1. Loading: Stack to center and form the hollow spinning ring
    _stackController.forward();
    await _circleController.forward();
    _spinController.repeat();

    // 2. Await external validation
    bool isValid = await widget.onVerify(value);

    // 3. Stop spinning smoothly and collapse the ring back into a center stack
    _spinController.stop();
    await Future.wait([
      _spinController.animateTo(
        1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      ),
      _circleController.reverse(),
    ]);
    _spinController.reset();

    // 4. Checking phase: Open into the "hand of cards" fan
    await _fanController.forward();
    await Future.delayed(const Duration(milliseconds: 800));
    await _fanController.reverse();

    // 5. Final State: Success or Error
    if (isValid) {
      // Morph into the Green True Mark
      setState(() => _state = OtpState.success);

      await _successPopController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 1200));

      widget.onSuccess?.call();
    } else {
      // ERROR SEQUENCE: Show False Icon -> Unstack -> Shake -> Clear

      // Step A: Show False Mark (Red X) while still stacked in the center
      setState(() => _state = OtpState.error);
      await _successPopController.forward(from: 0.0); // Re-using pop for the X

      // Wait so the user can see the "X"
      await Future.delayed(const Duration(milliseconds: 1000));

      // Step B: Revert the pop scale
      _successPopController.reverse();

      // Step C: Deal the cards back out into the row ("show all cards")
      await _stackController.reverse();

      // Step D: Shake to indicate failure
      await _shakeController.forward(from: 0.0);
      await Future.delayed(const Duration(milliseconds: 400));

      // Clear and refocus keyboard
      _controller.clear();
      setState(() => _state = OtpState.idle);
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }

  Color _getCurrentBorderColor(int index) {
    if (_state == OtpState.success) return widget.successColor;
    if (_state == OtpState.error) return widget.errorColor;
    if (_state == OtpState.validating) return widget.activeBorderColor;
    return _controller.text.length == index
        ? widget.activeBorderColor
        : widget.inactiveBorderColor;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (_state == OtpState.idle) {
          FocusScope.of(context).requestFocus(_focusNode);
        }
      },
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned.fill(
            child: Opacity(
              opacity: 0.0,
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                keyboardType: TextInputType.number,
                maxLength: widget.length,
                onChanged: _onTextChanged,
                enabled: _state == OtpState.idle,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: const InputDecoration(counterText: ""),
              ),
            ),
          ),

          AnimatedBuilder(
            animation: Listenable.merge([_shakeController, _successPopController]),
            builder: (context, child) {
              double shakeOffset = 0.0;
              if (_state == OtpState.error) {
                shakeOffset = sin(_shakeController.value * pi * 4) * 8.0;
              }

              double scale = 1.0;
              if (_state == OtpState.success) {
                scale = 1.0 + sin(_successPopController.value * pi) * 0.15;
              }

              return Transform.translate(
                offset: Offset(shakeOffset, 0),
                child: Transform.scale(
                  scale: scale,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(widget.length, (index) {
                      return _buildAnimatedCard(index);
                    }),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedCard(int index) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _stackController,
        _circleController,
        _spinController,
        _fanController,
        _successPopController, // Added so success pop triggers a rebuild
      ]),
      builder: (context, _) {
        final double centerIndex = (widget.length - 1) / 2;
        final double cardTotalWidth = widget.cardWidth + (_horizontalMargin * 2);
        final double distanceToCenter = (index - centerIndex) * cardTotalWidth;

        final double dxToCenter = -distanceToCenter * _stackController.value;

        final double circleAngle = index * (2 * pi / widget.length) * _circleController.value;
        final double continuousSpin = _spinController.value * pi * 2;
        final double fanAngle = (index - centerIndex) * widget.fanSpread * _fanController.value;

        final double totalRotationZ = circleAngle + fanAngle + (continuousSpin * _circleController.value);
        final double circleRadius = widget.spinRadius * _circleController.value;
        final double pivotY = (widget.cardHeight / 2.2) * _fanController.value;

        final transform = Matrix4.identity()
          ..translate(dxToCenter, 0.0, 0.0)
          ..translate(0.0, pivotY, 0.0)
          ..rotateZ(totalRotationZ)
          ..translate(0.0, -pivotY, 0.0)
          ..translate(0.0, -circleRadius, 0.0);

        // Render directly inside builder so setState(_state = OtpState.success) updates instantly
        return Transform(
          alignment: Alignment.center,
          transform: transform,
          child: _buildCardUI(index),
        );
      },
    );
  }

  Widget _buildCardUI(int index) {
    final borderColor = _getCurrentBorderColor(index);

    final isSuccess = _state == OtpState.success;
    final isError = _state == OtpState.error;

    // Checks if the cards are fully grouped in the center
    final isStacked = _stackController.value == 1.0;

    // Show center icon if success, OR if error and the cards are still stacked
    final bool showIcon = isSuccess || (isError && isStacked);
    final bool isGlowing = _state == OtpState.validating || showIcon;

    // Determine fill color
    Color bgColor = widget.cardBackgroundColor;
    if (isSuccess) bgColor = widget.successColor;
    if (isError && isStacked) bgColor = widget.errorColor; // Fill red when stacked

    final double textOpacity = (1.0 - _stackController.value).clamp(0.0, 1.0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: widget.cardWidth,
      height: widget.cardHeight,
      margin: EdgeInsets.symmetric(horizontal: _horizontalMargin),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(
          color: showIcon ? bgColor : borderColor,
          width: 2,
        ),
        boxShadow: [
          if (isGlowing)
            BoxShadow(
              color: (showIcon ? bgColor : borderColor).withOpacity(0.5),
              blurRadius: 18,
              spreadRadius: 3,
            ),
        ],
      ),
      alignment: Alignment.center,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Hide digits if an icon is showing
          Opacity(
            opacity: showIcon ? 0.0 : textOpacity,
            child: Text(
              _controller.text.length > index ? _controller.text[index] : "",
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),

          // The True Mark
          if (isSuccess)
            const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 34,
            ),

          // The False Mark
          if (isError && isStacked)
            const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 34,
            ),
        ],
      ),
    );
  }

}