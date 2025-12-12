import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:open_filex/open_filex.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Foto em PDF',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();
  XFile? _capturedImage;
  bool _isGeneratingPdf = false;
  String? _lastPdfPath;

  Future<void> _takePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 90,
      );

      if (photo != null) {
        setState(() {
          _capturedImage = photo;
          _lastPdfPath = null; // limpa o caminho do PDF anterior
        });
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao tirar foto: $e')),
      );
    }
  }

  Future<void> _generatePdf() async {
    if (_capturedImage == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tire uma foto primeiro!')),
      );
      return;
    }

    setState(() {
      _isGeneratingPdf = true;
    });

    String? pdfPath;

    try {
      // Lê a foto como bytes
      final Uint8List imageBytes = await _capturedImage!.readAsBytes();

      // Cria documento PDF
      final pdf = pw.Document();
      final image = pw.MemoryImage(imageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(
                image,
                fit: pw.BoxFit.contain,
              ),
            );
          },
        ),
      );

      // Diretório privado do app
      final Directory dir = await getApplicationDocumentsDirectory();
      pdfPath =
          '${dir.path}/foto_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final File pdfFile = File(pdfPath);
      await pdfFile.writeAsBytes(await pdf.save());

      if (!mounted) return;

      setState(() {
        _lastPdfPath = pdfPath;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('PDF gerado em:\n$pdfPath')),
      );

      // Tenta abrir o PDF (se tiver leitor de PDF no celular)
      try {
        await OpenFilex.open(pdfPath);
      } catch (e) {
        // Se não conseguir abrir, pelo menos o arquivo foi criado
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'PDF gerado, mas não consegui abrir automaticamente: $e')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao gerar PDF: $e')),
      );
    } finally {
      // Aqui garante que o botão pare de girar, dê certo ou dê errado
      if (mounted) {
        setState(() {
          _isGeneratingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final imageWidget = _capturedImage != null
        ? Image.file(
            File(_capturedImage!.path),
            width: 200,
            height: 200,
            fit: BoxFit.cover,
          )
        : const Text('Nenhuma foto tirada ainda');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Foto → PDF (Flutter)'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: Center(child: imageWidget),
            ),
            if (_lastPdfPath != null)
              Text(
                'Último PDF:\n$_lastPdfPath',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 12),
              ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: FilledButton(
                    onPressed: _isGeneratingPdf ? null : _takePhoto,
                    child: const Text('Tirar Foto'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.tonal(
                    onPressed: _isGeneratingPdf ? null : _generatePdf,
                    child: _isGeneratingPdf
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Gerar PDF'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}