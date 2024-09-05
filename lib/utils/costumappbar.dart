import 'package:flutter/material.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:lottie/lottie.dart';

class CustomCurvedAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final String? backButtonTitle;
  final String? menuTitle;
  final double height;
  final bool showBackButton;
  final bool showAvatar;
  final String? backgroundImage;
  final double imageOpacity;
  final bool menubar;
  final PreferredSizeWidget? bottom;

  CustomCurvedAppBar({
    required this.title,
    this.backButtonTitle,
    this.menuTitle,
    required this.height,
    this.showBackButton = true,
    this.showAvatar = false,
    this.backgroundImage,
    this.imageOpacity = 0.5,
    this.menubar = false,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return ClipPath(
      clipper: WaveClipperOne(),
      child: Container(
        height: height + (bottom?.preferredSize.height ?? 0),
        decoration: BoxDecoration(
          color: Colors.black,
        ),
        child: Stack(
          children: [
            if (backgroundImage != null)
              Opacity(
                opacity: imageOpacity,
                child: Image.asset(
                  backgroundImage!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            Column(
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (showBackButton)
                      Padding(
                        padding: const EdgeInsets.only(left: 30, top: 50),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.arrow_back, color: Colors.white, size: 27),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),SizedBox(width: 50),
                              if (backButtonTitle != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 5),
                                  child: Text(
                                    backButtonTitle!,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 26,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    if (menubar)
                      Padding(
                        padding: const EdgeInsets.only(left: 0, top: 20),
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: Row(
                            children: [
                              Container(
                                width: 120,
                                height: 100,
                                child: IconButton(
                                  icon: Lottie.asset(
                                    'assets/Animation - 1725354194421.json',
                                    height: 150,
                                    fit: BoxFit.cover,
                                  ),
                                  onPressed: () {
                                    Scaffold.of(context).openDrawer();
                                  },
                                ),
                              ),SizedBox(width: 40),
                              if (menuTitle != null)
                                Text(
                                  menuTitle!,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    SizedBox(width: 50),
                    if (backButtonTitle == null && menuTitle == null)
                      Padding(
                        padding: const EdgeInsets.only(top: 25),
                        child: Align(
                          alignment: Alignment.topCenter,
                          child: Text(
                            title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                if (bottom != null) bottom!,
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(height + (bottom?.preferredSize.height ?? 0));
}
