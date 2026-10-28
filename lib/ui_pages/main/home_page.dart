import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:latlong2/latlong.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ternak_pro/models/BannerItem.dart';

import '../../models/DailyTaskItem.dart';
import '../../models/TipsItem.dart';
import '../../services/api_service.dart';
import '../../services/cache_service.dart';
import '../../services/loc_service.dart';
import '../../shared/custom_loading.dart';
import '../../shared/theme.dart';
import '../../shared/widgets/home/daily_task.dart';
import '../../shared/widgets/custom_image_view.dart';
import '../../shared/widgets/daily_tip_card.dart';
import '../../shared/widgets/featured_service_card.dart';

Future<bool> hasSeenBanner() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool('hasSeenBanner') ?? false;
}

Future<void> setBannerSeen() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('hasSeenBanner', true);
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const _cachedBannersKey = 'cached_active_banners';
  String greeting = 'Hai Selamat Pagi,';
  String formattedDate = '';
  Timer? _timer;
  Position? currentPosition; // Store the GPS position
  bool _isLoadingLocation = false; // Track loading state
  List<DailyTaskItem> _tasks = [];
  bool _isLoadingTasks = false;
  String? _errorMessage;

  LatLng? _selectedLocation = LatLng(-6.9733626, 107.630346);
  String? _currentAddress = "Lokasi belum dipilih";

  bool _isLoadingFromStorage = true;

  final ApiService _apiService = ApiService(); // Initialize your ApiService

  bool _isInitialLoad = true;
  bool _isRefreshing = false;

  List<TipsItem> _tips = [];
  bool _isLoadingTips = false;

  String dataUser = '';

  String get _dailyFeedStatus {
    for (final task in _tasks) {
      final title = task.title.toLowerCase();
      if (title.contains('pakan') || title.contains('air')) {
        return task.status.isEmpty ? 'Belum' : task.status;
      }
    }
    return 'Belum';
  }

  @override
  void initState() {
    super.initState();
    _updateGreetingAndDate();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _updateGreetingAndDate();
    }); // Fetch location on init
    loadUserData();
    _fetchTasks();
    _loadSavedLocation();
    _initializePageData();
    _checkAndShowBanner(); //
  }

  void _checkAndShowBanner() async {
    final seen = await hasSeenBanner();
    if (!seen) {
      final cachedBanners = await _loadCachedBanners();
      if (!mounted) return;
      if (cachedBanners.isNotEmpty) {
        _showBannerDialogs(cachedBanners);
      }

      try {
        final banners = await _apiService.fetchBanners().timeout(
          const Duration(seconds: 6),
        );
        if (!mounted) return;
        await _saveCachedBanners(banners);
        if (cachedBanners.isEmpty && banners.isNotEmpty) {
          _showBannerDialogs(banners);
        }
      } catch (e) {
        debugPrint('Failed to load banners: $e');
      }
    }
  }

  Future<List<BannerItem>> _loadCachedBanners() async {
    final prefs = await SharedPreferences.getInstance();
    final rawBanners = prefs.getStringList(_cachedBannersKey) ?? const [];
    final banners = <BannerItem>[];

    for (final rawBanner in rawBanners) {
      try {
        final decoded = jsonDecode(rawBanner);
        if (decoded is Map) {
          final banner = BannerItem.fromJson(
            Map<String, dynamic>.from(decoded),
          );
          if (banner.bannerUrl.isNotEmpty) {
            banners.add(banner);
          }
        }
      } catch (_) {
        // Abaikan satu entri cache yang rusak dan tetap gunakan entri lainnya.
      }
    }

    return banners;
  }

  Future<void> _saveCachedBanners(List<BannerItem> banners) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _cachedBannersKey,
      banners.map((banner) => jsonEncode(banner.toJson())).toList(),
    );
  }

  void _showBannerDialogs(List<BannerItem> banners) {
    int currentIndex = 0;

    void showNextBanner() {
      if (currentIndex >= banners.length) {
        setBannerSeen();
        return;
      }

      final banner = banners[currentIndex];

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return Dialog(
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 40,
            ),
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                // Konten banner dengan border radius
                ClipRRect(
                  borderRadius: BorderRadius.circular(18),
                  child: Image.network(
                    normalizeAssetUrl(banner.bannerUrl),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }

                      return const Center(child: CircularProgressIndicator());
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.error, color: Colors.red, size: 50),
                      );
                    },
                  ),
                ),

                // Tombol close di pojok kanan atas
                Positioned(
                  top: 12,
                  right: 12,
                  child: GestureDetector(
                    onTap: () {
                      Navigator.of(context).pop();
                      currentIndex++;
                      showNextBanner();
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black54,
                      child: Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    }

    showNextBanner();
  }

  Future<void> _initializePageData() async {
    // Load data yang tidak perlu caching dulu
    _getCurrentLocation();
    _initializeLocation();

    // Load data dengan caching system
    await _loadUserDataWithCache();
    await _loadTasksWithCache();
    await _loadTipsWithCache(); // Tambahkan ini

    if (mounted) {
      setState(() => _isInitialLoad = false);
    }
  }

  Future<void> _loadUserDataWithCache() async {
    // Coba load dari cache dulu jika masih valid
    final isCacheValid = await CacheService.isCacheValid();
    final cachedUserData = await CacheService.getCachedUserData();

    if (isCacheValid && cachedUserData != null) {
      if (mounted) {
        setState(() {
          dataUser = cachedUserData;
        });
      }
    } else {
      // Jika cache tidak valid atau tidak ada, load dari API
      await loadUserData();
    }

    // Always refresh in background untuk data terbaru
    _refreshUserDataInBackground();
  }

  Future<void> loadUserData() async {
    try {
      final credential = await _apiService.loadCredentials();
      final newDataUser = credential['name'] ?? '';

      // Simpan ke cache
      await CacheService.cacheUserData(newDataUser);

      if (mounted) {
        setState(() {
          dataUser = newDataUser;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
    }
  }

  Future<void> _loadTasksWithCache() async {
    // Coba load dari cache dulu jika masih valid
    final isCacheValid = await CacheService.isCacheValid();
    final cachedTasksData = await CacheService.getCachedTasksData();

    if (isCacheValid && cachedTasksData != null) {
      if (mounted) {
        setState(() {
          _tasks = cachedTasksData
              .map((item) => DailyTaskItem.fromJson(item))
              .toList();
          _isLoadingTasks = false;
        });
      }
    } else {
      // Jika cache tidak valid atau tidak ada, load dari API
      await _fetchTasks();
    }

    // Always refresh in background untuk data terbaru
    _refreshTasksInBackground();
  }

  Future<void> _refreshUserDataInBackground() async {
    try {
      final credential = await _apiService.loadCredentials();
      final newDataUser = credential['name'] ?? '';

      // Update cache
      await CacheService.cacheUserData(newDataUser);

      // Update UI hanya jika berbeda
      if (mounted && newDataUser != dataUser) {
        setState(() {
          dataUser = newDataUser;
        });
      }
    } catch (e) {
      print('Background user data refresh failed: $e');
    }
  }

  Future<void> _refreshTasksInBackground() async {
    try {
      final credential = await _apiService.loadCredentials();
      final userId = credential['user_id'];
      final newTasks = await _apiService.getTugasUserAll(userId);

      // Update cache
      await CacheService.cacheTasksData(
        newTasks.map((task) => task.toJson()).toList(),
      );

      // Update UI hanya jika berbeda
      if (mounted) {
        setState(() {
          _tasks = newTasks;
        });
      }
    } catch (e) {
      print('Background tasks refresh failed: $e');
    }
  }

  Future<bool> _deleteTaskFromHome(DailyTaskItem task) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus tugas'),
        content: Text('Hapus tugas "${task.title}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    if (confirmed != true) return false;

    try {
      final credentials = await _apiService.loadCredentials();
      final userId = credentials['user_id'];
      if (userId is! String || userId.isEmpty) {
        throw Exception('Sesi pengguna tidak ditemukan');
      }

      await _apiService.deleteTugas(userId, task.idTugas);
      await CacheService.cacheTasksData(
        _tasks
            .where((item) => item.idTugas != task.idTugas)
            .map((item) => item.toJson())
            .toList(),
      );
      if (!mounted) return true;
      setState(() {
        _tasks.removeWhere((item) => item.idTugas == task.idTugas);
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Tugas dihapus')));
      return true;
    } catch (e) {
      if (!mounted) return false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menghapus tugas: $e')));
      return false;
    }
  }

  // Fetch tasks dynamically from the server
  Future<void> _fetchTasks() async {
    if (mounted) {
      setState(() {
        _isLoadingTasks = true;
        _errorMessage = null;
      });
    }

    try {
      final credential = await _apiService.loadCredentials();
      final userId = credential['user_id'];
      final tasks = await _apiService.getTugasUserAll(userId);

      // Simpan ke cache
      await CacheService.cacheTasksData(
        tasks.map((task) => task.toJson()).toList(),
      );

      if (mounted) {
        setState(() {
          _tasks = tasks;
          _isLoadingTasks = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _tasks = [];
          _errorMessage = null;
          _isLoadingTasks = false;
        });
      }
    }
  }

  Future<void> _handleRefresh() async {
    if (mounted) {
      setState(() => _isRefreshing = true);
    }

    try {
      // Refresh semua data secara manual
      await Future.wait([
        _refreshUserDataInBackground(),
        _refreshTasksInBackground(),
        _refreshTipsInBackground(),
        _getCurrentLocation(),
      ]);

      // Update cache timestamp
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_cache_time', DateTime.now().toString());
    } catch (e) {
      print('Refresh failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeLocation() async {
    // Coba load dari storage dulu
    await _loadSavedLocation();

    // Jika tidak ada yang tersimpan, set default
    if (_selectedLocation == null) {
      if (mounted) {
        setState(() {
          _selectedLocation = LatLng(-6.2088, 106.8456); // Default Jakarta
          _currentAddress = 'Tambahkan Lokasi';
          _isLoadingFromStorage = false;
        });
      }
    }
  }

  void _updateGreetingAndDate() {
    final now = DateTime.now();
    final hour = now.hour;
    final minute = now.minute;

    // Tentukan salam berdasarkan waktu
    if ((hour == 2 && minute >= 1) || (hour > 2 && hour <= 11)) {
      greeting = 'Hai Selamat Pagi,';
    } else if (hour > 11 && hour <= 15) {
      greeting = 'Hai Selamat Siang,';
    } else if (hour > 15 && hour <= 18) {
      greeting = 'Hai Selamat Sore,';
    } else {
      greeting = 'Hai Selamat Malam,';
    }

    // Format tanggal ke "Nama Hari, DD Bulan YYYY"
    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    formattedDate = dateFormat.format(now);

    if (mounted) {
      setState(() {});
    }
  }

  // Check and request location permissions
  Future<bool> _handleLocationPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    if (kIsWeb) {
      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak.')));
          }
          return false;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Izin lokasi ditolak secara permanen. Silakan izinkan di pengaturan browser.',
              ),
            ),
          );
        }
        return false;
      }
      return true;
    }

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Layanan lokasi dinonaktifkan. Aktifkan untuk melanjutkan.',
            ),
          ),
        );
      }
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Izin lokasi ditolak.')));
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Izin lokasi ditolak secara permanen. Silakan izinkan di pengaturan.',
            ),
          ),
        );
      }
      return false;
    }

    return true;
  }

  // Load lokasi yang tersimpan saat init
  Future<void> _loadSavedLocation() async {
    setState(() => _isLoadingFromStorage = true);

    try {
      final savedLocation = await LocationStorageService.loadLocation();
      if (savedLocation != null) {
        if (mounted) {
          setState(() {
            _selectedLocation = savedLocation['location'];
            _currentAddress = savedLocation['address'];
          });
        }
      }
    } catch (e) {
      print('Error loading saved location: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingFromStorage = false);
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    if (mounted) {
      setState(() {
        _isLoadingLocation = true;
      });
    }

    if (kIsWeb) {
      // Web-specific fallback for testing
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Lokasi otomatis tidak tersedia di web. Silakan pilih lokasi secara manual.',
            ),
          ),
        );
      }
      return;
    }

    final hasPermission = await _handleLocationPermission();
    if (!hasPermission) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = null;
        });
      }
      return;
    }

    try {
      Position position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 10),
          ).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              throw TimeoutException(
                'Gagal mendapatkan lokasi dalam waktu yang ditentukan.',
              );
            },
          );

      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // Check if placemarks is not empty
      if (placemarks.isEmpty) {
        throw Exception('Tidak ada data placemark yang ditemukan.');
      }

      Placemark place = placemarks[0];
      // Ensure placemark fields are not null
      String address = [
        place.subLocality ?? '',
        place.locality ?? '',
        place.administrativeArea ?? '',
      ].where((e) => e.isNotEmpty).join(', ').trim();

      if (address.isEmpty) {
        address = 'Lokasi tidak dikenal';
      }

      if (mounted) {
        setState(() {
          currentPosition = position;
          _currentAddress = address;
          _isLoadingLocation = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingLocation = false;
          _currentAddress = null;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mendapatkan lokasi: ${e.toString()}')),
        );
      }
    }
  }

  Future<void> _selectLocationManually() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => Dialog(
        insetPadding: EdgeInsets.all(16),
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.8,
          child: LocationPickerDialog(
            initialLocation: _selectedLocation,
            initialAddress: _currentAddress,
          ),
        ),
      ),
    );

    if (result != null && result['location'] != null) {
      // Simpan ke local storage
      await LocationStorageService.saveLocation(
        result['location'],
        result['address'] ?? 'Lokasi terpilih',
      );

      if (mounted) {
        setState(() {
          _selectedLocation = result['location'];
          _currentAddress = result['address'] ?? 'Lokasi terpilih';
        });
      }
    }
  }

  // Optional: Fungsi untuk menghapus lokasi
  Future<void> _clearLocation() async {
    await LocationStorageService.clearLocation();
    if (mounted) {
      setState(() {
        _selectedLocation = null;
        _currentAddress = null;
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Lokasi berhasil dihapus')));
    }
  }

  Future<void> _loadTipsWithCache() async {
    print('🔍 Loading tips with cache...');

    // Cek cache dulu
    final cachedTips = await CacheService.getCachedTipsData();
    final isCacheValid = await CacheService.isCacheValid();

    if (isCacheValid && cachedTips != null && cachedTips.isNotEmpty) {
      print('🎯 Using cached tips: ${cachedTips.length} items');
      if (mounted) {
        setState(() {
          _tips = cachedTips;
        });
      }
    } else {
      print('🔄 Cache invalid or empty, fetching from API...');
      await _fetchTips();
    }

    // Always refresh in background
    _refreshTipsInBackground();
  }

  Future<void> _fetchTips() async {
    if (mounted) {
      setState(() => _isLoadingTips = true);
    }

    try {
      print('🔄 Memulai fetch tips...');

      final tips = await _apiService.getTipsItem();
      print('📦 Data dari API: ${tips.length} items');

      // Debug: Print detail setiap tips
      for (var tip in tips) {
        print('📝 Tip: ${tip.judul} - Author: ${tip.author}');
      }

      // Cek apakah data valid sebelum cache
      if (tips.isEmpty) {
        print('⚠️ Data tips kosong dari API');
        // Coba load dari cache sebagai fallback
        final cachedTips = await CacheService.getCachedTipsData();
        if (cachedTips != null && cachedTips.isNotEmpty) {
          print('🔄 Fallback ke cached data: ${cachedTips.length} items');
          if (mounted) {
            setState(() {
              _tips = cachedTips;
              _isLoadingTips = false;
            });
          }
          return;
        }
      }

      // Simpan ke cache hanya jika data tidak empty
      if (tips.isNotEmpty) {
        print('💾 Menyimpan ${tips.length} tips ke cache');
        await CacheService.cacheTipsData(tips);
      }

      if (mounted) {
        setState(() {
          _tips = tips;
          _isLoadingTips = false;
        });
      }

      print('✅ Fetch selesai. Total tips: ${_tips.length}');
    } catch (e) {
      print('❌ Error fetching tips: $e');

      // Fallback ke cache jika error
      final cachedTips = await CacheService.getCachedTipsData();
      if (cachedTips != null && cachedTips.isNotEmpty) {
        print(
          '🔄 Fallback ke cached data karena error: ${cachedTips.length} items',
        );
        if (mounted) {
          setState(() {
            _tips = cachedTips;
          });
        }
      }

      if (mounted) {
        setState(() => _isLoadingTips = false);
      }
    }
  }

  Future<void> _refreshTipsInBackground() async {
    try {
      final tips = await _apiService.getTipsItem();
      await CacheService.cacheTipsData(tips);

      if (mounted) {
        setState(() {
          _tips = tips;
        });
      }
    } catch (e) {
      print('Background tips refresh failed: $e');
    }
  }

  // Modifikasi _buildDailyTips
  Widget _buildDailyTips(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 24),
            child: Text(
              'Tips Harian Kamu',
              style: AppTextStyle.semiBold.copyWith(fontSize: 16),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 135,
            child: _isLoadingTips
                ? const Center(child: TernakProBoxLoading())
                : _tips.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _tips.take(4).length,
                    itemBuilder: (context, index) {
                      final tip = _tips[index];
                      return Row(
                        children: [
                          if (index == 0) const SizedBox(width: 24),
                          DailyTipCardWidget(
                            imagePath: tip.imageUrl,
                            title: tip.judul,
                            author: tip.author,
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                '/tips-harian-detail',
                                arguments: tip,
                              );
                            },
                          ),
                          const SizedBox(width: 8),
                        ],
                      );
                    },
                  ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, '/tips-harian');
              },
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: AppColors.gradasi01WithOpacity20,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Lihat Lainnya →',
                      style: AppTextStyle.semiBold.copyWith(
                        color: AppColors.green01,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.info_outline, size: 40, color: Colors.grey),
          SizedBox(height: 8),
          Text('Belum ada tips tersedia', style: TextStyle(color: Colors.grey)),
          SizedBox(height: 8),
          ElevatedButton(onPressed: _fetchTips, child: Text('Coba Lagi')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _handleRefresh,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildHeaderSection(context, greeting, formattedDate, dataUser),
              _buildStatsCard(context, _dailyFeedStatus),
              _buildFeaturedServices(context),
              _buildDailyTasks(context),
              _buildDailyTips(context),
              SizedBox(height: 110), // Spacing at the bottom

              if (_isRefreshing)
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: CircularProgressIndicator(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Modified buildDailyTasks to handle dynamic tasks, loading, and error states
  Widget _buildDailyTasks(BuildContext context) {
    if (_errorMessage != null) {
      return Center(
        child: Column(
          children: [
            Text(_errorMessage!, style: TextStyle(color: Colors.red)),
            SizedBox(height: 10),
            ElevatedButton(onPressed: _fetchTasks, child: Text('Coba lagi')),
          ],
        ),
      );
    }

    final task2 = _tasks.take(2).toList();

    return buildDailyTasks(
      context,
      task2,
      _isLoadingTasks,
      onDelete: _deleteTaskFromHome,
    ); // Use the dynamic _tasks list
  }

  Widget _buildHeaderSection(
    BuildContext context,
    String greeting,
    String formattedDate,
    String dataUser,
  ) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    // Ukuran dinamis berdasarkan ukuran layar
    double headerHeight = screenHeight * 0.25; // Menyesuaikan tinggi header
    double imageHeight = screenHeight * 0.2; // Menyesuaikan tinggi gambar
    double fontSizeSmall = (screenWidth * 0.05).clamp(
      16.0,
      20.0,
    ); // Responsif untuk ukuran font
    double fontSizeLarge = (screenWidth * 0.06).clamp(
      18.0,
      22.0,
    ); // Responsif untuk ukuran font besar
    double iconSize = (screenWidth * 0.08).clamp(
      20.0,
      36.0,
    ); // Responsif untuk ukuran ikon

    return Container(
      height: headerHeight,
      width: double.infinity,
      decoration: BoxDecoration(gradient: AppColors.gradasi01),
      child: Stack(
        children: [
          CustomImageView(
            imagePath: "assets/home_assets/images/img_star.png",
            height: imageHeight,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          Positioned(
            top: 58,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greeting,
                      style: AppTextStyle.medium.copyWith(
                        fontSize: fontSizeSmall,
                        color: AppColors.white100,
                      ),
                    ),
                    Text(
                      dataUser,
                      style: AppTextStyle.extraBold.copyWith(
                        fontSize: fontSizeLarge,
                        color: AppColors.white100,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Navigator.pushNamed(context, '/notifikasi'),
                  child: Container(
                    width: iconSize,
                    height: iconSize,
                    decoration: BoxDecoration(
                      color: AppColors.white100,
                      borderRadius: BorderRadius.circular(iconSize / 2),
                    ),
                    child: Center(
                      child: CustomImageView(
                        imagePath: "assets/home_assets/icons/ic_bell.png",
                        height: iconSize * 0.6,
                        width: iconSize * 0.6,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 110,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _selectLocationManually,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth: 200, // Sangat ketat
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.white100,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Icon - fixed size
                                Container(
                                  width: 16,
                                  height: 16,
                                  child: CustomImageView(
                                    imagePath:
                                        "assets/home_assets/icons/ic_location.png",
                                    height: 16,
                                    width: 16,
                                  ),
                                ),
                                SizedBox(width: 6),

                                // Loading states
                                if (_isLoadingFromStorage || _isLoadingLocation)
                                  Container(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                else
                                  // Text dengan constraint sangat ketat
                                  Expanded(
                                    // Gunakan Expanded untuk memaksa constraint
                                    child: Container(
                                      constraints: BoxConstraints(
                                        maxWidth:
                                            screenWidth *
                                            0.35, // Maximum untuk text saja
                                      ),
                                      child: Tooltip(
                                        message:
                                            _currentAddress ??
                                            'Tambahkan Lokasi',
                                        child: Text(
                                          _currentAddress ?? 'Tambahkan Lokasi',
                                          style: AppTextStyle.medium.copyWith(
                                            fontSize: 11, // Font lebih kecil
                                            color: _currentAddress == null
                                                ? AppColors.grey
                                                : AppColors.black100,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          softWrap: false,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        if (_currentAddress != null)
                          IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.white100,
                              size: 20,
                            ),
                            onPressed: _clearLocation,
                            tooltip: 'Hapus lokasi',
                          ),
                      ],
                    ),
                    SizedBox(height: 16),
                    CustomImageView(
                      imagePath: "assets/home_assets/images/img_amelia_1_2.png",
                      height: 36,
                      width: 32,
                    ),
                  ],
                ),

                // Optional: Tombol clear location
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            right: 15,
            child: Text(
              formattedDate,
              style: AppTextStyle.medium.copyWith(
                fontSize: fontSizeSmall * 0.6,
                color: AppColors.white100,
              ),
            ),
          ),
          Positioned(
            right: 0,
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
            left: 0,
            child: CustomImageView(
              imagePath: "assets/home_assets/images/img_amelia_1_1.png",
              height: 40,
              width: 28,
            ),
          ),
        ],
      ),
    );
  }
}

final ApiService _apiService = ApiService(); // Initialize your ApiService
// Fungsi untuk mendapatkan jumlah ternak
Future<int> _getTernakUserCount() async {
  final credential = await _apiService.loadCredentials();
  final userId = credential['user_id'];

  try {
    final count = await _apiService.getTernakUserCount(
      userId,
    ); // Panggil fungsi getTernakUserCount untuk mendapatkan jumlah data ternak
    return count; // Mengembalikan jumlah data ternak
  } catch (e) {
    return 0; // Mengembalikan 0 jika gagal
  }
}

Widget _buildStatsCard(BuildContext context, String dailyFeedStatus) {
  return LayoutBuilder(
    builder: (context, constraints) {
      double maxWidth = constraints.maxWidth;

      // Ukuran dinamis
      double fontSizeSmall = (maxWidth * 0.01).clamp(10.0, 14.0);
      double fontSizeMedium = (maxWidth * 0.025).clamp(14.0, 18.0);
      double fontSizeLarge = (maxWidth * 0.04).clamp(14.0, 18.0);
      double iconSmall = (maxWidth * 0.05).clamp(16.0, 24.0);
      double iconLarge = (maxWidth * 0.08).clamp(24.0, 36.0);
      double verticalSpacing = (maxWidth * 0.02).clamp(6.0, 12.0);
      double dividerHeight = (maxWidth * 0.12).clamp(40.0, 60.0);

      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        transform: Matrix4.translationValues(0, -24, 0),
        child: Container(
          padding: EdgeInsets.symmetric(
            vertical: verticalSpacing,
            horizontal: 10,
          ),
          decoration: BoxDecoration(
            color: AppColors.white100,
            border: Border.all(color: AppColors.grey20),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Kolom 1: Jumlah Ternak
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Jumlah Ternak",
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: fontSizeSmall,
                            color: AppColors.blackText,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        Row(
                          children: [
                            Image.asset(
                              "assets/home_assets/icons/ic_cow.png",
                              height: iconSmall,
                              width: iconSmall,
                            ),
                            SizedBox(width: 10),
                            FutureBuilder<int>(
                              future: _getTernakUserCount(),
                              builder: (context, snapshot) {
                                // Tampilkan loading indicator saat masih loading
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        AppColors.green01,
                                      ),
                                    ),
                                  );
                                }

                                // Handle error
                                if (snapshot.hasError) {
                                  return Text(
                                    "-",
                                    style: AppTextStyle.extraBold.copyWith(
                                      fontSize: fontSizeLarge,
                                      color: AppColors.blackText,
                                    ),
                                  );
                                }

                                // Data tersedia
                                if (snapshot.hasData) {
                                  return Text(
                                    "${snapshot.data!.toString()} Ekor",
                                    style: AppTextStyle.extraBold.copyWith(
                                      fontSize: fontSizeMedium,
                                      color: AppColors.blackText,
                                    ),
                                  );
                                }

                                // Fallback jika tidak ada data
                                return Text(
                                  "0 Ekor",
                                  style: AppTextStyle.extraBold.copyWith(
                                    fontSize: fontSizeMedium,
                                    color: AppColors.blackText,
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Kolom 2: Pakan Harian
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Pakan Harian",
                          style: AppTextStyle.semiBold.copyWith(
                            fontSize: fontSizeSmall,
                            color: AppColors.blackText,
                          ),
                        ),
                        SizedBox(height: verticalSpacing),
                        Row(
                          children: [
                            Image.asset(
                              "assets/home_assets/icons/ic_snack.png",
                              height: iconSmall,
                              width: iconSmall,
                            ),
                            SizedBox(width: 10),
                            Text(
                              dailyFeedStatus,
                              style: AppTextStyle.extraBold.copyWith(
                                fontSize: fontSizeMedium,
                                color: dailyFeedStatus == 'Sudah'
                                    ? AppColors.green01
                                    : AppColors.primaryRed,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Divider vertikal
                    Container(
                      height: dividerHeight,
                      width: 1,
                      color: AppColors.grey20,
                    ),

                    // Kolom 3: Update Data Harian (tombol)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/list-data-ternak-tugas');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/home_assets/icons/ic_update.png",
                            height: iconLarge,
                            width: iconLarge,
                          ),
                          SizedBox(height: verticalSpacing / 2),
                          Text(
                            "Update Data\nHarian",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: fontSizeSmall,
                              color: AppColors.blackText,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Kolom 4: Tambah Data Ternak (tombol)
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/tambah-data-ternak');
                      },
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            "assets/home_assets/icons/ic_plus.png",
                            height: iconLarge,
                            width: iconLarge,
                          ),
                          SizedBox(height: verticalSpacing / 2),
                          Text(
                            "Tambah Data\nTernak",
                            textAlign: TextAlign.center,
                            style: AppTextStyle.semiBold.copyWith(
                              fontSize: fontSizeSmall,
                              color: AppColors.blackText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _buildFeaturedServices(BuildContext context) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 24),
    transform: Matrix4.translationValues(0, -10, 0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fitur Unggulan',
          style: AppTextStyle.semiBold.copyWith(fontSize: 16),
        ),
        SizedBox(height: 8),
        FeaturedServiceCardWidget(
          iconPath: "assets/home_assets/icons/ic_ai_agent.png",
          title: 'Asisten Virtual Peternak',
          description: 'Asisten AI Untuk Membantu Mengelola Ternakmu',
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF298FBB), Color(0xFF298FBB)],
          ),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/asisten-virtual',
              arguments: {'initialText': null, 'externalInput': true},
            );
          },
        ),
        SizedBox(height: 8),
        FeaturedServiceCardWidget(
          iconPath: "assets/home_assets/icons/ic_cow.png",
          title: 'Rekomendasi Ternak Potensial',
          description: 'Temukan Ternak Potensial Untuk Berkembangbiak',
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [Color(0xFF0EBCB1), Color(0xFF065627)],
          ),
          iconSize: 28,
          containerSize: 38,
          onTap: () {
            Navigator.pushNamed(context, '/rekomendasi-ternak-potensial');
          },
        ),
      ],
    ),
  );
}

class LocationPickerDialog extends StatefulWidget {
  final LatLng? initialLocation;
  final String? initialAddress;

  const LocationPickerDialog({
    Key? key,
    this.initialLocation,
    this.initialAddress,
  }) : super(key: key);

  @override
  _LocationPickerDialogState createState() => _LocationPickerDialogState();
}

class _LocationPickerDialogState extends State<LocationPickerDialog> {
  LatLng? _selectedLocation;
  String _currentAddress = 'Pilih lokasi di peta';
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _selectedLocation = widget.initialLocation;
    _currentAddress = widget.initialAddress ?? 'Pilih lokasi di peta';
    _searchController.text = widget.initialAddress ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedLocation != null) {
        _mapController.move(_selectedLocation!, 15.0);
      }
    });
  }

  // Fungsi untuk mencari lokasi berdasarkan query (menggunakan Nominatim OpenStreetMap)
  Future<List<LocationSuggestion>> _searchLocations(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await http.get(
        Uri.parse(
          'https://nominatim.openstreetmap.org/search?format=json&q=$query&addressdetails=1&limit=5',
        ),
        headers: {'User-Agent': 'TernakProApp/1.0'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => LocationSuggestion.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Error searching locations: $e');
      return [];
    }
  }

  // Fungsi untuk mendapatkan alamat dari koordinat
  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    setState(() => _isLoading = true);

    try {
      final List<Placemark> placemarks = await placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );

      if (placemarks.isNotEmpty) {
        final Placemark place = placemarks.first;
        return _formatAddress(place);
      }
      return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    } catch (e) {
      print('Error getting address: $e');
      return '${latLng.latitude.toStringAsFixed(6)}, ${latLng.longitude.toStringAsFixed(6)}';
    } finally {
      setState(() => _isLoading = false);
    }
  }

  String _formatAddress(Placemark place) {
    String address = '';

    if (place.street != null && place.street!.isNotEmpty) {
      address += place.street!;
    }
    if (place.subLocality != null && place.subLocality!.isNotEmpty) {
      address += address.isNotEmpty
          ? ', ${place.subLocality!}'
          : place.subLocality!;
    }
    if (place.locality != null && place.locality!.isNotEmpty) {
      address += address.isNotEmpty ? ', ${place.locality!}' : place.locality!;
    }
    if (place.administrativeArea != null &&
        place.administrativeArea!.isNotEmpty) {
      address += address.isNotEmpty
          ? ', ${place.administrativeArea!}'
          : place.administrativeArea!;
    }

    return address.isNotEmpty ? address : 'Lokasi terpilih';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pilih Lokasi'),
        actions: [
          IconButton(
            icon: Icon(Icons.my_location),
            onPressed: () {
              // Bisa ditambahkan fitur GPS di sini
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: EdgeInsets.all(16),
            child: TypeAheadField<LocationSuggestion>(
              controller:
                  _searchController, // Changed from textFieldConfiguration
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Cari alamat atau tempat...',
                    prefixIcon: Icon(Icons.search),
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                );
              },
              suggestionsCallback: (pattern) async {
                return await _searchLocations(pattern);
              },
              itemBuilder: (context, suggestion) {
                return ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(suggestion.displayName),
                );
              },
              onSelected: (suggestion) async {
                final latLng = LatLng(
                  double.parse(suggestion.lat),
                  double.parse(suggestion.lon),
                );
                setState(() {
                  _selectedLocation = latLng;
                  _currentAddress = suggestion.displayName;
                  _searchController.text = suggestion.displayName;
                });
                _mapController.move(latLng, 15.0);
              },
            ),
          ),

          // Peta
          Expanded(
            child: FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _selectedLocation ?? LatLng(-6.2088, 106.8456),
                initialZoom: 15.0,
                onTap: (tapPosition, latLng) async {
                  setState(() {
                    _selectedLocation = latLng;
                  });
                  final address = await _getAddressFromLatLng(latLng);
                  setState(() {
                    _currentAddress = address;
                    _searchController.text = address;
                  });
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.ternak_pro',
                ),
                if (_selectedLocation != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: _selectedLocation!,
                        width: 40,
                        height: 40,
                        child: Icon(
                          Icons.location_pin,
                          color: Colors.red,
                          size: 40,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),

          // Info Lokasi
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              children: [
                _isLoading
                    ? CircularProgressIndicator()
                    : Text(
                        _currentAddress,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                SizedBox(height: 8),
                if (_selectedLocation != null)
                  Text(
                    'Koordinat: ${_selectedLocation!.latitude.toStringAsFixed(6)}, ${_selectedLocation!.longitude.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
              ],
            ),
          ),

          // Tombol Aksi
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _selectedLocation != null
                        ? () {
                            Navigator.pop(context, {
                              'location': _selectedLocation,
                              'address': _currentAddress,
                            });
                          }
                        : null,
                    child: Text('Pilih Lokasi Ini'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text('Batal'),
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Model untuk suggestion hasil pencarian
class LocationSuggestion {
  final String displayName;
  final String lat;
  final String lon;

  LocationSuggestion({
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory LocationSuggestion.fromJson(Map<String, dynamic> json) {
    return LocationSuggestion(
      displayName: json['display_name'] ?? '',
      lat: json['lat'] ?? '0',
      lon: json['lon'] ?? '0',
    );
  }
}
