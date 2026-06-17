import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.message,
    required this.onAdd,
  });

  final String message;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/logo/SoloKey.png',
            height: 72,
            width: 72,
            color: const Color(0xFF2A2A4A),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Añade tu primera credencial',
            style: TextStyle(color: Color(0xFF9E9EBF), fontSize: 14),
          ),
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Añadir credencial'),
          ),
        ],
      ),
    );
  }
}
