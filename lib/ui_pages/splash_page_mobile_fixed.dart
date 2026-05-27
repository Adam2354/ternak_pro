import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternak_pro/ui_pages/onboarding/onboarding_1.dart';
import '../../shared/theme.dart';
import '../services/api_service.dart';

class SplashPageMobile extends StatefulWidget {
  const SplashPageMobile({super.key});

  @override
  State<SplashPageMobile> createState() => _SplashPageMobileState();
}

class _SplashPageMobileState extends State<SplashPageMobile> {
  final ApiService _apiService = ApiService();

  String? _token;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _resetBannerSeen();
    _loadCredentials();
  }

  Future<void> _loadCredentials() async {
    final credential = await _apiService.loadCredentials();
    if (mounted) {
      setState(() {
        _token = credential['token'];
        _userId = credential['user_id'];
      });
    }
  }

  void _proceedNavigation() {
    if (_token != null && _userId != null) {
      // User is logged in, go to MainPage
      Navigator.pushReplacementNamed(context, '/main');
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Onboarding1()),
      );
      // User is not logged in, go to Onboarding1
    }
  }

  Future<void> _resetBannerSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenBanner', false); // Reset banner flag
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    // Responsif terhadap ukuran layar, mengatur padding dan gambar logo
    double logoWidth = screenWidth * 0.4; // 60% lebar layar untuk logo

    return Scaffold(
      body: GestureDetector(
        onTap: _proceedNavigation,
        child: Stack(
          children: [
            // Main content
            Container(
              decoration: BoxDecoration(
                gradient: AppColors.gradasi01, // Gradient background
              ),
              child: Center(
                child: Image.asset(
                  "assets/splash_logo.png",
                  key: const ValueKey('splash_logo'),
                  width: logoWidth,
                ),
              ),
            ),
            // Copyright text at the bottom
            Positioned(
              bottom: 16.0, // Distance from the bottom of the screen
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: Text(
                  'Copyright © 2025\nAll rights reserved.',
                  style: AppTextStyle.medium.copyWith(
                    color: AppColors.white100,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
