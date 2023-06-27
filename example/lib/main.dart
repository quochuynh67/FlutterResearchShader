import 'package:flutter/material.dart';
import 'package:shady_example/button.dart';
import 'package:shady_example/gallery/shady_gallery.dart';
import 'package:shady_example/interactive/interactive_gallery.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int? screen;

  @override
  Widget build(BuildContext context) {
    Widget child = ColoredBox(
      color: Colors.black,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShadyButton(text: 'SHADERTOY', onTap: () => setState(() => screen = 0)),
          ShadyButton(text: 'INTERACTIVE', onTap: () => setState(() => screen = 1)),
        ],
      ),
    );

    if (screen == 0) {
      child = ShadyGallery(onBack: () => setState(() => screen = null));
    } else if (screen == 1) {
      child = ShadyInteractives(onBack: () => setState(() => screen = null));
    }

    return MaterialApp(
      title: 'Shady example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Material(
        child: child,
      ),
    );
  }
}
