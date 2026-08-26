import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_zxing/flutter_zxing.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/dimens.dart';
import '../../widgets/app_dialog.dart';

/// Skeniranje QR koda karte preko kamere racunara - alternativa rucnom unosu.
///
/// Osoblje pritisne "Skeniraj" kad je kod centriran u kadru; app slika i
/// dekodira taj snimak (nema kontinuiranog live stream dekodiranja na
/// Windows desktopu bez placenog SDK-a, pa je ovo najpouzdaniji pristup).
class QrScannerDialog extends StatefulWidget {
  const QrScannerDialog({super.key});

  @override
  State<QrScannerDialog> createState() => _QrScannerDialogState();
}

class _QrScannerDialogState extends State<QrScannerDialog> {
  CameraController? _controller;
  String? _initError;
  String? _scanError;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _initError = 'Nije pronadjena nijedna kamera na ovom racunaru.');
        return;
      }
      final controller = CameraController(cameras.first, ResolutionPreset.medium, enableAudio: false);
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() => _controller = controller);
    } catch (error) {
      if (mounted) setState(() => _initError = 'Neuspjelo pokretanje kamere: $error');
    }
  }

  Future<void> _scan() async {
    final controller = _controller;
    if (controller == null || _isScanning) return;

    setState(() {
      _isScanning = true;
      _scanError = null;
    });

    try {
      final photo = await controller.takePicture();
      final result = await zx.readBarcodeImagePathString(
        photo.path,
        DecodeParams(format: Format.qrCode, tryHarder: true),
      );

      if (!mounted) return;

      if (result.isValid && result.text != null && result.text!.isNotEmpty) {
        Navigator.of(context).pop(result.text);
        return;
      }

      setState(() => _scanError = 'Kod nije prepoznat. Centrirajte QR kod u kadar i pokusajte ponovo.');
    } catch (error) {
      if (mounted) setState(() => _scanError = 'Greska pri skeniranju: $error');
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppDialog(
      title: 'Skeniranje QR koda',
      subtitle: 'Centrirajte QR kod karte u kadar i pritisnite "Skeniraj".',
      width: AppSizes.dialogWidth,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.md),
              child: ColoredBox(
                color: Colors.black,
                child: _initError != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Text(
                            _initError!,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
                          ),
                        ),
                      )
                    : _controller == null
                        ? const Center(child: CircularProgressIndicator())
                        : CameraPreview(_controller!),
              ),
            ),
          ),
          if (_scanError != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_scanError!, style: theme.textTheme.bodySmall?.copyWith(color: AppColors.danger)),
          ],
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Otkazi'),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: FilledButton.icon(
                  onPressed: _controller == null || _isScanning ? null : _scan,
                  icon: _isScanning
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.qr_code_scanner_rounded),
                  label: const Text('Skeniraj'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
