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

class _CameraViewState extends State<CameraView> {
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
      // Calculate magnitude of acceleration
      double magnitude = sqrt(event.x * event.x + event.y * event.y + event.z * event.z);
      
      // If the difference between last magnitude is extremely small, it's on a table.
      double delta = (magnitude - _lastAccelMagnitude).abs();
      _lastAccelMagnitude = magnitude;

      if (mounted) {
        setState(() {
          // If delta is less than 0.1, the phone is perfectly still (e.g., on a table)
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
          // Anti-Cheat: Multiple Faces
          _updateWarning('Multiple faces detected. Please stand alone.');
        } else {
          final face = faces.first;

          // Anti-Cheat: Face Occlusion / Sunglass Check
          if (face.leftEyeOpenProbability == null || face.rightEyeOpenProbability == null) {
            _updateWarning('Please remove glasses or masks.');
            _isDetecting = false;
            return;
          }

          // Check if face is looking straight
          if (face.headEulerAngleY != null && face.headEulerAngleY!.abs() < 15) {
            _updateWarning(''); // Clear warnings

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
      var rotationCompensation = 0; // Simplified for portrait
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _controller == null) {
      return const Center(child: CircularProgressIndicator());
    }
    
    // Fixed Aspect Ratio for Portrait camera
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
        // Overlay mask
        ColorFiltered(
          colorFilter: const ColorFilter.mode(
            Colors.black54,
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
                  height: 350,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(200),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Warning Banner
        if (_warningMessage.isNotEmpty)
          Positioned(
            top: 40, left: 20, right: 20,
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.redAccent.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _warningMessage,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        // Instructions
        Positioned(
          top: 100,
          left: 0, right: 0,
          child: Text(
            'Center your face inside the oval',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600),
          ),
        ),
        Positioned(
          bottom: 120,
          left: 0, right: 0,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _challengePassed ? Colors.green.withOpacity(0.9) : Colors.orange.withOpacity(0.9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _challengePassed 
                  ? 'Verified! Processing...'
                  : _currentChallenge == LivenessChallengeType.blink 
                      ? 'Please BLINK once for liveness check'
                      : 'Please SMILE for liveness check',
              textAlign: TextAlign.center,
              style: GoogleFonts.poppins(
                color: Colors.white, 
                fontSize: 14, 
                fontWeight: FontWeight.w600
              ),
            ),
          ),
        ),
      ],
    );
  }
}
