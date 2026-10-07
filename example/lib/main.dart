import 'package:flutter/material.dart';
import 'package:untitled/src/otp_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: .fromSeed(seedColor: Colors.deepPurple),
      ),
      home: LoginScreen()
    );
  }
}


class LoginScreen extends StatelessWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigate to the customized OTP screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => PokerOtpScreen(
                  title: "OTP Verification",
                  subtitle: "We texted a code to +1 234 *** 5678",
                  length: 4,

                  onVerify: (otp) async {
                    // 1. Just check the code here. Do NOT navigate here.
                    await Future.delayed(const Duration(seconds: 2)); // simulate network
                    return otp == "1234"; // Returns true/false
                  },

                  onSuccess: () {
                    // 2. This triggers EXACTLY when the green checkmark is done showing!
                    Navigator.pop(context); // Or Navigator.pushReplacement to Home
                  },
                ),
              ),
            );
          },
          child: const Text("Go to OTP Screen"),
        ),
      ),
    );
  }
}

