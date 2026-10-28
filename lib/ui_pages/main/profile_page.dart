import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ternak_pro/services/api_service.dart';
import 'package:ternak_pro/shared/widgets/profile_setting_item.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../cubit/page_cubit.dart';
import '../../services/loc_service.dart';
import '../../shared/custom_loading.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/custom_image_view.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isLoading = false; // Menambahkan status loading

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  // Fungsi logout yang memanggil metode logout dari ApiService
  Future<void> _logOut(BuildContext context) async {
    // Tampilkan modal konfirmasi
    final bool? shouldLogout = await showLogoutConfirmationDialog(context);

    if (shouldLogout != true) {
      return; // Jika pengguna membatalkan logout, keluar dari fungsi
    }

    setState(() {
      _isLoading = true; // Mulai loading
    });

    try {
      // Tambahkan jeda waktu untuk menunjukkan loading (misalnya 1,5 detik)
      await Future.delayed(const Duration(milliseconds: 4000));

      // Memanggil logout melalui instance ApiService
      await ApiService.logout(context);
    } catch (e) {
      print("Error during logout: $e");
      // Tampilkan pesan error kepada pengguna
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal logout: $e',
            style: AppTextStyle.medium.copyWith(
              fontSize: 14,
              color: AppColors.white100,
            ),
          ),
          backgroundColor: AppColors.red,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false; // Selesai loading
      });
    }
  }

  // Fungsi untuk menampilkan modal konfirmasi logout
  Future<bool?> showLogoutConfirmationDialog(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false, // Tidak bisa menutup dialog dengan tap di luar
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: AppColors.bgLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          contentPadding: const EdgeInsets.all(16),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Ikon logout
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  gradient: AppColors.gradasi01WithOpacity20,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Icon(
                    Icons.logout,
                    size: 34,
                    color: AppColors.black100,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              // Judul
              Text(
                'Konfirmasi Logout',
                textAlign: TextAlign.center,
                style: AppTextStyle.semiBold.copyWith(
                  fontSize: 18,
                  color: AppColors.black100,
                ),
              ),
              const SizedBox(height: 12),
              // Pesan
              Text(
                'Apakah Anda yakin ingin keluar dari akun Anda?',
                textAlign: TextAlign.center,
                style: AppTextStyle.medium.copyWith(
                  fontSize: 14,
                  color: AppColors.black100,
                ),
              ),
              const SizedBox(height: 16),
              // Tombol
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Tombol Batal
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            color: AppColors.blue10,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(
                                context,
                              ).pop(false); // Kembalikan false untuk batal
                            },
                            child: Center(
                              child: Text(
                                'Batal',
                                style: AppTextStyle.semiBold.copyWith(
                                  fontSize: 16,
                                  color: AppColors.black100,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Tombol Keluar
                  Expanded(
                    child: SizedBox(
                      height: 50,
                      child: Material(
                        color: Colors.transparent,
                        child: Ink(
                          decoration: BoxDecoration(
                            gradient: AppColors.gradasi01,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(16),
                            onTap: () {
                              Navigator.of(context).pop(
                                true,
                              ); // Kembalikan true untuk lanjut logout
                            },
                            child: Center(
                              child: Text(
                                'Keluar',
                                style: AppTextStyle.semiBold.copyWith(
                                  fontSize: 16,
                                  color: AppColors.white100,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String dataUser = '';
  String email = '';
  Future<void> loadUserData() async {
    final credential = await ApiService().loadCredentials(); // Await the Future
    setState(() {
      dataUser = credential['name'] ?? ''; // Safe access with default value
      email = credential['email'] ?? ''; // Safe access with default value
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: const Key('profile_page'),
      body: Stack(
        children: [
          // Konten utama
          SingleChildScrollView(
            child: Column(
              children: [
                _buildHeaderSection(context, dataUser),
                _pribadiSettings(context, dataUser, email),
                _aplikasiSettings(context),
                _panduanSettings(context),
                _logOutSettings(context),
                const SizedBox(height: 110), // Spacing at the bottom
              ],
            ),
          ),
          // Indikator loading
          if (_isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.white60, // Background transparan
                child: Center(child: TernakProBoxLoading()),
              ),
            ),
        ],
      ),
    );
  }

  Widget _logOutSettings(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 20, left: 24, right: 24),
      transform: Matrix4.translationValues(0, 0, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8),

          ProfileSettingItem(
            imageUrl: 'assets/profile_assets/icons/ic_out.png',
            bgImage: Color(0XFFFFE0D5),
            menuName: 'Keluar Akun',
            placeHolder: '',
            onTap: () {
              // Memanggil fungsi logout saat item di-tap
              _logOut(context);
            },
          ),
        ],
      ),
    );
  }
}

Widget _buildHeaderSection(BuildContext context, dataUser) {
  return Container(
    height: MediaQuery.of(context).size.height * 0.18,
    width: double.infinity,
    decoration: BoxDecoration(
      gradient: AppColors.gradasi01,
      borderRadius: BorderRadius.only(
        bottomRight: Radius.circular(20),
        bottomLeft: Radius.circular(20),
      ),
    ),
    child: Stack(
      children: [
        CustomImageView(
          imagePath: "assets/home_assets/images/img_star.png",
          height: MediaQuery.of(context).size.height * 0.15,
          width: double.infinity,
          fit: BoxFit.cover,
        ),
        Positioned(
          top: 65,
          left: 24,
          right: 24,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  InkWell(
                    onTap: () => _showFeatureUserNotAvailableDialog(context),
                    child: Stack(
                      children: [
                        Container(
                          width: 75,
                          height: 75,
                          decoration: BoxDecoration(
                            border: BoxBorder.all(
                              color: AppColors.primaryWhite,
                              width: 0.3,
                            ),
                            borderRadius: BorderRadius.circular(100),
                          ),
                          child: Image.asset(
                            'assets/profile_assets/icons/ic_farmer.png',
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            width: 23,
                            height: 23,
                            padding: EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.primaryWhite,
                              borderRadius: BorderRadius.circular(100),
                            ),
                            child: Image.asset(
                              'assets/profile_assets/icons/ic_pencil.png',
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Peternakan',
                        style: AppTextStyle.medium.copyWith(
                          fontSize: 18,
                          color: AppColors.white100,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        dataUser,
                        style: AppTextStyle.extraBold.copyWith(
                          fontSize: 20,
                          color: AppColors.white100,
                          overflow: TextOverflow.ellipsis,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 5,
          bottom: 0,
          child: Row(
            children: [
              Column(
                children: [
                  SizedBox(height: 12),
                  CustomImageView(
                    imagePath: "assets/home_assets/images/img_amelia_1_3.png",
                    height: 28,
                    width: 32,
                  ),
                ],
              ),
              SizedBox(width: 8),
              CustomImageView(
                imagePath: "assets/home_assets/images/img_amelia_1_4.png",
                height: 40,
                width: 32,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 31,
          child: Row(
            children: [
              CustomImageView(
                imagePath: "assets/home_assets/images/img_amelia_1_1.png",
                height: 40,
                width: 28,
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Row(
            children: [
              CustomImageView(
                imagePath: "assets/home_assets/images/img_amelia_1_2.png",
                height: 36,
                width: 32,
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _pribadiSettings(BuildContext context, dataUser, email) {
  return Container(
    margin: EdgeInsets.only(top: 20, left: 24, right: 24),
    transform: Matrix4.translationValues(0, 0, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan Pribadi',
          style: AppTextStyle.semiBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_user.png',
          bgImage: Color(0XFFFFE0D5),
          menuName: 'Username',
          placeHolder: dataUser,
          onTap: () {
            _showFeatureUserNotAvailableDialog(context);
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_mail.png',
          bgImage: Color(0XFFFFF0C8),
          menuName: 'Email',
          placeHolder: email,
          onTap: () {
            _showFeatureUserNotAvailableDialog(context);
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_lock.png',
          bgImage: Color(0XFFD4F4F1),
          menuName: 'Kata Sandi',
          placeHolder: '********',
          onTap: () {
            _showFeatureUserNotAvailableDialog(context);
          },
        ),
      ],
    ),
  );
}

Widget _aplikasiSettings(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 20, left: 24, right: 24),
    transform: Matrix4.translationValues(0, 0, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pengaturan Aplikasi',
          style: AppTextStyle.semiBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        FutureBuilder<Map<String, dynamic>?>(
          future: LocationStorageService.loadLocation(),
          builder: (context, snapshot) {
            final address = snapshot.hasData ? snapshot.data!['address'] : null;

            return ProfileSettingItem(
              imageUrl: 'assets/profile_assets/icons/ic_loc.png',
              bgImage: Color(0XFFDCE8F7),
              menuName: 'Lokasi Ternak',
              placeHolder: snapshot.connectionState == ConnectionState.waiting
                  ? 'Memuat...'
                  : address ?? 'Tambahkan Lokasi',
              onTap: () {
                _showFeatureLocDialog(context);
              },
            );
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_bell.png',
          bgImage: Color(0XFFFFF0C8),
          menuName: 'Pemberitahuan',
          placeHolder: 'Izinkan',
          onTap: () {
            _showFeatureNotAvailableDialog(context);
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_mode.png',
          bgImage: Color(0XFFF8D5FF),
          menuName: 'Mode Gelap',
          placeHolder: 'Terang',
          onTap: () {
            _showFeatureNotAvailableDialog(context);
          },
        ),
      ],
    ),
  );
}

// Fungsi untuk menampilkan custom modal
void _showFeatureNotAvailableDialog(BuildContext context) {
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
          'Mohon maaf saat ini fitur belum dapat digunakan',
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

void _showFeatureLocDialog(BuildContext context) {
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
          'Anda dapat mengubah lokasi saat ini pada halaman utama',
          style: TextStyle(fontSize: 16),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Tutup dialog
            },
            child: const Text(
              'Kembali',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<PageCubit>().setPage(0); // Tutup dialog
            },
            child: const Text(
              'Halaman utama',
              style: TextStyle(
                color: Color.fromARGB(255, 11, 58, 46),
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
          'Mohon maaf saat ini fitur untuk mengubah data pengguna belum dapat digunakan',
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

Widget _panduanSettings(BuildContext context) {
  return Container(
    margin: EdgeInsets.only(top: 20, left: 24, right: 24),
    transform: Matrix4.translationValues(0, 0, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Panduan Aplikasi',
          style: AppTextStyle.semiBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_loc.png',
          bgImage: Color(0XFFD5E7FF),
          menuName: 'FAQ',
          placeHolder: '',
          onTap: () {
            Uri url = Uri.parse('https://hawariyyun.my.id/#faq');
            launchUrl(url);
            // Navigator.pushNamed(context, '/ternakpro-web');
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_feature.png',
          bgImage: Color(0XFFFFEDD5),
          menuName: 'Fitur',
          placeHolder: '',
          onTap: () {
            Uri url = Uri.parse('https://hawariyyun.my.id/#fitur');
            launchUrl(url);
            // Navigator.pushNamed(context, '/ternakpro-web');
          },
        ),
        ProfileSettingItem(
          imageUrl: 'assets/profile_assets/icons/ic_phone.png',
          bgImage: Color(0XFFD5F8F7),
          menuName: 'Hubungi Kami',
          placeHolder: '',
          onTap: () {
            Uri url = Uri.parse('https://hawariyyun.my.id');
            launchUrl(url);
            // Navigator.pushNamed(context, '/ternakpro-web');
          },
        ),
      ],
    ),
  );
}
