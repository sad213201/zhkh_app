import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class ScanMeterScreen extends StatefulWidget {
  const ScanMeterScreen({super.key});

  @override
  State<ScanMeterScreen> createState() => _ScanMeterScreenState();
}

class _ScanMeterScreenState extends State<ScanMeterScreen> {
  CameraController? _controller;
  final TextRecognizer _textRecognizer = TextRecognizer();
  String _recognized = '';
  bool _isBusy = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    if (cameras.isEmpty) return;
    _controller = CameraController(cameras.first, ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) setState(() {});
  }

  Future<void> _scan() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy)
      return;
    setState(() => _isBusy = true);
    try {
      final file = await _controller!.takePicture();
      final input = InputImage.fromFilePath(file.path);
      final result = await _textRecognizer.processImage(input);
      final digits = RegExp(r'\d+[.,]?\d*')
          .allMatches(result.text)
          .map((m) => m.group(0)!)
          .join(' ');
      setState(
        () => _recognized = digits.isEmpty ? 'Цифры не найдены' : digits,
      );
    } catch (e) {
      setState(() => _recognized = 'Ошибка: $e');
    } finally {
      setState(() => _isBusy = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Сканирование счётчика')),
      body: Column(
        children: [
          Expanded(child: CameraPreview(_controller!)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(_recognized, style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: _isBusy ? null : _scan,
                  icon: const Icon(Icons.camera_alt),
                  label: Text(
                    _isBusy ? 'Распознавание...' : 'Сфотографировать',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
