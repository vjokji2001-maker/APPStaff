import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:screen_protector/screen_protector.dart';
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
    if (Platform.isAndroid || Platform.isIOS) {
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
    _cameras = await availableCameras();
    final frontCamera = _cameras!.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.front,
      orElse: () => _cameras!.first,
    );
    _controller = CameraController(
      frontCamera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid 
          ? ImageFormatGroup.nv21 
          : ImageFormatGroup.bgra8888,
    );
    await _controller!.initialize();
    if (!mounted) return;
    setState(() => _isInitialized = true);
    _startImageStream();
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
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation = 0; 
      final int rotationRaw = (sensorOrientation - rotationCompensation + 360) % 360;
      rotation = InputImageRotationValue.fromRawValue(rotationRaw);
    }
    
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

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
    if (Platform.isAndroid || Platform.isIOS) {
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
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.cyanAccent),
            const SizedBox(height: 16),
            Text('INITIALIZING AI ENGINE...', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 16)),
          ],
        ),
      );
    }
    
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * _controller!.value.aspectRatio;
    if (scale < 1) scale = 1 / scale;

    return Stack(
      fit: StackFit.expand,
      children: [
        Transform.scale(
          scale: scale,
          child: Center(
            child: CameraPreview(_controller!),
          ),
        ),
        // Techy Overlay mask
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black87, // Darker for AI aesthetic
            BlendMode.srcOut,
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: const Alignment(0.0, -0.2),
                child: Container(
                  height: 380,
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        // AI HUD Grid & Scanner Line
        Align(
          alignment: const Alignment(0.0, -0.2),
          child: SizedBox(
            height: 380,
            width: 280,
            child: Stack(
              children: [
                CustomPaint(
                  size: const Size(280, 380),
                  painter: ScannerCornersPainter(),
                ),
                AnimatedBuilder(
                  animation: _scanAnimation,
                  builder: (context, child) {
                    return Align(
                      alignment: Alignment(0.0, _scanAnimation.value), 
                      child: Container(
                        height: 4,
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.cyanAccent,
                          boxShadow: [
                            BoxShadow(color: Colors.cyanAccent.withOpacity(0.8), blurRadius: 15, spreadRadius: 4),
                            BoxShadow(color: Colors.blue.withOpacity(0.6), blurRadius: 30, spreadRadius: 8),
                          ],
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  },
                ),
                // Grid overlay
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.15,
                    child: CustomPaint(painter: GridPainter()),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        // HUD Texts
        Positioned(
          top: 50,
          left: 20,
          child: AnimatedBuilder(
            animation: _opacityAnimation,
            builder: (context, child) {
              return Opacity(
                opacity: _opacityAnimation.value,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SYS // ONLINE', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text('AI_MESH // ACTIVE', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 13, letterSpacing: 1.2)),
                    const SizedBox(height: 4),
                    Text('BIOMETRICS // STANDBY', style: GoogleFonts.shareTechMono(color: Colors.cyanAccent, fontSize: 13, letterSpacing: 1.2)),
                  ],
                ),
              );
            },
          ),
        ),
        
        Positioned(
          top: 50,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('LAT: ${(_isDeviceMoving ? 21.1498 + Random().nextDouble() * 0.0001 : 21.1498).toStringAsFixed(4)}', style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 12)),
              Text('LNG: ${(79.0820 + Random().nextDouble() * 0.0001).toStringAsFixed(4)}', style: GoogleFonts.shareTechMono(color: Colors.greenAccent, fontSize: 12)),
            ],
          ),
        ),

        // Warning Banner
        if (_warningMessage.isNotEmpty)
          Positioned(
            top: 100, 
            left: 20, 
            right: 20,
            child: Text(
              _warningMessage,
              textAlign: TextAlign.center,
              style: GoogleFonts.shareTechMono(
                color: Colors.redAccent, 
                fontWeight: FontWeight.bold, 
                fontSize: 16,
                shadows: [
                  Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4, offset: const Offset(1, 1)),
                  Shadow(color: Colors.black, blurRadius: 8, offset: const Offset(0, 0)),
                ]
              ),
            ),
          ),
        
        // Instructions
        Positioned(
          bottom: 230,
          left: 0, 
          right: 0,
          child: Text(
            'POSITION FACE WITHIN HUD',
            textAlign: TextAlign.center,
            style: GoogleFonts.shareTechMono(
              color: Colors.white70, 
              fontSize: 14, 
              letterSpacing: 2.0,
              shadows: [
                Shadow(color: Colors.black.withOpacity(0.8), blurRadius: 4, offset: const Offset(1, 1))
              ]
            ),
          ),
        ),
        
        Positioned(
          bottom: 120,
          left: 0, right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _challengePassed ? Colors.green.withOpacity(0.85) : Colors.black87,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _challengePassed ? Colors.greenAccent : Colors.cyanAccent, 
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: _challengePassed ? Colors.greenAccent.withOpacity(0.4) : Colors.cyanAccent.withOpacity(0.3), 
                  blurRadius: 15, 
                  spreadRadius: 2
                )
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _challengePassed 
                      ? 'IDENTITY VERIFIED'
                      : 'LIVENESS CHECK REQUIRED',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.shareTechMono(
                    color: _challengePassed ? Colors.white : Colors.cyanAccent, 
                    fontSize: 16, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                if (!_challengePassed) ...[
                  const SizedBox(height: 8),
                  Text(
                    _currentChallenge == LivenessChallengeType.blink 
                        ? '> EXECUTING: BLINK_PROTOCOL'
                        : '> EXECUTING: SMILE_PROTOCOL',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.shareTechMono(
                      color: Colors.white, 
                      fontSize: 14, 
                    ),
                  ),
                ]
              ],
            ),
          ),
        ),
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
