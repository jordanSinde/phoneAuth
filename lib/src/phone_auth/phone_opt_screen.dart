import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:country_code_picker/country_code_picker.dart';

class PhoneAuthScreen extends StatefulWidget {
  const PhoneAuthScreen({super.key});

  @override
  State<PhoneAuthScreen> createState() => _PhoneAuthScreenState();
}

class _PhoneAuthScreenState extends State<PhoneAuthScreen> {
  String _verificationId = "";
  int _resendToken = 0;
  bool _codeSent = false;
  bool _verificationInProgress = false;
  String _selectedCountryCode = "+237";
  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _otpCodeController = TextEditingController();

  Future<void> _verifyPhoneNumber(String phoneNumber) async {
    setState(() {
      _verificationInProgress = true;
      _codeSent = false;
    });

    verificationCompleted(PhoneAuthCredential phoneAuthCredential) async {
      await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      _redirectToHomePage();
    }

    verificationFailed(FirebaseAuthException authException) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Verification Failed'),
            content: Text(authException.message ?? 'Unknown Error'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }

    codeSent(String verificationId, int? resendToken) async {
      setState(() {
        _verificationId = verificationId;
        _resendToken = resendToken ?? 0;
        _codeSent = true;
      });
    }

    codeAutoRetrievalTimeout(String verificationId) {
      // This callback will be triggered when the SMS code auto-retrieval times out.
      // You can handle the situation accordingly.
    }

    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      timeout: const Duration(seconds: 120),
      forceResendingToken: _resendToken,
    );

    setState(() {
      _verificationInProgress = false;
    });
  }

  Future<void> _signInWithPhoneNumber(String smsCode) async {
    try {
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId,
        smsCode: smsCode,
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      _redirectToHomePage();
    } catch (e) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Sign In Failed'),
            content: Text(e.toString()),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _resendVerificationCode() async {
    if (!_verificationInProgress && _codeSent) {
      setState(() {
        _codeSent = false;
      });

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: _selectedCountryCode + _phoneNumberController.text,
        verificationCompleted:
            (PhoneAuthCredential credential) {}, // a chercher plustard
        verificationFailed: (FirebaseAuthException e) {},
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken ?? 0;
            _codeSent = true;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {},
        forceResendingToken: _resendToken,
      );
    }
  }

  void _redirectToHomePage() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => Container()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Phone Authentication'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CountryCodePicker(
                onChanged: (CountryCode? countryCode) {
                  setState(() {
                    _selectedCountryCode = countryCode!.toString();
                  });
                },
                initialSelection: '+237',
                favorite: const ['+237', '+235', '+44'],
                showCountryOnly: false,
                showOnlyCountryWhenClosed: false,
                alignLeft: false,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneNumberController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Phone Number',
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  if (!_verificationInProgress) {
                    _verifyPhoneNumber(
                        _selectedCountryCode + _phoneNumberController.text);
                  }
                },
                child: _verificationInProgress
                    ? const CircularProgressIndicator()
                    : const Text('Verify Phone Number'),
              ),
              const SizedBox(height: 16),
              if (_codeSent)
                TextFormField(
                  controller: _otpCodeController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'OTP Code',
                  ),
                ),
              const SizedBox(height: 16),
              if (_codeSent)
                ElevatedButton(
                  onPressed: () {
                    _signInWithPhoneNumber(_otpCodeController.text);
                  },
                  child: const Text('Verify OTP Code'),
                ),
              if (_codeSent)
                TextButton(
                  onPressed: _resendVerificationCode,
                  child: const Text('Resend Code'),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
