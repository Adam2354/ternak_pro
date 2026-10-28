import 'package:flutter/material.dart';
import 'package:ternak_pro/services/api_service.dart';
import '../../theme.dart';
import '../custom_image_view.dart';
import 'harga_filter.dart';

class CustomHargaPasarItem extends StatelessWidget {
  final String lokasi;
  final String imageUrl;
  final String name;
  final int harga;
  final String kondisi;

  const CustomHargaPasarItem({
    super.key,
    required this.lokasi,
    required this.imageUrl,
    required this.name,
    required this.harga,
    required this.kondisi,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    String statusIcon;
    switch (kondisi.toLowerCase()) {
      case 'naik':
        statusColor = AppColors.red600;
        statusIcon = 'assets/harga_pasar_assets/icons/ic_arrow_up.png';
        break;
      case 'stabil':
        statusColor = AppColors.blue01;
        statusIcon = 'assets/harga_pasar_assets/icons/ic_strip.png';
        break;
      case 'turun':
        statusColor = AppColors.green03;
        statusIcon = 'assets/harga_pasar_assets/icons/ic_arrow_down.png';
        break;
      default:
        statusColor = AppColors.blue01;
        statusIcon = 'assets/harga_pasar_assets/icons/ic_strip.png';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = constraints.maxWidth;

        return Card(
          color: AppColors.bgLight,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: AppColors.grey20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(right: 14, top: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Image.asset(
                      'assets/harga_pasar_assets/icons/ic_location.png',
                      width: 16.0,
                      height: 16.0,
                    ),
                    SizedBox(width: 4.0),
                    Text(lokasi),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageView(
                      imagePath: imageUrl,
                      width: cardWidth * 0.62,
                      height: cardWidth * 0.48,
                      fit: BoxFit.contain,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.0,
                      vertical: 4.0,
                    ),
                    child: Text(
                      name,
                      style: AppTextStyle.regular,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      'RP. ${harga.toStringAsFixed(0)}/kg',
                      textAlign: TextAlign.left,
                      style: AppTextStyle.semiBold.copyWith(fontSize: 16),
                    ),
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: statusColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.0),
                    bottomRight: Radius.circular(16.0),
                  ),
                ),
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(statusIcon, width: 12.0, height: 12.0),
                    SizedBox(width: 4.0),
                    Text(
                      'Harga $kondisi',
                      style: TextStyle(color: Colors.white),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class HargaPasarList extends StatefulWidget {
  final String searchQuery;
  final HargaFilter filter;

  const HargaPasarList({
    super.key,
    this.searchQuery = '',
    this.filter = HargaFilter.semua,
  });

  @override
  State<HargaPasarList> createState() => _HargaPasarListState();
}

class _HargaPasarListState extends State<HargaPasarList> {
  late Future<List<Map<String, dynamic>>> hargaPasarFuture;
  List<Map<String, dynamic>> items = []; // Declare items here

  @override
  void initState() {
    super.initState();
    hargaPasarFuture = _fetchHargaPasarData();
  }

  // Fetch data from the API
  Future<List<Map<String, dynamic>>> _fetchHargaPasarData() async {
    List<Map<String, dynamic>> fetchedItems = await ApiService()
        .getAllHargaPasar();
    setState(() {
      items = fetchedItems; // Update items list with the fetched data
    });
    return fetchedItems;
  }

  bool _matchFilter(String kondisi) {
    switch (widget.filter) {
      case HargaFilter.semua:
        return true;
      case HargaFilter.naik:
        return kondisi.toLowerCase() == 'naik';
      case HargaFilter.turun:
        return kondisi.toLowerCase() == 'turun';
      case HargaFilter.stabil:
        return kondisi.toLowerCase() == 'stabil';
    }
  }

  @override
  Widget build(BuildContext context) {
    final q = widget.searchQuery.trim().toLowerCase();

    final filtered = items.where((it) {
      final name = (it['nama'] as String).toLowerCase();
      final kondisi = (it['kondisi'] as String);
      final okQuery = q.isEmpty || name.contains(q);
      final okFilter = _matchFilter(kondisi);
      return okQuery && okFilter;
    }).toList();

    return FutureBuilder<List<Map<String, dynamic>>>(
      future: hargaPasarFuture, // Use the future for fetching data
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          ); // Show loading spinner
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error fetching data'));
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('No data available'));
        }

        // Filter and display the items in the grid
        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 50), // bottom 50
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 8.0,
            mainAxisSpacing: 8.0,
            childAspectRatio: 0.75,
          ),
          itemCount: filtered.length,
          itemBuilder: (context, index) {
            final item = filtered[index];
            return CustomHargaPasarItem(
              lokasi: item['lokasi'],
              imageUrl: item['image_url'],
              name: item['nama'],
              harga: item['harga_kg'],
              kondisi: item['kondisi'],
            );
          },
        );
      },
    );
  }
}
