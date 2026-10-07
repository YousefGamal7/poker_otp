# Poker OTP

A highly animated, casino-dealer style OTP (One-Time Password) verification package for Flutter. `poker_otp` utilizes complex `Matrix4` 3D transformations to create a fluid, multi-stage choreography that mimics dealing, checking, and validating a hand of cards.

![Poker OTP Demo](https://raw.githubusercontent.com/YousefGamal7/poker_otp/main/example/demo.gif) *(Note: Add a GIF of your animation to your repository and update this link)*

## ✨ Features

* **Multi-Stage Choreography:** 
  * **Loading:** Cards slide into a center stack, push outward, and continuously spin in a 3D hollow ring.
  * **Checking:** The ring collapses and smoothly opens into a bottom-pivot "hand of cards" fan.
  * **Success:** Cards collapse, morph into a glowing green checkmark, and trigger a success callback.
  * **Error:** Cards collapse, deal back into their original horizontal row, shake red, and clear the input for retry.
* **Scattered Text Effect:** Includes a custom `ScatteredText` widget that randomly throws characters across the screen and rearranges them perfectly in sync with the verification cycle.
* **Native Keyboard Support:** Uses a hidden native `TextField` mapped to a `FocusNode` for flawless numeric keyboard integration.
* **Highly Customizable:** Full control over card dimensions, ring radius, fan spread, animation timings, and neon glow colors.

## 🚀 Getting Started

Add the package to your `pubspec.yaml`:

```yaml
dependencies:
  poker_otp: ^1.0.0
Import the library in your Dart code:Dartimport 'package:poker_otp/poker_otp.dart';
💻 UsageYou can use the fully integrated PokerOtpScreen wrapper for a complete plug-and-play experience, or embed the PokerOtpField directly into your own custom UI.Option 1: The Plug-and-Play ScreenThe easiest way to use the package. It automatically handles the ScatteredText title animations and perfectly times them with the card animations.DartNavigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => PokerOtpScreen(
      title: "OTP Verification",
      subtitle: "We texted a code to +1 234 *** 5678",
      length: 4, 
      
      // Your asynchronous verification logic
      onVerify: (otp) async {
        await Future.delayed(const Duration(seconds: 2)); // Simulate API call
        return otp == "1234"; // Return true for success, false for error
      },
      
      // Triggered after the green checkmark animation finishes
      onSuccess: () {
        Navigator.pop(context); // Or route to Home Screen
      },
      
      onResend: () {
        print("Resending OTP code...");
      },
    ),
  ),
);
Option 2: The Standalone FieldIf you want to place the poker cards inside your own custom layout:DartPokerOtpField(
  length: 4,
  cardWidth: 55.0,
  cardHeight: 70.0,
  spinRadius: 75.0,
  onVerify: (otp) async {
    await Future.delayed(const Duration(seconds: 2));
    return otp == "1234";
  },
  onSuccess: () {
    print("OTP Verified!");
  },
)
⚙️ Customization ParametersPokerOtpFieldParameterTypeDefaultDescriptionlengthint4The number of digits required (must be 4 or 6).onVerifyFuture<bool> Function(String)RequiredThe async callback triggered when the OTP is fully typed. Must return true or false.onSuccessVoidCallback?nullCalled exactly after the success checkmark animation finishes holding on screen.cardWidthdouble55.0The width of each individual card.cardHeightdouble70.0The height of each individual card.spinRadiusdouble75.0Controls how wide the hollow ring expands during the loading phase.fanSpreaddouble0.25Controls how wide the cards fan out during the checking phase.successColorColorColor(0xFF22C55E)The color of the checkmark, border, and neon glow on success.errorColorColorColor(0xFFEF4444)The color of the border and neon glow on error.activeBorderColorColorColor(0xFF6366F1)The border color of the currently focused card and the loading ring.inactiveBorderColorColorColor(0xFF2A2A3C)The border color of empty, unfocused cards.cardBackgroundColorColorColor(0xFF181825)The background color of the cards.📝 LicenseDistributed under the MIT License. See LICENSE for more information.
