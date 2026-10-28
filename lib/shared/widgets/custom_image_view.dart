import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:ternak_pro/shared/theme.dart';

String normalizeAssetUrl(String imagePath) {
  var resolvedPath = imagePath;
  for (var i = 0; i < 2; i++) {
    if (!resolvedPath.contains('%')) break;
    final decodedPath = Uri.decodeComponent(resolvedPath);
    if (decodedPath == resolvedPath) break;
    resolvedPath = decodedPath;
  }

  imagePath = resolvedPath;
  if (!imagePath.startsWith('http://') && !imagePath.startsWith('https://')) {
    const serverAssetPrefixes = [
      '/main_assets/',
      'main_assets/',
      '/storage/',
      'storage/',
      '/uploads/',
      'uploads/',
    ];
    final isServerAsset = serverAssetPrefixes.any(
      (prefix) => imagePath.startsWith(prefix),
    );
    if (isServerAsset) {
      final path = imagePath.startsWith('/') ? imagePath : '/$imagePath';
      final normalizedPath = _normalizeUploadedImagePath(
        path
            .replaceFirst('/main_assets/icons/', '/assets/icons/')
            .replaceFirst('/main_assets/images/', '/assets/images/'),
      );
      return Uri(
        scheme: 'https',
        host: 'hawariyyun.my.id',
        path: normalizedPath,
      ).toString();
    }
    return imagePath;
  }

  try {
    final uri = Uri.parse(imagePath);
    final fileName = uri.pathSegments.isEmpty ? '' : uri.pathSegments.last;
    const localIconPaths = {
      'ic_snack.png': 'assets/home_assets/icons/ic_snack.png',
      'ic_shield.png': 'assets/home_assets/icons/ic_shield.png',
    };
    if (localIconPaths.containsKey(fileName)) {
      return localIconPaths[fileName]!;
    }

    const legacyHosts = {
      'app.ternakpro.id',
      'ternakpro.id',
      'www.ternakpro.id',
      'api.ternakpro.id',
    };

    if (!legacyHosts.contains(uri.host) && uri.host != 'hawariyyun.my.id') {
      return imagePath;
    }

    var path = uri.path;
    if (path.contains('/main_assets/icons/')) {
      path = path.replaceFirst('/main_assets/icons/', '/assets/icons/');
    } else if (path.contains('/main_assets/images/')) {
      path = path.replaceFirst('/main_assets/images/', '/assets/images/');
    }
    path = _normalizeUploadedImagePath(path);

    return uri.replace(host: 'hawariyyun.my.id', path: path).toString();
  } on FormatException {
    return imagePath;
  }
}

String _normalizeUploadedImagePath(String path) {
  final fileName = path.split('/').last.toLowerCase();
  const uploadedFileNames = {
    'sekam.png': 'sekam.jpg',
    'singkong.png': 'singkong.jpeg',
    'bondol.png': 'bonggol.jpg',
    'rumput.png': 'rumput.jpg',
    'daging_sapi.png': 'daging_sapi.jpg',
    'daging_ayam.png': 'daging_ayam.jpg',
    'susu_kambing.png': 'susu_kambing.jpg',
    'telur.png': 'telur.jpg',
  };
  final replacement = uploadedFileNames[fileName];
  if (replacement == null) return path;
  return '${path.substring(0, path.length - fileName.length)}$replacement';
}

extension ImageTypeExtension on String {
  ImageType get imageType {
    if (startsWith('http') || startsWith('https')) {
      if (endsWith('.svg')) {
        return ImageType.networkSvg;
      }
      return ImageType.network;
    } else if (endsWith('.svg')) {
      return ImageType.svg;
    } else if (startsWith('file://')) {
      return ImageType.file;
    } else {
      return ImageType.png;
    }
  }
}

enum ImageType { svg, png, network, networkSvg, file, unknown }

// ignore: must_be_immutable
class CustomImageView extends StatelessWidget {
  CustomImageView({
    super.key,
    this.imagePath,
    this.height,
    this.width,
    this.color,
    this.fit,
    this.alignment,
    this.onTap,
    this.radius,
    this.margin,
    this.border,
    this.placeHolder,
  }) {
    if (imagePath == null || imagePath!.isEmpty) {
      imagePath = 'assets/home_assets/images/img_not_found.png';
    }
  }

  ///[imagePath] is required parameter for showing image
  late String? imagePath;

  final double? height;

  final double? width;

  final Color? color;

  final BoxFit? fit;

  final String? placeHolder;

  final Alignment? alignment;

  final VoidCallback? onTap;

  final EdgeInsetsGeometry? margin;

  final BorderRadius? radius;

  final BoxBorder? border;

  @override
  Widget build(BuildContext context) {
    return alignment != null
        ? Align(alignment: alignment!, child: _buildWidget())
        : _buildWidget();
  }

  Widget _buildWidget() {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(onTap: onTap, child: _buildCircleImage()),
    );
  }

  ///build the image with border radius
  _buildCircleImage() {
    if (radius != null) {
      return ClipRRect(
        borderRadius: radius ?? BorderRadius.zero,
        child: _buildImageWithBorder(),
      );
    } else {
      return _buildImageWithBorder();
    }
  }

  ///build the image with border and border radius style
  _buildImageWithBorder() {
    if (border != null) {
      return Container(
        decoration: BoxDecoration(border: border, borderRadius: radius),
        child: _buildImageView(),
      );
    } else {
      return _buildImageView();
    }
  }

  Widget _buildImageView() {
    final resolvedImagePath = normalizeAssetUrl(imagePath!);

    switch (resolvedImagePath.imageType) {
      case ImageType.svg:
        return SizedBox(
          height: height,
          width: width,
          child: SvgPicture.asset(
            resolvedImagePath,
            height: height,
            width: width,
            fit: fit ?? BoxFit.contain,
            colorFilter: color != null
                ? ColorFilter.mode(
                    color ?? AppColors.transparent,
                    BlendMode.srcIn,
                  )
                : null,
          ),
        );
      case ImageType.file:
        return Image.file(
          File(resolvedImagePath),
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
      case ImageType.networkSvg:
        return SvgPicture.network(
          resolvedImagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.contain,
          colorFilter: color != null
              ? ColorFilter.mode(
                  color ?? AppColors.transparent,
                  BlendMode.srcIn,
                )
              : null,
        );
      case ImageType.network:
        return Image.network(
          resolvedImagePath,
          height: height,
          width: width,
          fit: fit,
          color: color,
          webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
          errorBuilder: (context, error, stackTrace) {
            return Image.asset(
              placeHolder ?? 'assets/home_assets/images/img_not_found.png',
              height: height,
              width: width,
              fit: fit ?? BoxFit.cover,
            );
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return SizedBox(
              height: height,
              width: width,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.grey,
                  strokeWidth: 2,
                ),
              ),
            );
          },
        );
      case ImageType.png:
      default:
        return Image.asset(
          resolvedImagePath,
          height: height,
          width: width,
          fit: fit ?? BoxFit.cover,
          color: color,
        );
    }
  }
}
