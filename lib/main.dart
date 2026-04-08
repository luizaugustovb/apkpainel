import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:io';

void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: PanelApp(),
  ));
}

class PanelApp extends StatefulWidget {
  const PanelApp({super.key});

  @override
  State<PanelApp> createState() => _PanelAppState();
}

class _PanelAppState extends State<PanelApp> {
  late final WebViewController controller;
  final FlutterTts flutterTts = FlutterTts();
  
  // URL do seu sistema - Altere conforme necessário
  final String panelUrl = 'http://localhost/painellab/panel'; 

  @override
  void initState() {
    super.initState();
    _setupTts();
    _setupWebViewController();
  }

  void _setupTts() async {
    await flutterTts.setLanguage("pt-BR");
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setPitch(1.0);
    // Força o uso do motor do Google se disponível
    if (Platform.isAndroid) {
      await flutterTts.setEngine("com.google.android.tts");
    }
  }

  void _setupWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {},
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      // Esta é a "Ponte" que conecta o seu PHP ao Android
      ..addJavaScriptChannel(
        'AndroidTerminal',
        onMessageReceived: (JavaScriptMessage message) {
          _speak(message.message);
        },
      )
      ..loadRequest(Uri.parse(panelUrl));
  }

  Future<void> _speak(String text) async {
    if (text.isNotEmpty) {
      await flutterTts.stop();
      await flutterTts.speak(text);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: WebViewWidget(controller: controller),
      ),
    );
  }
}
