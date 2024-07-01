import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:riffle/hover_builder.dart';
import 'package:window_manager/window_manager.dart';

class DesktopWindowButtons extends StatefulWidget {
  const DesktopWindowButtons({super.key});

  @override
  State<DesktopWindowButtons> createState() => _DesktopWindowButtonsState();
}

class _DesktopWindowButtonsState extends State<DesktopWindowButtons>
    with WindowListener {
  Color? iconsColor;

  @override
  void initState() {
    super.initState();
    windowManager.addListener(this);
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        DesktopWindowsButton(
          onTap: windowManager.minimize,
          hoverColor: Get.theme.colorScheme.inversePrimary,
          icon: Icon(
            Icons.minimize,
            color: iconsColor,
            size: kToolbarHeight * 0.3,
          ),
        ),
        FutureBuilder(
          future: windowManager.isMaximized(),
          builder: (context, snapshot) {
            if (snapshot.data == true) {
              return DesktopWindowsButton(
                onTap: windowManager.unmaximize,
                hoverColor: Get.theme.colorScheme.inversePrimary,
                icon: FaIcon(
                  FontAwesomeIcons.windowRestore,
                  color: iconsColor,
                  size: kToolbarHeight * 0.2,
                ),
              );
            }
            return DesktopWindowsButton(
              onTap: windowManager.maximize,
              hoverColor: Get.theme.colorScheme.inversePrimary,
              icon: FaIcon(
                FontAwesomeIcons.windowMaximize,
                color: iconsColor,
                size: kToolbarHeight * 0.2,
              ),
            );
          },
        ),
        DesktopWindowsButton(
          onTap: windowManager.close,
          hoverColor: const Color(0xFFe81123),
          icon: Icon(
            Icons.close,
            color: iconsColor,
            size: kToolbarHeight * 0.3,
          ),
        ),
      ],
    );
  }

  @override
  void onWindowMaximize() {
    setState(() {});
  }

  @override
  void onWindowUnmaximize() {
    setState(() {});
  }

  @override
  void onWindowRestore() {
    setState(() {});
  }

  @override
  void onWindowBlur() {
    setState(() {
      // iconsColor = Get.theme.colorScheme.inversePrimary;
    });
    super.onWindowBlur();
  }

  @override
  void onWindowFocus() {
    setState(() {
      iconsColor = null;
    });
    super.onWindowFocus();
  }
}

class DesktopWindowsButton extends StatelessWidget {
  const DesktopWindowsButton({
    super.key,
    required this.onTap,
    required this.hoverColor,
    required this.icon,
  });

  final void Function()? onTap;
  final Color hoverColor;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: 1,
        child: HoverBuilder(
          builder: (context, isHovered) {
            return Container(
              color: isHovered ? hoverColor : null,
              child: Center(
                child: icon,
              ),
            );
          },
        ),
      ),
    );
  }
}
