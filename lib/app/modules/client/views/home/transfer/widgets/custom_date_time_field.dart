import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDateTimeField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData prefixIcon;

  const CustomDateTimeField({
    super.key,
    required this.controller,
    required this.hintText,
    required this.prefixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(
          prefixIcon,
          color: const Color(0xFF4C6FFF),
        ),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
      onTap: () async {
        // Sélection de la date
        final DateTime? pickedDate = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2025),
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: const ColorScheme.light(
                  primary: Color(0xFF4C6FFF),
                ),
              ),
              child: child!,
            );
          },
        );

        if (pickedDate != null) {
          // Sélection de l'heure après la date
          final TimeOfDay? pickedTime = await showTimePicker(
            context: context,
            initialTime: TimeOfDay.now(),
            builder: (context, child) {
              return Theme(
                data: Theme.of(context).copyWith(
                  colorScheme: const ColorScheme.light(
                    primary: Color(0xFF4C6FFF),
                  ),
                ),
                child: child!,
              );
            },
          );

          if (pickedTime != null) {
            // Combiner la date et l'heure
            final DateTime combinedDateTime = DateTime(
              pickedDate.year,
              pickedDate.month,
              pickedDate.day,
              pickedTime.hour,
              pickedTime.minute,
            );

            // Formater la date et l'heure
            controller.text = DateFormat('dd/MM/yyyy HH:mm').format(combinedDateTime);
          }
        }
      },
      validator: (value) => value!.isEmpty ? 'Date et heure requises' : null,
    );
  }
}