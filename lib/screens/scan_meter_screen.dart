import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../services/database_service.dart';

class ScanMeterScreen extends StatefulWidget {
  final String meterId;

  const ScanMeterScreen({super.key, required this.meterId});

  @override
  State<ScanMeterScreen> createState() => _ScanMeterScreenState();
}

class _ScanMeterScreenState extends State<ScanMeterScreen> {
  CameraController? _controller;

  final TextRecognizer _textRecognizer = TextRecognizer();

  final DatabaseService _databaseService = DatabaseService();

  String _recognized = '';

  bool _isBusy = false;

  bool _saved = false;

  @override
  void initState() {
    super.initState();

    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();

      if (cameras.isEmpty) {
        if (mounted) {
          setState(() {
            _recognized = 'Камера не найдена';
          });
        }

        return;
      }

      _controller = CameraController(cameras.first, ResolutionPreset.medium);

      await _controller!.initialize();

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _recognized = 'Ошибка камеры: $e';
        });
      }
    }
  }

  Future<void> _scan() async {
    if (_controller == null || !_controller!.value.isInitialized || _isBusy) {
      return;
    }

    setState(() {
      _isBusy = true;
      _saved = false;
    });

    try {
      final file = await _controller!.takePicture();

      final inputImage = InputImage.fromFilePath(file.path);

      final result = await _textRecognizer.processImage(inputImage);

      final matches = RegExp(r'\d+[.,]?\d*')
          .allMatches(result.text)
          .map((match) => match.group(0)!)
          .toList();

      setState(() {
        _recognized = matches.isEmpty ? 'Цифры не найдены' : matches.join(' ');
      });
    } catch (e) {
      setState(() {
        _recognized = 'Ошибка: $e';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isBusy = false;
        });
      }
    }
  }

  Future<void> _saveReading() async {
    if (_recognized.isEmpty ||
        _recognized == 'Цифры не найдены' ||
        _recognized.startsWith('Ошибка')) {
      return;
    }

    /*
     * Берём первое распознанное числовое значение.
     *
     * Например:
     * "142.5"
     * "142,5"
     *
     * Если OCR нашёл несколько чисел,
     * первое используется как показание.
     */
    final firstValue = _recognized.split(' ').first.replaceAll(',', '.');

    final value = double.tryParse(firstValue);

    if (value == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось определить показание')),
      );

      return;
    }

    try {
      await _databaseService.insertUserReading(
        meterId: widget.meterId,
        value: value,
      );

      if (!mounted) {
        return;
      }

      setState(() {
        _saved = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Показание сохранено в SQLite')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
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
      return Scaffold(
        appBar: AppBar(title: const Text('Сканирование счётчика')),
        body: const Center(child: CircularProgressIndicator()),
      );
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
                Text(
                  _recognized.isEmpty
                      ? 'Сфотографируйте показания'
                      : _recognized,
                  style: const TextStyle(fontSize: 18),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isBusy ? null : _scan,
                    icon: const Icon(Icons.camera_alt),
                    label: Text(
                      _isBusy ? 'Распознавание...' : 'Сфотографировать',
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                if (_recognized.isNotEmpty &&
                    _recognized != 'Цифры не найдены' &&
                    !_recognized.startsWith('Ошибка'))
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _saved ? null : _saveReading,
                      icon: const Icon(Icons.save),
                      label: Text(
                        _saved ? 'Показание сохранено' : 'Сохранить показание',
                      ),
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
