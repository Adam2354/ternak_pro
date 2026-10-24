import 'package:flutter/material.dart';
import 'package:ternak_pro/shared/theme.dart';
import '../../shared/custom_loading.dart';
import '../../shared/widgets/register_app_textfield.dart';
import '../../services/api_service.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage>
    with SingleTickerProviderStateMixin {
  bool rememberMe = false;
  bool showPassword = false;
  bool showPasswordConfirmation = false;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController noTeleponController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passwordConfirmationController =
      TextEditingController();
  final TextEditingController nameController = TextEditingController();

  bool emailError = false;
  bool noTeleponError = false;
  bool passwordError = false;
  bool passwordConfirmationError = false;
  bool nameError = false;
  bool noTeleponFocused = false;
  bool emailFocused = false;
  bool passwordFocused = false;
  bool passwordConfirmationFocused = false;
  bool nameFocused = false;
  String? errorMessage;
  String? successMessage;
  int selectedRoleId = 3;

  bool isLoading = false;

  final emailRegex = RegExp(r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$");
  final noTeleponRegex = RegExp(r"^(?:\+62|62|0)8[1-9][0-9]{6,9}$");

  AnimationController? _notifAnimController;
  Animation<double>? _notifOpacity;

  final ApiService _apiService = ApiService();

  @override
  void initState() {
    super.initState();
    _notifAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
      reverseDuration: const Duration(milliseconds: 350),
      value: 1,
    );
    _notifOpacity = CurvedAnimation(
      parent: _notifAnimController!,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _notifAnimController?.dispose();
    emailController.dispose();
    noTeleponController.dispose();
    passwordController.dispose();
    passwordConfirmationController.dispose();
    nameController.dispose();
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

  void showSuccess(String msg) {
    setState(() {
      successMessage = msg;
      _notifAnimController?.forward(from: 0);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && successMessage == msg) {
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
          successMessage = null;
          emailError = false;
          noTeleponError = false;
          passwordError = false;
          passwordConfirmationError = false;
          nameError = false;
        });
      }
    });
  }

  Future<void> validateAndRegister() async {
    setState(() {
      noTeleponError = false;
      emailError = false;
      passwordError = false;
      passwordConfirmationError = false;
      nameError = false;
      errorMessage = null;
      isLoading = true; // Mulai loading

      String email = emailController.text.trim();
      String noTelepon = noTeleponController.text.trim();
      String password = passwordController.text;
      String passwordConfirmation = passwordConfirmationController.text;
      String name = nameController.text.trim();

      if (email.isEmpty || password.isEmpty || name.isEmpty) {
        emailError = email.isEmpty;
        passwordError = password.isEmpty;
        nameError = name.isEmpty;
      }
      if (!emailRegex.hasMatch(email)) {
        emailError = true;
        isLoading = false;
        showError("Format email tidak valid!");
        return;
      }
      if (noTelepon.isNotEmpty && !noTeleponRegex.hasMatch(noTelepon)) {
        noTeleponError = true;
        isLoading = false;
        showError("Format No Telepon tidak valid!");
        return;
      }
      if (password.length < 8) {
        passwordError = true;
        isLoading = false;
        showError("Password minimal 8 karakter!");
        return;
      }
      if (password != passwordConfirmation) {
        passwordConfirmationError = true;
        isLoading = false;
        showError("Konfirmasi password tidak cocok!");
        return;
      }
    });

    // Proses registrasi
    try {
      final user = await _apiService.register(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
        passwordConfirmation: passwordConfirmationController.text,
        roleId: selectedRoleId,
        noTelepon: noTeleponController.text.trim().isEmpty
            ? null
            : noTeleponController.text.trim(),
      );
      // Tampilkan pesan selamat datang
      if (mounted) {
        showSuccess("Selamat datang, ${user.name}! Registrasi berhasil.");
        Future.delayed(const Duration(seconds: 2), () {
          isLoading = false;
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/login');
          }
        });
      }
    } catch (e) {
      if (mounted) {
        isLoading = false;
        showError(e.toString().replaceFirst('Exception: ', ''));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      resizeToAvoidBottomInset: false, // <- penting: biar keyboard overlay
      body: Stack(
        clipBehavior: Clip.none,
        children: [
          // Background gradient
          Container(
            height: width * 1.1,
            decoration: const BoxDecoration(gradient: AppColors.gradasi02),
          ),

          Positioned(
            bottom: -115,
            left: 0,
            right: 0,
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Image.asset(
                'assets/banner_bottom.png',
                width: MediaQuery.of(context).size.width,
                fit: BoxFit.fill,
              ),
            ),
          ),

          // Content
          SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 56),
                // Logo
                Image.asset("assets/ic_launcher.png", width: 56, height: 56),
                const SizedBox(height: 16),
                // Title
                Text(
                  "Daftar Akun",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.extraBold.copyWith(
                    fontSize: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                // Subtitle
                Text(
                  "Masukkan data diri dibawah untuk lanjut",
                  textAlign: TextAlign.center,
                  style: AppTextStyle.regular.copyWith(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                // Card
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((0.07).round()),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nama Lengkap
                      RegisterAppTextfield(
                        controller: nameController,
                        label: "Nama Lengkap",
                        hintText: "Masukkan nama lengkap kamu",
                        error: nameError,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              nameFocused && !nameError
                                  ? AppColors.black100
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: Icon(Icons.person, size: 20),
                          ),
                        ),
                        onFocusChange: (hasFocus) {
                          setState(() {
                            nameFocused = hasFocus;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      // No Telepon Field
                      RegisterAppTextfield(
                        controller: noTeleponController,
                        label: "No Telepon",
                        hintText: "081234656780",
                        error: noTeleponError,
                        keyboardType: TextInputType.number,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              noTeleponFocused && !noTeleponError
                                  ? AppColors.black100
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/auth_assets/icons/ic_phone.png",
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                        onFocusChange: (hasFocus) {
                          setState(() {
                            noTeleponFocused = hasFocus;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      // Email Field
                      RegisterAppTextfield(
                        controller: emailController,
                        label: "Email",
                        hintText: "johndoe@gmail.com",
                        error: emailError,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              emailFocused && !emailError
                                  ? AppColors.black100
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/auth_assets/icons/ic_mail.png",
                              width: 12,
                              height: 12,
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
                      // Password Field
                      RegisterAppTextfield(
                        controller: passwordController,
                        label: "Password",
                        hintText: "Masukkan password kamu",
                        error: passwordError,
                        obscureText: !showPassword,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              passwordFocused && !passwordError
                                  ? AppColors.black100
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/auth_assets/icons/ic_lock.png",
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              showPassword
                                  ? AppColors.primaryBlue
                                  : (passwordFocused && !passwordError
                                        ? AppColors.black100
                                        : Colors.grey),
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              showPassword
                                  ? "assets/auth_assets/icons/ic_eye_active.png"
                                  : "assets/auth_assets/icons/ic_eye_unactive.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              showPassword = !showPassword;
                            });
                          },
                        ),
                        onFocusChange: (hasFocus) {
                          setState(() {
                            passwordFocused = hasFocus;
                          });
                        },
                      ),
                      const SizedBox(height: 14),
                      // Password Confirmation Field
                      RegisterAppTextfield(
                        controller: passwordConfirmationController,
                        label: "Konfirmasi Password",
                        hintText: "Masukkan konfirmasi password",
                        error: passwordConfirmationError,
                        obscureText: !showPasswordConfirmation,
                        prefixIcon: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              passwordConfirmationFocused &&
                                      !passwordConfirmationError
                                  ? AppColors.black100
                                  : Colors.grey,
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              "assets/auth_assets/icons/ic_lock.png",
                              width: 12,
                              height: 12,
                            ),
                          ),
                        ),
                        suffixIcon: IconButton(
                          icon: ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              showPasswordConfirmation
                                  ? AppColors.primaryBlue
                                  : (passwordConfirmationFocused &&
                                            !passwordConfirmationError
                                        ? AppColors.black100
                                        : Colors.grey),
                              BlendMode.srcIn,
                            ),
                            child: Image.asset(
                              showPasswordConfirmation
                                  ? "assets/auth_assets/icons/ic_eye_active.png"
                                  : "assets/auth_assets/icons/ic_eye_unactive.png",
                              width: 20,
                              height: 20,
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              showPasswordConfirmation =
                                  !showPasswordConfirmation;
                            });
                          },
                        ),
                        onFocusChange: (hasFocus) {
                          setState(() {
                            passwordConfirmationFocused = hasFocus;
                          });
                        },
                      ),

                      const SizedBox(height: 35),

                      // Register Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: validateAndRegister,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            elevation: 0,
                            backgroundColor: AppColors.primaryYellow,
                          ),
                          child: Text(
                            "Daftar",
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),
                      // Divider with text
                      Row(
                        children: [
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: AppColors.black50,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Text(
                              "Atau",
                              style: AppTextStyle.regular.copyWith(
                                color: AppColors.black50,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          const Expanded(
                            child: Divider(
                              thickness: 1,
                              color: AppColors.black50,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),
                      // Google Button
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: Image.asset(
                            "assets/auth_assets/icons/ic_google.png",
                            width: 24,
                            height: 24,
                          ),
                          label: Text(
                            "Masuk Dengan Google",
                            style: AppTextStyle.semiBold.copyWith(
                              color: AppColors.black100,
                              fontSize: 16,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: AppColors.black100),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          onPressed: () {
                            // Tambahkan logika untuk login dengan Google jika diperlukan
                            _showFeatureUserNotAvailableDialog(context);
                          },
                        ),
                      ),
                      const SizedBox(height: 18),

                      // Login Link
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Sudah punya akun? ",
                            style: AppTextStyle.regular.copyWith(fontSize: 13),
                          ),
                          GestureDetector(
                            onTap: () {
                              Navigator.pushNamed(context, '/login');
                            },
                            child: Text(
                              "Masuk",
                              style: AppTextStyle.semiBold.copyWith(
                                color: AppColors.primaryYellow,
                                fontSize: 13,
                                decoration: TextDecoration.underline,
                                decorationColor: AppColors.primaryYellow,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),

          // Back button
          Positioned(
            top: 40,
            left: 16,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Image.asset(
                "assets/auth_assets/icons/ic_back.png",
                width: 28,
                height: 28,
              ),
            ),
          ),

          // Error message overlay
          if (errorMessage != null)
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: true,
                child: FadeTransition(
                  opacity: _notifOpacity!,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 20,
                    child: Container(
                      color: AppColors.primaryRed,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: AppTextStyle.semiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (successMessage != null)
            Positioned(
              top: 56,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: true,
                child: FadeTransition(
                  opacity: _notifOpacity!,
                  child: Material(
                    color: Colors.transparent,
                    elevation: 20,
                    child: Container(
                      color: AppColors.green01,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              successMessage!,
                              style: AppTextStyle.semiBold.copyWith(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white60, // Latar belakang semi-transparan
                child: const Center(child: TernakProBoxLoading()),
              ),
            ),
        ],
      ),
    );
  }
}

void _showFeatureUserNotAvailableDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        title: const Text(
          'Informasi',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: const Text(
          'Mohon maaf saat ini Registrasi dengan Google belum dapat digunakan, silakan google dengan email dan password.',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text(
              'OK',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
