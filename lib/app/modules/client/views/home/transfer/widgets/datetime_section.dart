// widgets/datetime_section.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:money_transfer_app/app/modules/client/views/home/transfer/widgets/custom_date_time_field.dart';

class DateTimeSection extends StatelessWidget {
  final TextEditingController dateTimeController;

  const DateTimeSection({
    super.key,
    required this.dateTimeController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date et heure du transfert',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        CustomDateTimeField(
          controller: dateTimeController,
          hintText: 'Date et heure du transfert',
          prefixIcon: Icons.calendar_today,
        ),
      ],
    );
  }
}
