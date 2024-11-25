// widgets/frequency_selector.dart
import 'package:flutter/material.dart';
import 'package:money_transfer_app/app/data/models/transaction_model.dart';

class FrequencySelector extends StatefulWidget {
  final void Function(TransferFrequency) onFrequencyChanged;
  final TransferFrequency initialFrequency;

  const FrequencySelector({
    super.key,
    required this.onFrequencyChanged,
    this.initialFrequency = TransferFrequency.monthly,
  });

  @override
  State<FrequencySelector> createState() => _FrequencySelectorState();
}

class _FrequencySelectorState extends State<FrequencySelector> {
  late TransferFrequency selectedFrequency;

  @override
  void initState() {
    super.initState();
    selectedFrequency = widget.initialFrequency;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fréquence du transfert',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2D3142),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              _buildFrequencyTile(
                TransferFrequency.daily,
                'Quotidien',
                'Transfert effectué chaque jour',
                Icons.calendar_today,
              ),
              const Divider(height: 1),
              _buildFrequencyTile(
                TransferFrequency.weekly,
                'Hebdomadaire',
                'Transfert effectué chaque semaine',
                Icons.view_week,
              ),
              const Divider(height: 1),
              _buildFrequencyTile(
                TransferFrequency.monthly,
                'Mensuel',
                'Transfert effectué chaque mois',
                Icons.calendar_month,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFrequencyTile(
    TransferFrequency frequency,
    String title,
    String subtitle,
    IconData icon,
  ) {
    return RadioListTile<TransferFrequency>(
      value: frequency,
      groupValue: selectedFrequency,
      onChanged: (TransferFrequency? value) {
        if (value != null) {
          setState(() {
            selectedFrequency = value;
          });
          widget.onFrequencyChanged(value);
        }
      },
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFF2D3142),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      secondary: Icon(
        icon,
        color: const Color(0xFF4C6FFF),
      ),
      activeColor: const Color(0xFF4C6FFF),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
    );
  }
}