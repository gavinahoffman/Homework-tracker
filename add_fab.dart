import 'package:flutter/material.dart';

class AddFAB extends StatelessWidget {
  final VoidCallback onPressed;
  final String tooltip;

  const AddFAB({
    super.key,
    required this.onPressed,
    this.tooltip = 'Add',
  });

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: onPressed,
      tooltip: tooltip,
      child: const Icon(Icons.add),
    );
  }
}
