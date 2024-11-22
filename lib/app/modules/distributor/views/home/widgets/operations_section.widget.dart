import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class OperationsSection extends StatelessWidget {
  final List<OperationButtonData> operations;

  const OperationsSection({
    Key? key,
    required this.operations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Opérations',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: operations.map((op) => 
            Expanded(
              child: _buildOperationButton(
                icon: op.icon,
                title: op.title,
                color: op.color,
                onTap: op.onTap,
              ),
            )
          ).toList(),
        ),
      ],
    );
  }

  Widget _buildOperationButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OperationButtonData {
  final IconData icon;
  final String title;
  final Color color;
  final VoidCallback onTap;

  const OperationButtonData({
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });
}