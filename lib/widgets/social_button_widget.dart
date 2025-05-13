import 'package:flutter/material.dart';
import 'text_widget.dart';

class SocialButtonWidget extends StatelessWidget {
  final Color bgColor;
  final String imagePath;
  final String buttonName;
  final VoidCallback onPress;

  const SocialButtonWidget({
    super.key,
    required this.bgColor,
    required this.imagePath,
    required this.buttonName,
    required this.onPress,
  });
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPress,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(bgColor),
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(horizontal: 17, vertical: 5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(imagePath, width: 20),
          const SizedBox(width: 8),
          TextWidget(
            title: buttonName, // @todo pass as parameter
            txtSize: 18.0,
            txtColor: Colors.black,
          ),
        ],
      ),
    );
  }
}
