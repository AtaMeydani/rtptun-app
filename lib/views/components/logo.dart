import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.vpn_lock_rounded,
          size: 40,
          color: themeData.colorScheme.onPrimary,
        ),
        const SizedBox(
          width: 4,
        ),
        Text(
          'RTP',
          style: themeData.textTheme.headlineMedium!.copyWith(
            color: themeData.colorScheme.onPrimary,
          ),
        ),
        Text(
          ' Tunnel',
          style: themeData.textTheme.titleLarge!.copyWith(
            color: themeData.colorScheme.onPrimary,
          ),
        ),
      ],
    );
  }
}
