import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:mobile_scanner/mobile_scanner.dart';

class QRScannerPage extends StatefulWidget {
  const QRScannerPage({super.key});

  @override
  State<QRScannerPage> createState() => _QRScannerPageState();
}

class _QRScannerPageState extends State<QRScannerPage> {
  final MobileScannerController _controller = MobileScannerController();
  bool _scanned = false; // prevents scanning twice

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) async {
    if (_scanned) return; // ignore if already scanned
    
    final barcode = capture.barcodes.first;
    final rawValue = barcode.rawValue;

    if (rawValue == null) return;

    setState(() => _scanned = true);
    _controller.stop();

    // send to your API
    await registerAttendance(rawValue);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan QR Code')),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // overlay to guide the student
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.green, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> registerAttendance(String rawValue) async {
    try {
      final data = jsonDecode(rawValue);

      final response = await http.post(
        Uri.parse('Dummy/attendance/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': data['token'],
          'courseId': data['courseId'],
        }),
      );

      if (response.statusCode == 200) {
        _showResult(success: true);
      } else {
        _showResult(success: false);
      }
    } catch (e) {
      _showResult(success: false);
    }
  }

  void _showResult({required bool success}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(success ? '✅ Attendance Registered' : '❌ Failed'),
        content: Text(
          success
              ? 'Your attendance has been recorded.'
              : 'QR code is invalid or expired.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (success) {
                context.pop(); // go back after success
              } else {
                // allow retry
                setState(() => _scanned = false);
                _controller.start();
              }
            },
            child: Text(success ? 'Done' : 'Try Again'),
          ),
        ],
      ),
    );
  }
}