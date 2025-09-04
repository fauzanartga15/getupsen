// File: lib/widgets/enhanced_face_overlay_painter.dart
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class EnhancedFaceOverlayPainter extends CustomPainter {
  final List<Face> faces;
  final Size imageSize;
  final Size previewSize;
  final Map<int, String> faceNames;
  final Map<int, double> faceConfidences;
  final Map<int, bool> isRecognized;
  final int selectedFaceIndex; // NEW: For face selection
  final bool isBackCamera;

  EnhancedFaceOverlayPainter({
    required this.faces,
    required this.imageSize,
    required this.previewSize,
    required this.faceNames,
    required this.faceConfidences,
    required this.isRecognized,
    required this.selectedFaceIndex,
    this.isBackCamera = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (faces.isEmpty) return;

    final scaleX = size.width / imageSize.width;
    final scaleY = size.height / imageSize.height;

    for (int i = 0; i < faces.length; i++) {
      final face = faces[i];
      final recognized = isRecognized[i] ?? false;
      final isSelected = i == selectedFaceIndex;

      // Enhanced color logic for selection
      Color rectColor;
      Color labelColor;
      double strokeWidth;

      if (isSelected && recognized) {
        // Selected and recognized - bright green with thicker border
        rectColor = Colors.green.shade400;
        labelColor = Colors.green.shade400;
        strokeWidth = 4.0;
      } else if (recognized) {
        // Recognized but not selected - normal green
        rectColor = Colors.green;
        labelColor = Colors.green;
        strokeWidth = 3.0;
      } else {
        // Not recognized - orange
        rectColor = Colors.orange;
        labelColor = Colors.orange;
        strokeWidth = 2.0;
      }

      // Paint for face rectangles
      final Paint facePaint = Paint()
        ..color = rectColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth;

      // Paint for labels background
      final Paint labelPaint = Paint()
        ..color = labelColor.withValues(alpha: 0.8);

      // Transform face bounding box to preview coordinates
      final transformedRect = _transformRect(
        face.boundingBox,
        scaleX,
        scaleY,
        size.width,
      );

      // Draw face rectangle
      canvas.drawRect(transformedRect, facePaint);

      // Add selection indicator
      if (isSelected && recognized) {
        final Paint selectionPaint = Paint()
          ..color = Colors.green.shade400.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawRect(transformedRect, selectionPaint);

        // Add corner indicators
        _drawSelectionCorners(canvas, transformedRect, Colors.green.shade400);
      }

      // Get face label with confidence
      String label;
      if (recognized) {
        final name = faceNames[i] ?? 'Unknown';
        final confidence = faceConfidences[i] ?? 0.0;
        label = '$name (${confidence.toStringAsFixed(0)}%)';
      } else {
        label = faceNames[i] ?? 'Face ${i + 1}';
      }

      // Draw label
      _drawLabel(
        canvas,
        label,
        transformedRect,
        labelPaint,
        recognized,
        isSelected,
      );
    }
  }

  // Transform ML Kit coordinates to preview coordinates
  Rect _transformRect(
    Rect rect,
    double scaleX,
    double scaleY,
    double previewWidth,
  ) {
    double left, top, right, bottom;

    if (isBackCamera) {
      left = rect.left * scaleX;
      right = rect.right * scaleX;
    } else {
      left = previewWidth - (rect.right * scaleX);
      right = previewWidth - (rect.left * scaleX);
    }

    top = rect.top * scaleY;
    bottom = rect.bottom * scaleY;

    return Rect.fromLTRB(left, top, right, bottom);
  }

  // Draw selection corner indicators
  void _drawSelectionCorners(Canvas canvas, Rect rect, Color color) {
    final Paint cornerPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const double cornerSize = 20.0;

    // Top-left corner
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left + cornerSize, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.top + cornerSize),
      cornerPaint,
    );

    // Top-right corner
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right - cornerSize, rect.top),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.right, rect.top + cornerSize),
      cornerPaint,
    );

    // Bottom-left corner
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left + cornerSize, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.left, rect.bottom),
      Offset(rect.left, rect.bottom - cornerSize),
      cornerPaint,
    );

    // Bottom-right corner
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right - cornerSize, rect.bottom),
      cornerPaint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.bottom),
      Offset(rect.right, rect.bottom - cornerSize),
      cornerPaint,
    );
  }

  // Enhanced label drawing with selection styling
  void _drawLabel(
    Canvas canvas,
    String label,
    Rect faceRect,
    Paint labelPaint,
    bool recognized,
    bool isSelected,
  ) {
    final faceWidth = faceRect.width;
    final fontSize = (faceWidth / 8).clamp(14.0, 24.0);

    // Enhanced text styling for selected faces
    final textSpan = TextSpan(
      text: label,
      style: TextStyle(
        color: Colors.white,
        fontSize: fontSize,
        fontWeight: isSelected
            ? FontWeight.w900
            : (recognized ? FontWeight.bold : FontWeight.w500),
        shadows: [
          Shadow(
            blurRadius: isSelected ? 6 : 4,
            color: Colors.black87,
            offset: Offset(1, 1),
          ),
        ],
      ),
    );

    final textPainter = TextPainter(
      text: textSpan,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();

    // Enhanced label background
    final labelHeight = fontSize + (isSelected ? 12 : 8);
    final labelWidth = textPainter.width + (isSelected ? 20 : 16);

    final labelRect = Rect.fromLTWH(
      faceRect.left,
      faceRect.top - labelHeight - 4,
      labelWidth,
      labelHeight,
    );

    // Draw label background with enhanced styling for selection
    if (isSelected) {
      // Add glow effect for selected face
      final glowPaint = Paint()
        ..color = labelPaint.color.withValues(alpha: 0.3)
        ..maskFilter = MaskFilter.blur(BlurStyle.outer, 4);

      canvas.drawRRect(
        RRect.fromRectAndRadius(labelRect.inflate(2), Radius.circular(10)),
        glowPaint,
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(labelRect, Radius.circular(isSelected ? 10 : 8)),
      labelPaint,
    );

    // Draw text
    final textOffset = Offset(
      faceRect.left + (isSelected ? 10 : 8),
      faceRect.top - labelHeight + (isSelected ? 4 : 2),
    );

    textPainter.paint(canvas, textOffset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true; // Always repaint for live updates
  }
}
