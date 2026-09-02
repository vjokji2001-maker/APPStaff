import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:screen_protector/screen_protector.dart';
import 'package:staff_mate/my_hr/theme/hr_theme.dart';
import 'package:sensors_plus/sensors_plus.dart';
enum LivenessChallengeType { blink, smile }

class CameraView extends StatefulWidget {
  final void Function(XFile image) onFaceDetected;

  const CameraView({Key? key, required this.onFaceDetected}) : super(key: key);

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> with SingleTickerProviderStateMixin {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _isInitialized = false;
  bool _isDetecting = false;
  
  late final FaceDetector _faceDetector;
  
  // Motion Sensor (Anti-Cheat)
  StreamSubscription<AccelerometerEvent>? _accelSubscription;
  double _lastAccelMagnitude = 0.0;
  bool _isDeviceMoving = false;

  // Liveness check variables
  late LivenessChallengeType _currentChallenge;
  bool _challengePassed = false;
  bool _eyesClosed = false;
  String _warningMessage = '';

  // AI Scanner Animations
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _secureScreen();
    
    // Pick random challenge
    _currentChallenge = Random().nextBool() ? LivenessChallengeType.blink : LivenessChallengeType.smile;

    // Start motion sensor checking
    _startMotionSensor();

    final options = FaceDetectorOptions(
      enableClassification: true,
      enableTracking: true,
      performanceMode: FaceDetectorMode.fast,
    );
    _faceDetector = FaceDetector(options: options);
    
    // Setup animations
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOutSine),
    );
    
    _opacityAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _initializeCamera();
  }

  Future<void> _secureScreen() async {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      await ScreenProtector.protectDataLeakageWithBlur();
      await ScreenProtector.preventScreenshotOn();
    }
  }

  void _startMotionSensor() {
    _accelSubscription = accelerometerEventStream().listen((AccelerometerEvent event) {
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      double delta = (magnitude - _lastAccelMagnitude).abs();
      _lastAccelMagnitude = magnitude;

      if (mounted) {
        setState(() {
          _isDeviceMoving = delta > 0.1;
        });
      }
    });
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras == null || _cameras!.isEmpty) {
        _updateWarning('No cameras found on device');
        return;
      }
      final frontCamera = _cameras!.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      _controller = CameraController(
        frontCamera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: (!kIsWeb && Platform.isAndroid) 
            ? ImageFormatGroup.nv21 
            : ImageFormatGroup.bgra8888,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
      _startImageStream();
    } catch (e) {
      debugPrint("Camera Init Error: $e");
      _updateWarning('Failed to open camera: $e');
    }
  }

  void _startImageStream() {
    _controller!.startImageStream((CameraImage image) async {
      if (_isDetecting || _challengePassed) return;
      _isDetecting = true;
      try {
        if (!_isDeviceMoving) {
          _updateWarning('Hold phone in hand. It must not be placed on a surface.');
          _isDetecting = false;
          return;
        }

        final inputImage = _inputImageFromCameraImage(image);
        if (inputImage == null) {
          _isDetecting = false;
          return;
        }

        final faces = await _faceDetector.processImage(inputImage);
        
        if (faces.isEmpty) {
          _updateWarning('');
        } else if (faces.length > 1) {
          _updateWarning('Multiple faces detected. Please stand alone.');
        } else {
          final face = faces.first;

          if (face.leftEyeOpenProbability == null || face.rightEyeOpenProbability == null) {
            _updateWarning('Please remove glasses or masks.');
            _isDetecting = false;
            return;
          }

          if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() < 15) {
            _updateWarning('');

            if (_currentChallenge == LivenessChallengeType.blink) {
              _processBlinkChallenge(face);
            } else {
              _processSmileChallenge(face);
            }

            if (_challengePassed) {
              await _controller!.stopImageStream();
              final file = await _controller!.takePicture();
              widget.onFaceDetected(file);
              return;
            }
          } else {
            _updateWarning('Look straight at the camera.');
          }
        }
      } catch (e) {
        debugPrint("Error detecting face: $e");
      }
      _isDetecting = false;
    });
  }

  void _updateWarning(String message) {
    if (_warningMessage != message && mounted) {
      setState(() => _warningMessage = message);
    }
  }

  void _processBlinkChallenge(Face face) {
    final leftOpen = face.leftEyeOpenProbability!;
    final rightOpen = face.rightEyeOpenProbability!;
    
    if (leftOpen < 0.2 && rightOpen < 0.2) {
      _eyesClosed = true;
    } else if (leftOpen > 0.8 && rightOpen > 0.8 && _eyesClosed) {
      _eyesClosed = false;
      if (mounted) {
        setState(() => _challengePassed = true);
      }
    }
  }

  void _processSmileChallenge(Face face) {
    if (face.smilingProbability != null && face.smilingProbability! > 0.7) {
      if (mounted) {
        setState(() => _challengePassed = true);
      }
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null || _cameras == null || _cameras!.isEmpty) return null;
    final camera = _cameras!.firstWhere((c) => c.lensDirection == CameraLensDirection.front);
    final sensorOrientation = camera.sensorOrientation;
    
    InputImageRotation? rotation;
    if (!kIsWeb && Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (!kIsWeb && Platform.isAndroid) {
      var rotationCompensation = 0; 
      final int rotationRaw = (sensorOrientation - rotationCompensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationRaw);
    } else {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    }
    
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (!kIsWeb && Platform.isAndroid && format != InputImageFormat.nv21) ||
        (!kIsWeb && Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    final WriteBuffer allBytes = WriteBuffer();
    for (final Plane plane in image.planes) {
      allBytes.putUint8List(plane.bytes);
    }
    final bytes = allBytes.done().buffer.asUint8List();

    return InputImage.fromBytes(
      bytes: bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: image.planes[0].bytesPerRow,
      ),
    );
  }

  @override
  void dispose() {
    if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
      ScreenProtector.preventScreenshotOff();
    }
    _accelSubscription?.cancel();
    _controller?.stopImageStream();
    _controller?.dispose();
    _faceDetector.close();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return Scaffold(
        backgroundColor: const Color(0xFF071118),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_warningMessage.isEmpty)
                const CircularProgressIndicator(color: Colors.cyanAccent)
              else
                const Icon(Icons.error_outline, color: Colors.redAccent, size: 48),
              const SizedBox(height: 16),
              Text(
                _warningMessage.isEmpty ? 'Initializing Camera...' : _warningMessage,
                style: GoogleFonts.poppins(
                  color: _warningMessage.isEmpty ? Colors.white : Colors.redAccent,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
    
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;
    
    final darkBgColor = const Color(0xFF071118);
    final cyanAccentColor = const Color(0xFF00FFC2);

    return Scaffold(
      backgroundColor: darkBgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
            // Top Section: Header
            const SizedBox(height: 20),
            Icon(Icons.security_rounded, color: cyanAccentColor, size: 36),
            const SizedBox(height: 8),
            Text('FACE AUTHENTICATION', style: GoogleFonts.poppins(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
            const SizedBox(height: 4),
            Text('Secure • Fast • Reliable', style: GoogleFonts.poppins(color: cyanAccentColor.withOpacity(0.7), fontSize: 13)),
            const SizedBox(height: 20),
            
            // Liveness Box
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: cyanAccentColor.withOpacity(0.05),
                border: Border.all(color: cyanAccentColor.withOpacity(0.3)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: cyanAccentColor,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check, color: Colors.black, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('LIVENESS CHECK REQUIRED', style: GoogleFonts.poppins(color: cyanAccentColor, fontWeight: FontWeight.bold, fontSize: 12)),
                        Text('Position your face within the frame and stay still', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                      ],
                    ),
                  )
                ],
              ),
            ),
            
            const Spacer(),
            
            // Camera Area
            SizedBox(
              height: 320,
              width: 320,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera Feed (Circular)
                  ClipOval(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Transform.scale(
                        scale: scale,
                        child: Center(
                          child: CameraPreview(_controller!),
                        ),
                      ),
                    ),
                  ),
                  
                  // Circular Border
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: cyanAccentColor, width: 2),
                      boxShadow: [
                        BoxShadow(color: cyanAccentColor.withOpacity(0.2), blurRadius: 20, spreadRadius: 5),
                      ]
                    ),
                  ),
                  
                  // Grid Overlay (within circle)
                  ClipOval(
                    child: SizedBox(
                      width: 300,
                      height: 300,
                      child: Opacity(
                        opacity: 0.2,
                        child: CustomPaint(painter: GridPainter()),
                      ),
                    ),
                  ),
                  
                  // Scanning Line
                  AnimatedBuilder(
                    animation: _scanAnimation,
                    builder: (context, child) {
                      return Align(
                        alignment: Alignment(0.0, _scanAnimation.value),
                        child: Container(
                          width: 280,
                          height: 3,
                          decoration: BoxDecoration(
                            color: cyanAccentColor,
                            boxShadow: [
                              BoxShadow(color: cyanAccentColor, blurRadius: 10, spreadRadius: 2),
                              BoxShadow(color: Colors.white, blurRadius: 4, spreadRadius: 1),
                            ]
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Corner brackets
                  CustomPaint(
                    size: const Size(320, 320),
                    painter: ScannerCornersPainter(),
                  ),
                ],
              ),
            ),
            
            const Spacer(),
            
            // Status Text below camera
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.verified_user_outlined, color: cyanAccentColor, size: 24),
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_warningMessage.isNotEmpty ? _warningMessage : 'Scanning Face...', style: GoogleFonts.poppins(color: cyanAccentColor, fontSize: 13, fontWeight: FontWeight.bold)),
                    if (_warningMessage.isEmpty)
                      Text('Please do not move', style: GoogleFonts.poppins(color: Colors.white70, fontSize: 11)),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Bottom 4 Icons Panel
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: cyanAccentColor.withOpacity(0.03),
                border: Border.all(color: cyanAccentColor.withOpacity(0.2)),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInstructionItem(Icons.person_outline, 'Face in Frame', cyanAccentColor),
                  _buildInstructionItem(Icons.light_mode_outlined, 'Good Lighting', cyanAccentColor),
                  _buildInstructionItem(Icons.sentiment_satisfied_outlined, 'Look Straight', cyanAccentColor),
                  _buildInstructionItem(Icons.mobile_friendly_outlined, 'Hold Steady', cyanAccentColor),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Footer
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, color: Colors.white54, size: 14),
                const SizedBox(width: 6),
                Text('Your biometric data is secure and encrypted', style: GoogleFonts.poppins(color: Colors.white54, fontSize: 11)),
              ],
            ),
            const SizedBox(height: 16),
          ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildInstructionItem(IconData icon, String label, Color color) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(label, style: GoogleFonts.poppins(color: Colors.white70, fontSize: 10)),
      ],
    );
  }
}

class ScannerCornersPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double cornerLength = 40.0;
    
    // Top Left
    canvas.drawPath(Path()..moveTo(0, cornerLength)..lineTo(0, 0)..lineTo(cornerLength, 0), paint);
    // Top Right
    canvas.drawPath(Path()..moveTo(size.width - cornerLength, 0)..lineTo(size.width, 0)..lineTo(size.width, cornerLength), paint);
    // Bottom Left
    canvas.drawPath(Path()..moveTo(0, size.height - cornerLength)..lineTo(0, size.height)..lineTo(cornerLength, size.height), paint);
    // Bottom Right
    canvas.drawPath(Path()..moveTo(size.width - cornerLength, size.height)..lineTo(size.width, size.height)..lineTo(size.width, size.height - cornerLength), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.cyanAccent
      ..strokeWidth = 1.0;
      
    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
