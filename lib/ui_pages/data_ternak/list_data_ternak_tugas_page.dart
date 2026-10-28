import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ternak_pro/cubit/tab_ternak_cubit.dart';
import 'package:ternak_pro/models/TernakItem.dart';
import 'package:ternak_pro/shared/theme.dart';

import '../../models/DailyTaskItem.dart';
import '../../services/api_service.dart';
import '../../shared/custom_loading.dart';
import '../../shared/widgets/data_ternak/custom_app_bar.dart';
import '../../shared/widgets/data_ternak/custom_tab_bar.dart';
import '../../shared/widgets/data_ternak/data_ternak_list.dart';
import '../../shared/widgets/data_ternak/data_tugas_list.dart';
import '../../shared/widgets/onboarding_buttom.dart';

class ListDataTernakTugasPage extends StatefulWidget {
  const ListDataTernakTugasPage({super.key});

  @override
  ListDataTernakTugasPageState createState() => ListDataTernakTugasPageState();
}

class ListDataTernakTugasPageState extends State<ListDataTernakTugasPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ApiService _apiService = ApiService();

  late Future<List<Map<String, dynamic>>> _ternakListFuture;
  late Future<List<Map<String, dynamic>>> _tugasListFuture;

  Future<List<Map<String, dynamic>>> fetchTernakList() async {
    final credential = await _apiService.loadCredentials();
    final userId = credential['user_id'];

    try {
      // Mapping data ternak yang sudah diambil ke dalam DailyTaskItem
      List<Ternakitem> ternakListData = await _apiService.getTernakUserAll(
        userId,
      );

      List<Map<String, dynamic>> ternakListDataFinal = ternakListData
          .map((ternak) => ternak.toJson())
          .toList();

      // Menunggu 3 detik sebelum mematikan _isLoadingTasks
      await Future.delayed(const Duration(seconds: 3));

      return ternakListDataFinal;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> fetchTugasList() async {
    final credential = await _apiService.loadCredentials();
    final userId = credential['user_id'];

    try {
      // Mapping data tugas yang sudah diambil ke dalam DailyTaskItem
      List<DailyTaskItem> tugasListData = await _apiService.getTugasUserAll(
        userId,
      );

      List<Map<String, dynamic>> tugasListDataFinal = tugasListData
          .map((task) => task.toJson())
          .toList();

      // Menunggu 3 detik sebelum mematikan _isLoadingTasks
      await Future.delayed(const Duration(seconds: 3));

      return tugasListDataFinal;
    } catch (e) {
      rethrow;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _ternakListFuture = fetchTernakList();
    _tugasListFuture = fetchTugasList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Ambil argumen; fallback ke 0 kalau null / tipe tidak sesuai
    final args = ModalRoute.of(context)?.settings.arguments;
    final int initialIndex = switch (args) {
      final Map m when m['initialIndex'] is int => m['initialIndex'] as int,
      _ => 0,
    };

    return BlocProvider(
      create: (_) => TabTernakCubit(initialIndex),
      child: BlocConsumer<TabTernakCubit, int>(
        listener: (context, selectedIndex) {
          if (_tabController.index != selectedIndex) {
            _tabController.animateTo(selectedIndex);
          }
        },
        builder: (context, selectedIndex) {
          return Scaffold(
            backgroundColor: AppColors.bgLight,
            appBar: CustomAppBar(),
            body: Column(
              children: [
                CustomTabBar(
                  controller: _tabController,
                  onSwipe: (index) {
                    context.read<TabTernakCubit>().setTab(index);
                  },
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    physics: NeverScrollableScrollPhysics(),
                    children: [
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _ternakListFuture, // gunakan future dari state
                        builder: (context, snapshot) {
                          // Loading state
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: TernakProBoxLoading());
                          }

                          // Error handling
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                children: [
                                  Text('Error: ${snapshot.error}'),
                                  Text('Error details: ${snapshot.error}'),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _ternakListFuture = fetchTernakList();
                                      });
                                    },
                                    child: Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          // No data handling
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('Tidak ada tugas saat ini.'),
                            );
                          }

                          // Once data is ready, pass it to the TugasList widget
                          return DataTernakList(
                            snapshot.data!,
                            onRefresh: () {
                              setState(() {
                                _ternakListFuture = fetchTernakList();
                              });
                            },
                          );
                        },
                      ),
                      FutureBuilder<List<Map<String, dynamic>>>(
                        future: _tugasListFuture, // gunakan future dari state
                        builder: (context, snapshot) {
                          // Loading state
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: TernakProBoxLoading());
                          }

                          // Error handling
                          if (snapshot.hasError) {
                            return Center(
                              child: Column(
                                children: [
                                  Text('Error: ${snapshot.error}'),
                                  Text('Error details: ${snapshot.error}'),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        _tugasListFuture = fetchTugasList();
                                      });
                                    },
                                    child: Text('Coba lagi'),
                                  ),
                                ],
                              ),
                            );
                          }

                          // No data handling
                          if (!snapshot.hasData || snapshot.data!.isEmpty) {
                            return Center(
                              child: Text('Tidak ada tugas saat ini.'),
                            );
                          }

                          // Once data is ready, pass it to the TugasList widget
                          return TugasList(
                            snapshot.data!,
                            onRefresh: () {
                              setState(() {
                                _tugasListFuture = fetchTugasList();
                              });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
            bottomNavigationBar: BottomActionButton(
              activePage: selectedIndex == 0 ? 'ternak' : 'tugas',
            ),
          );
        },
      ),
    );
  }
}

class TugasList extends StatefulWidget {
  final List<Map<String, dynamic>> tugasList;
  final VoidCallback onRefresh;

  const TugasList(this.tugasList, {super.key, required this.onRefresh});

  @override
  State<TugasList> createState() => _TugasListState();
}

class _TugasListState extends State<TugasList> {
  late List<Map<String, dynamic>> _tugasList;

  @override
  void initState() {
    super.initState();
    _tugasList = List<Map<String, dynamic>>.from(widget.tugasList);
  }

  @override
  void didUpdateWidget(covariant TugasList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.tugasList, widget.tugasList)) {
      _tugasList = List<Map<String, dynamic>>.from(widget.tugasList);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: _tugasList.length,
      itemBuilder: (context, index) {
        final task = _tugasList[index];
        final idTugas = int.tryParse(task['id_tugas'].toString()) ?? 0;
        return Dismissible(
          key: ValueKey('tugas_$idTugas'),
          direction: DismissDirection.endToStart,
          background: Container(
            margin: const EdgeInsets.only(top: 8, left: 16, right: 16),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(10),
            ),
            alignment: Alignment.centerRight,
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          confirmDismiss: (_) => _confirmDeleteTugas(context, idTugas),
          onDismissed: (_) {
            setState(() => _tugasList.removeAt(index));
            widget.onRefresh();
          },
          child: CustomTugasItem(
            idTugas: idTugas,
            title: task['nama_tugas']?.toString() ?? '',
            statusId: int.tryParse(task['status_tugas_id'].toString()) ?? 0,
            status: task['status_tugas']?.toString() ?? 'Belum',
            time: task['waktu_tugas']?.toString() ?? '',
            tglTugas: task['tgl_tugas']?.toString() ?? '',
            catatan: task['catatan']?.toString() ?? '',
            iconPath:
                task['icon_path']?.toString() ??
                'assets/home_assets/icons/ic_default.png',
            onDelete: () async {
              final deleted = await _confirmDeleteTugas(context, idTugas);
              if (deleted) {
                setState(() {
                  final currentIndex = _tugasList.indexWhere(
                    (item) => item['id_tugas'] == idTugas,
                  );
                  if (currentIndex >= 0) _tugasList.removeAt(currentIndex);
                });
                widget.onRefresh();
              }
              return deleted;
            },
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteTugas(BuildContext context, int idTugas) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus tugas'),
        content: const Text('Anda yakin ingin menghapus tugas ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (result != true) return false;

    try {
      final credentials = await ApiService().loadCredentials();
      final userId = credentials['user_id'];
      if (userId is! String || userId.isEmpty) {
        throw Exception('Sesi pengguna tidak ditemukan');
      }

      await ApiService().deleteTugas(userId, idTugas);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Tugas dihapus')));
      }
      return true;
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menghapus tugas: $e')));
      }
      return false;
    }
  }
}

class BottomActionButton extends StatelessWidget {
  final String activePage;

  const BottomActionButton({super.key, required this.activePage});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: ClipRect(
        child: Opacity(
          opacity:
              1.0, // You can adjust this value for transparency, 1.0 = no transparency
          child: OnboardingButton(
            previous: false,
            text: "Tambahkan",
            width: double.infinity,
            height: 30,
            onClick: () =>
                Navigator.pushNamed(context, "/tambah-data-$activePage"),
          ),
        ),
      ),
    );
  }
}
