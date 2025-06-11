import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

/// A widget for displaying images from the local file system.
///
/// Handles:
/// - Normal rendering of local image files via [Image.file]
/// - File permission errors (e.g. "Permission denied") with a user-friendly fallback
/// - Missing file errors with a customizable placeholder
///
class SafeLocalImage extends StatelessWidget {
  /// Full file path to the image on local storage.
  final String path;

  /// Optional fixed height for the image or placeholder.
  final double? height;

  /// Optional fixed width for the image or placeholder.
  final double? width;

  /// Defines how the image should be inscribed into the space allocated.
  final BoxFit fit;

  /// Border radius for rounding the image or placeholder container.
  final BorderRadius borderRadius;

  /// Whether to show a "Go to Settings" button when permissions are denied.
  final bool showSettingsButton;

  /// Optional placeholder message when the file is not found.
  final String? placeholderText;

  /// Custom text style for placeholder messages.
  final TextStyle? textStyle;

  /// Optional icon to display next to the placeholder message.
  final Icon? icon;

  /// Whether to display the placeholder layout vertically (column) or horizontally (row).
  final bool verticalLayout;

  /// Creates a [SafeLocalImage] widget that attempts to load a local image
  /// and handles missing files or permission issues.
  const SafeLocalImage({
    Key? key,
    required this.path,
    this.height,
    this.width,
    this.fit = BoxFit.cover,
    this.borderRadius = const BorderRadius.all(Radius.circular(0)),
    this.showSettingsButton = true,
    this.placeholderText,
    this.textStyle,
    this.icon,
    this.verticalLayout = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = width ?? MediaQuery.of(context).size.width;

    return ClipRRect(
      borderRadius: borderRadius,
      child: Image.file(
        File(path),
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          if (error is FileSystemException) {
            if (error.osError?.message.contains('Permission denied') ?? false) {
              return _buildPermissionDeniedUI(context, resolvedWidth);
            }
          }

          // Fallback placeholder when image cannot be loaded
          return _buildPlaceholderContainer(
            context,
            Text(
              placeholderText ?? "Image not found",
              textAlign: TextAlign.center,
              style:
                  textStyle ??
                  GoogleFonts.libreBaskerville(
                    color: Colors.black54,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          );
        },
      ),
    );
  }

  /// Builds a UI shown when permission to read local files is denied.
  Widget _buildPermissionDeniedUI(BuildContext context, double width) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 163, 208),
        borderRadius: borderRadius,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          verticalLayout
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  icon ?? const Icon(Icons.lock, size: 17),
                  const SizedBox(height: 6),
                  Text(
                    "Permission required to view this image",
                    textAlign: TextAlign.center,
                    style:
                        textStyle ??
                        GoogleFonts.libreBaskerville(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              )
              : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  icon ?? const Icon(Icons.lock, size: 17),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Permission required to view this image",
                      textAlign: TextAlign.center,
                      style:
                          textStyle ??
                          GoogleFonts.libreBaskerville(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
          if (showSettingsButton)
            Flexible(
              child: FilledButton.icon(
                onPressed: () async {
                  await openAppSettings();
                },
                icon: const Icon(Icons.settings),
                label: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "Go to Settings",
                    style: GoogleFonts.playpenSans(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                style: ButtonStyle(
                  padding: WidgetStateProperty.all(
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  backgroundColor: WidgetStateProperty.all(
                    const Color(0xFF323074),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// Builds a default placeholder container with a fallback message or icon.
  Widget _buildPlaceholderContainer(BuildContext context, Widget child) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
