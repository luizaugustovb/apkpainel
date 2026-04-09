import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:audioplayers/audioplayers.dart';

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
  final AudioPlayer audioPlayer = AudioPlayer();
  
  final String panelUrl = 'http://10.1.8.13/painellab/public/painel?token=0d3b32bcfabbb9bebd005a9c91a48898'; 

  @override
  void initState() {
    super.initState();
    _setupWebViewController();

    // TESTE: Fala "Sistema Iniciado" 5 segundos após abrir o app
    // Se você ouvir isso, a solução está funcionando!
    Future.delayed(const Duration(seconds: 5), () {
      _speakViaGoogle("Sistema iniciado");
    });
  }

  void _setupWebViewController() {
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..addJavaScriptChannel(
        'AndroidTerminal',
        onMessageReceived: (JavaScriptMessage message) {
          // Recebe o texto da senha do PHP e fala via Google
          _speakViaGoogle(message.message);
        },
      )
      ..loadRequest(Uri.parse(panelUrl));
  }

  Future<void> _speakViaGoogle(String text) async {
    if (text.isEmpty) return;
    
    // Monta a URL do Google Tradutor para gerar o áudio
    final url = 'https://translate.google.com/translate_tts'
        '?ie=UTF-8'
        '&q=${Uri.encodeComponent(text)}'
        '&tl=pt-BR'
        '&client=tw-ob';
    
    try {
      // Toca o áudio direto da URL, como se fosse uma música
      await audioPlayer.stop();
      await audioPlayer.play(UrlSource(url));
    } catch (e) {
      debugPrint("Erro ao reproduzir áudio do Google: $e");
    }
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: WebViewWidget(controller: controller),
    );
  }
}
