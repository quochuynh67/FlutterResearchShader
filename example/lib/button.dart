import 'package:flutter/material.dart';

class ShadyButton extends StatelessWidget {
  final String text;
  final IconData? icon;
  final VoidCallback onTap;

  const ShadyButton({
    super.key,
    required this.text,
    required this.onTap,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: FilledButton.icon(
      label: Text(
        text,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w200,
        ),
      ),
      onPressed: onTap,
      style: const ButtonStyle(
        side: MaterialStatePropertyAll(BorderSide(color: Colors.white54)),
        padding: MaterialStatePropertyAll(EdgeInsets.all(10)),
        backgroundColor: MaterialStatePropertyAll(Colors.black45),
        foregroundColor: MaterialStatePropertyAll(Colors.black45),
      ),
      icon: Icon(
        icon ?? Icons.arrow_right_alt_sharp,
        color: Colors.white,
        size: 14,
      ),
      ),
    );
  }
}
