import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternak_pro/ui_pages/onboarding/onboarding_1.dart';
import 'package:url_launcher/url_launcher.dart';
// import 'package:web/web.dart' as html;
import '../../shared/theme.dart';
import '../services/api_service.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  final ApiService _apiService = ApiService();

  String? _token;
  String? _userId;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _resetBannerSeen();
    _loadCredentials();
    _startSplashFlow();
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

  Future<void> _startSplashFlow() async {
    await Future.wait([
      _loadCredentials(),
      Future.delayed(const Duration(seconds: 5)),
    ]);

    if (!mounted || _hasNavigated) {
      return;
    }

    _proceedNavigation();
  }

  void _proceedNavigation() {
    if (_hasNavigated || !mounted) {
      return;
    }

    _hasNavigated = true;

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

  // Fungsi untuk memeriksa dan menyimpan data login di SharedPreferences
  // Future<void> _checkLogin(BuildContext context) async {
  //   final prefs = await SharedPreferences.getInstance();

  //   // Ambil data dari URL query parameters
  //   final url = Uri.parse(html.window.location.href);
  //   final token = url.queryParameters['token'];
  //   final userId = url.queryParameters['user_id'];
  //   final email = url.queryParameters['email'];
  //   final name = url.queryParameters['name'];
  //   final roleId = url.queryParameters['role_id'];

  //   // Jika data tidak ditemukan, arahkan ke halaman login
  //   if (token != null && userId != null && email != null && name != null && roleId != null) {
  //     // Simpan data ke SharedPreferences
  //     prefs.setString('token', token);
  //     prefs.setString('user_id', userId);
  //     prefs.setString('email', email);
  //     prefs.setString('name', name);
  //     prefs.setInt('role_id', int.parse(roleId));

  //     // Arahkan pengguna ke halaman utama
  //     Navigator.pushReplacementNamed(context, '/main');
  //   } else {
  //     _launchURL('https://ternakpro.id/login');
  //   }
  // }

  // // Fungsi untuk membuka URL
  // _launchURL(String url) async {
  //   final urlUri = Uri.parse(url);
  //   if (await canLaunchUrl(urlUri)) {
  //     await launchUrl(urlUri);
  //   } else {
  //     throw 'Tidak dapat membuka URL: $url';
  //   }
  // }

  Future<void> _checkLoginStatus(BuildContext context) async {
    // This function is no longer needed - remove it
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
