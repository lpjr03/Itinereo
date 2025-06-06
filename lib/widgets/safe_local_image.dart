import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:permission_handler/permission_handler.dart';

enum FileCheckResult { found, notFound }

class SafeLocalImage extends StatefulWidget {
  final String path;
  final double height;
  final double? width;
  final BoxFit fit;
  final BorderRadius borderRadius;
  final bool showSettingsButton;
  final String? placeholderText;
  final TextStyle? textStyle;
  final Icon? icon;
  final bool verticalLayout;
  final bool hasStoragePermission; // <-- nuovo parametro

  const SafeLocalImage({
    Key? key,
    required this.path,
    required this.height,
    required this.hasStoragePermission, // <-- richiesto
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
  State<SafeLocalImage> createState() => _SafeLocalImageState();
}

class _SafeLocalImageState extends State<SafeLocalImage> {
  FileCheckResult? result;

  @override
  void initState() {
    super.initState();
    _checkFileStatus();
  }

  Future<void> _checkFileStatus() async {
    try {
      final file = File(widget.path);
      final exists = await file.exists();

      setState(() {
        result = exists ? FileCheckResult.found : FileCheckResult.notFound;
      });
    } catch (_) {
      setState(() => result = FileCheckResult.notFound);
    }
  }

  @override
  Widget build(BuildContext context) {
    final resolvedWidth = widget.width ?? MediaQuery.of(context).size.width;

    if (!widget.hasStoragePermission) {
      return _buildPermissionDeniedUI(resolvedWidth);
    }

    if (result == null) {
      return _buildPlaceholderContainer(
        context,
        const CircularProgressIndicator(),
      );
    }

    if (result == FileCheckResult.found) {
      return ClipRRect(
        borderRadius: widget.borderRadius,
        child: Image.file(
          File(widget.path),
          fit: widget.fit,
          height: widget.height,
          width: resolvedWidth,
        ),
      );
    }

    return _buildPlaceholderContainer(
      context,
      Text(
        widget.placeholderText ?? "Image not found",
        textAlign: TextAlign.center,
        style:
            widget.textStyle ??
            GoogleFonts.libreBaskerville(
              color: Colors.black54,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
      ),
    );
  }

  Widget _buildPermissionDeniedUI(double width) {
    return Container(
      height: widget.height,
      width: width,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 164, 163, 208),
        borderRadius: widget.borderRadius,
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          widget.verticalLayout
              ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  widget.icon ?? const Icon(Icons.lock, size: 17),
                  const SizedBox(height: 6),
                  Text(
                    "Permission required to view this image",
                    textAlign: TextAlign.center,
                    softWrap: true,
                    overflow: TextOverflow.visible,
                    style:
                        widget.textStyle ??
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
                  widget.icon ?? const Icon(Icons.lock, size: 17),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      "Permission required to view this image",
                      textAlign: TextAlign.center,
                      softWrap: true,
                      overflow: TextOverflow.visible,
                      style:
                          widget.textStyle ??
                          GoogleFonts.libreBaskerville(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                  ),
                ],
              ),
          if (widget.showSettingsButton)
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

  Widget _buildPlaceholderContainer(BuildContext context, Widget child) {
    return Container(
      height: widget.height,
      width: widget.width ?? double.infinity,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: widget.borderRadius,
      ),
      child: child,
    );
  }
}
