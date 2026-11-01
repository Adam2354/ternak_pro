import 'package:flutter/material.dart';
import '../../theme.dart';

class CustomDropdownSehat extends StatefulWidget {
  final String status; // Tambahkan parameter status untuk menerima nilai default
  final ValueChanged<String>? onChanged; // Callback untuk perubahan nilai

  const CustomDropdownSehat({
    super.key,
    required this.status,
    this.onChanged, // Opsional, bisa null
  });

  @override
  CustomDropdownSehatState createState() => CustomDropdownSehatState();
}

class CustomDropdownSehatState extends State<CustomDropdownSehat> {
  late String _selectedValue;

  @override
  void initState() {
    super.initState();
    // Set nilai default berdasarkan status yang diterima
    _selectedValue = widget.status;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Kondisi',
          style: AppTextStyle.semiBold.copyWith(
            fontSize: 14,
            color: AppColors.black100,
          ),
        ),
        SizedBox(height: 3),
        GestureDetector(
          onTap: () {
            _showCustomDialog(context);
          },
          child: Container(
            padding: EdgeInsets.all(13),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.white06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    // Icon
                    Image.asset(
                      _iconForCondition(_selectedValue),
                      width: 16,
                      height: 16,
                    ),
                    SizedBox(width: 10),
                    // Text
                    Text(
                      _selectedValue,
                      style: AppTextStyle.medium.copyWith(
                        fontSize: 16,
                        color: AppColors.blackText,
                      ),
                    ),
                  ],
                ),
                // Dropdown icon
                Image.asset(
                  'assets/home_assets/icons/ic_dropdown.png',
                  width: 16,
                  height: 16,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Function to show the custom dropdown dialog
  void _showCustomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          contentPadding: EdgeInsets.zero,
          content: SizedBox(
            height: 270,
            child: Column(
              children: <Widget>[
                _buildDialogOption('Sehat'),
                _buildDialogOption('Sakit'),
                _buildDialogOption('Hamil'),
                _buildDialogOption('Meninggal'),
                _buildDialogOption('Siap Jual'),
              ],
            ),
          ),
        );
      },
    );
  }

  // Dialog option item
  Widget _buildDialogOption(String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedValue = value; // Update the selected value
        });
        widget.onChanged?.call(value); // Panggil callback onChanged
        Navigator.pop(context); // Close the dialog
      },
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        child: Row(
          children: [
            Image.asset(_iconForCondition(value), width: 16, height: 16),
            SizedBox(width: 10),
            Text(
              value,
              style: AppTextStyle.medium.copyWith(
                fontSize: 16,
                color: AppColors.blackText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _iconForCondition(String value) {
    return value == 'Sehat'
        ? 'assets/home_assets/icons/ic_check_green.png'
        : 'assets/home_assets/icons/ic_check_yellow.png';
  }
}
