import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:ternak_pro/shared/custom_loading.dart';
import 'package:ternak_pro/shared/theme.dart';

import '../../services/api_service.dart';
import '../../shared/widgets/login_app_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool showPassword = false;
  bool isLoading = false;

  bool emailError = false;
  bool passwordError = false;

  bool emailFocused = false;
  bool passwordFocused = false;

  String? errorMessage;

  final TextEditingController emailController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();

  final ApiService _apiService = ApiService();

  final emailRegex = RegExp(
    r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$",
  );

  AnimationController? _notifAnimController;
  Animation<double>? _notifOpacity;

  @override
  void initState() {
    super.initState();

    _notifAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 350),
    );

    _notifOpacity = CurvedAnimation(
      parent: _notifAnimController!,
      curve: Curves.easeInOut,
    );

    _checkRememberMe();
  }

  Future<void> _checkRememberMe() async {
    final rememberMeData = await _apiService.getRememberMe();

    setState(() {
      rememberMe = rememberMeData['remember_me'];

      emailController.text = rememberMeData['remember_email'] ?? '';

      passwordController.text = rememberMeData['remember_password'] ?? '';
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    _notifAnimController?.dispose();
    super.dispose();
  }

  void showError(String msg) {
    setState(() {
      errorMessage = msg;
      _notifAnimController?.forward(from: 0);
    });

    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && errorMessage == msg) {
        _closeError();
      }
    });
  }

  void _closeError() {
    _notifAnimController?.reverse();

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        setState(() {
          errorMessage = null;
          emailError = false;
          passwordError = false;
        });
      }
    });
  }

  Future<void> validateAndLogin() async {
    setState(() {
      emailError = false;
      passwordError = false;
      errorMessage = null;
      isLoading = true;
    });

    final email = emailController.text.trim();

    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        emailError = email.isEmpty;
        passwordError = password.isEmpty;
        isLoading = false;
      });

      showError("Oops! Isi form dengan lengkap dulu yah!");

      return;
    }

    if (!emailRegex.hasMatch(email)) {
      setState(() {
        emailError = true;
        isLoading = false;
      });

      showError("Format email tidak valid!");

      return;
    }

    if (password.length < 8) {
      setState(() {
        passwordError = true;
        isLoading = false;
      });

      showError("Password minimal 8 karakter!");

      return;
    }

    try {
      await _apiService.login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/main', (route) => false);
      }
    } catch (e) {
      showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            /// =====================
            /// TOP GRADIENT
            /// =====================
            Container(
              height: 360,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF2D8ED8), Color(0xFF16D0B0)],
                ),
              ),
            ),

            /// =====================
            /// BOTTOM BANNER
            /// =====================
            Align(
              alignment: Alignment.bottomCenter,
              child: IgnorePointer(
                child: Image.asset(
                  'assets/banner_bottom.png',
                  width: double.infinity,
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),

            /// =====================
            /// MAIN CONTENT
            /// =====================
            SafeArea(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(bottom: keyboardHeight + 24),
                child: Column(
                  children: [
                    const SizedBox(height: 18),

                    /// BACK BUTTON
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Image.asset(
                            "assets/auth_assets/icons/ic_back.png",
                            width: 24,
                            height: 24,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 4),

                    /// LOGO
                    Image.asset(
                      "assets/ic_launcher.png",
                      width: 62,
                      height: 62,
                    ),

                    const SizedBox(height: 8),

                    /// TITLE
                    Text(
                      "Masuk Ke\nAkun Kamu",
                      textAlign: TextAlign.center,
                      style: AppTextStyle.extraBold.copyWith(
                        fontSize: 30,
                        height: 1.1,
                        color: Colors.white,
                      ),
                    ),

                    const SizedBox(height: 16),

                    /// SUBTITLE
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Masukkan email dan password kamu untuk Login",
                        textAlign: TextAlign.center,
                        style: AppTextStyle.regular.copyWith(
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    /// LOGIN CARD
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          /// GOOGLE BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: OutlinedButton.icon(
                              onPressed: isLoading
                                  ? null
                                  : () async {
                                      setState(() {
                                        isLoading = true;
                                        errorMessage = null;
                                      });

                                      try {
                                        UserCredential userCredential;

                                        if (kIsWeb) {
                                          final googleProvider =
                                              GoogleAuthProvider();

                                          userCredential = await FirebaseAuth
                                              .instance
                                              .signInWithPopup(googleProvider);
                                        } else {
                                          await GoogleSignIn.instance
                                              .initialize();

                                          final googleUser = await GoogleSignIn
                                              .instance
                                              .authenticate();

                                          final googleAuth =
                                              googleUser.authentication;

                                          final credential =
                                              GoogleAuthProvider.credential(
                                                idToken: googleAuth.idToken,
                                              );

                                          userCredential = await FirebaseAuth
                                              .instance
                                              .signInWithCredential(credential);
                                        }

                                        final firebaseUser =
                                            userCredential.user;

                                        if (firebaseUser == null) {
                                          throw Exception(
                                            'Akun Google tidak berhasil diverifikasi.',
                                          );
                                        }

                                        final idToken = await firebaseUser
                                            .getIdToken(true);

                                        if (idToken == null ||
                                            idToken.isEmpty) {
                                          throw Exception(
                                            'Firebase ID token tidak tersedia.',
                                          );
                                        }

                                        await _apiService.loginWithGoogle(
                                          idToken: idToken,
                                        );

                                        if (!mounted) return;

                                        Navigator.pushNamedAndRemoveUntil(
                                          context,
                                          '/main',
                                          (route) => false,
                                        );
                                      } on FirebaseAuthException catch (e) {
                                        if (mounted) {
                                          showError(
                                            'Login Google gagal: ${e.message ?? e.code}',
                                          );
                                        }
                                      } catch (e) {
                                        if (mounted) {
                                          showError(
                                            e.toString().replaceFirst(
                                              'Exception: ',
                                              '',
                                            ),
                                          );
                                        }
                                      } finally {
                                        if (mounted) {
                                          setState(() {
                                            isLoading = false;
                                          });
                                        }
                                      }
                                    },
                              icon: Image.asset(
                                "assets/auth_assets/icons/ic_google.png",
                                width: 18,
                                height: 18,
                              ),
                              label: Text(
                                "Masuk Dengan Google",
                                style: AppTextStyle.semiBold.copyWith(
                                  fontSize: 14,
                                  color: AppColors.black100,
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(
                                  color: Color(0xFFE7E7E7),
                                ),
                                backgroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// DIVIDER
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xFFE7E7E7),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                ),
                                child: Text(
                                  "Atau login dengan",
                                  style: AppTextStyle.regular.copyWith(
                                    fontSize: 11,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  thickness: 1,
                                  color: Color(0xFFE7E7E7),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 20),

                          /// EMAIL FIELD
                          LoginAppTextfield(
                            controller: emailController,
                            hintText: "Masukkan email kamu",
                            error: emailError,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  emailFocused && !emailError
                                      ? AppColors.primaryBlue
                                      : emailError
                                      ? Colors.red
                                      : Colors.grey[600]!,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  "assets/auth_assets/icons/ic_mail.png",
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                            onFocusChange: (hasFocus) {
                              setState(() {
                                emailFocused = hasFocus;
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          /// PASSWORD FIELD
                          LoginAppTextfield(
                            controller: passwordController,
                            hintText: "Masukkan password kamu",
                            error: passwordError,
                            obscureText: !showPassword,
                            prefixIcon: Padding(
                              padding: const EdgeInsets.all(12),
                              child: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  passwordFocused && !passwordError
                                      ? AppColors.primaryBlue
                                      : passwordError
                                      ? Colors.red
                                      : Colors.grey[600]!,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  "assets/auth_assets/icons/ic_lock.png",
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  showPassword = !showPassword;
                                });
                              },
                              icon: ColorFiltered(
                                colorFilter: ColorFilter.mode(
                                  showPassword
                                      ? AppColors.primaryBlue
                                      : Colors.grey[600]!,
                                  BlendMode.srcIn,
                                ),
                                child: Image.asset(
                                  showPassword
                                      ? "assets/auth_assets/icons/ic_eye_active.png"
                                      : "assets/auth_assets/icons/ic_eye_unactive.png",
                                  width: 18,
                                  height: 18,
                                ),
                              ),
                            ),
                            onFocusChange: (hasFocus) {
                              setState(() {
                                passwordFocused = hasFocus;
                              });
                            },
                          ),

                          const SizedBox(height: 14),

                          /// REMEMBER
                          Row(
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: Checkbox(
                                  value: rememberMe,
                                  onChanged: (val) {
                                    setState(() {
                                      rememberMe = val ?? false;
                                    });
                                  },
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "Ingat Saya",
                                style: AppTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              const Spacer(),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/forgot-password',
                                  );
                                },
                                child: Text(
                                  "Lupa Password ?",
                                  style: AppTextStyle.semiBold.copyWith(
                                    color: AppColors.primaryBlue,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 24),

                          /// LOGIN BUTTON
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: isLoading ? null : validateAndLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFFF9800),
                                disabledBackgroundColor: const Color(
                                  0xFFFFB84D,
                                ),
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: isLoading
                                  ? const TernakProBoxLoading()
                                  : Text(
                                      "Masuk",
                                      style: AppTextStyle.semiBold.copyWith(
                                        fontSize: 15,
                                        color: Colors.white,
                                      ),
                                    ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          /// REGISTER
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Belum punya akun ? ",
                                style: AppTextStyle.regular.copyWith(
                                  fontSize: 12,
                                  color: Colors.black87,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  "Daftar",
                                  style: AppTextStyle.semiBold.copyWith(
                                    fontSize: 12,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// =====================
            /// ERROR NOTIFICATION
            /// =====================
            if (errorMessage != null)
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: FadeTransition(
                    opacity: _notifOpacity!,
                    child: Material(
                      color: Colors.transparent,
                      elevation: 10,
                      child: Container(
                        color: AppColors.primaryRed,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                        child: Text(
                          errorMessage!,
                          style: AppTextStyle.semiBold.copyWith(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),

            /// =====================
            /// FULLSCREEN LOADING
            /// =====================
            if (isLoading)
              Positioned.fill(
                child: Container(
                  color: Colors.white54,
                  child: const Center(child: TernakProBoxLoading()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
