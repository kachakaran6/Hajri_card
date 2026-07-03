import 'package:flutter/material.dart';

class Numpad extends StatelessWidget {
  final Function(String) onKeyTap;
  final VoidCallback onBackspace;
  final VoidCallback onClear;
  final VoidCallback onSubmit;
  final String submitLabel;
  final Color? submitColor;

  const Numpad({
    super.key,
    required this.onKeyTap,
    required this.onBackspace,
    required this.onClear,
    required this.onSubmit,
    this.submitLabel = 'OK',
    this.submitColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var row in [
          ['1', '2', '3'],
          ['4', '5', '6'],
          ['7', '8', '9'],
        ])
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: row
                .map((key) => _buildKey(context, key, () => onKeyTap(key)))
                .toList(),
          ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildKey(context, 'C', onClear, color: Colors.grey),
            _buildKey(context, '0', () => onKeyTap('0')),
            _buildKey(
              context,
              '⌫',
              onBackspace,
              icon: Icons.backspace_outlined,
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 60,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: submitColor ?? Theme.of(context).primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            onPressed: onSubmit,
            child: Text(
              submitLabel,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildKey(
    BuildContext context,
    String label,
    VoidCallback onTap, {
    IconData? icon,
    Color? color,
  }) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: 72,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            alignment: Alignment.center,
            child: icon != null
                ? Icon(
                    icon,
                    size: 28,
                    color:
                        color ?? Theme.of(context).textTheme.bodyLarge?.color,
                  )
                : Text(
                    label,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color:
                          color ?? Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
