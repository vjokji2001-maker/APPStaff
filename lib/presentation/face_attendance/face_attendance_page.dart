import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../theme/hr_theme.dart';
import '../../di/providers.dart';
import 'face_attendance_cubit.dart';
import 'face_attendance_state.dart';
import 'widgets/camera_view.dart';
import 'widgets/liveness_challenge.dart';
import 'widgets/attendance_success_screen.dart';

import 'widgets/face_attendance_error_view.dart';

class FaceAttendancePage extends StatelessWidget {
  final String punchDirection;
  const FaceAttendancePage({super.key, required this.punchDirection});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<FaceAttendanceCubit>()..initialize(punchDirection),
      child: BlocBuilder<FaceAttendanceCubit, FaceAttendanceState>(
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: Text(punchDirection == 'IN' ? 'Check In' : 'Check Out', style: GoogleFonts.poppins()),
            ),
            body: _buildBody(state, context),
          );
        },
      ),
    );
  }

  Widget _buildBody(FaceAttendanceState state, BuildContext context) {
    if (state is FaceAttendanceInitial) {
      return const Center(child: Text('Preparing...'));
    } else if (state is FaceAttendancePermissionLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is FaceAttendancePermissionDenied) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text('Permissions required: ${state.missing.join(', ')}',
                style: GoogleFonts.poppins()),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.read<FaceAttendanceCubit>().requestPermissions(),
              child: const Text('Grant Permissions'),
            ),
          ],
        ),
      );
    } else if (state is FaceAttendanceReady) {
      return CameraView(onFaceDetected: (image) => context.read<FaceAttendanceCubit>().processFace(image));
    } else if (state is FaceAttendanceLiveness) {
      return LivenessChallenge(onChallengeResult: (passed) => context.read<FaceAttendanceCubit>().handleLivenessResult(passed));
    } else if (state is FaceAttendanceSuccess) {
      return AttendanceSuccessScreen(attendance: state.attendance);
    } else if (state is FaceAttendanceError) {
      return FaceAttendanceErrorView(
        rawError: state.message,
        onRetry: () => context.read<FaceAttendanceCubit>().retry(),
      );
    }
    return const SizedBox.shrink();
  }
}
