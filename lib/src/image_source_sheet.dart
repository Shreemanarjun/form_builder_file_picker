import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ImageSourceBottomSheet extends StatefulWidget {
  /// Optional maximum height of image
  final double? maxHeight;

  /// Optional maximum width of image
  final double? maxWidth;

  /// The imageQuality argument modifies the quality of the image, ranging from
  /// 0-100 where 100 is the original/max quality. If imageQuality is null, the
  /// image with the original quality will be returned.
  final int? imageQuality;

  final int? remainingImages;

  /// Use preferredCameraDevice to specify the camera to use when the source is
  /// `ImageSource.camera`. The preferredCameraDevice is ignored when source is
  /// `ImageSource.gallery`. It is also ignored if the chosen camera is not
  /// supported on the device. Defaults to `CameraDevice.rear`.
  final CameraDevice preferredCameraDevice;

  /// Callback when images is selected.
  final void Function(Iterable<XFile> files) onImageSelected;
  // Callback when files are selected.
  final void Function(List<PlatformFile> files) onFileSelected;

  final Widget? cameraIcon;
  final Widget? galleryIcon;
  final Widget? cameraLabel;
  final Widget? galleryLabel;
  final EdgeInsets? bottomSheetPadding;
  final bool preventPop;

  final FileType type;
  final List<String>? allowedExtensions;
  final Function(FilePickerStatus)? onFileLoading;
  final bool allowCompression;
  final bool allowMultiple;
  final bool withData;
  final bool withReadStream;

  const ImageSourceBottomSheet({
    Key? key,
    this.remainingImages,
    this.preventPop = false,
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    required this.onImageSelected,
    this.cameraIcon,
    this.galleryIcon,
    this.cameraLabel,
    this.galleryLabel,
    this.bottomSheetPadding,
    this.type = FileType.any,
    this.allowedExtensions,
    this.onFileLoading,
    this.allowCompression = true,
    this.allowMultiple = false,
    this.withData = false,
    this.withReadStream = false,
    required this.onFileSelected,
  }) : super(key: key);

  @override
  _ImageSourceBottomSheetState createState() => _ImageSourceBottomSheetState();
}

class _ImageSourceBottomSheetState extends State<ImageSourceBottomSheet> {
  bool _isPickingImage = false;

  Future<void> _onPickImage(ImageSource source) async {
    if (_isPickingImage) return;
    _isPickingImage = true;
    final imagePicker = ImagePicker();
    try {
      if (source == ImageSource.camera || widget.remainingImages == 1) {
        final pickedFile = await imagePicker.pickImage(
          source: source,
          preferredCameraDevice: widget.preferredCameraDevice,
          maxHeight: widget.maxHeight,
          maxWidth: widget.maxWidth,
          imageQuality: widget.imageQuality,
        );
        _isPickingImage = false;
        if (pickedFile != null) {
          widget.onImageSelected([pickedFile]);
        }
      } else {
        final pickedFiles = await imagePicker.pickMultiImage(
          maxHeight: widget.maxHeight,
          maxWidth: widget.maxWidth,
          imageQuality: widget.imageQuality,
        );
        _isPickingImage = false;
        if (pickedFiles != null && pickedFiles.isNotEmpty) {
          widget.onImageSelected(pickedFiles);
        }
      }
    } catch (e) {
      _isPickingImage = false;
      rethrow;
    }
  }

  Future<void> _onFilesSelected() async {
    
    FilePickerResult? resultList;
    try {
      if (kIsWeb || await Permission.storage.request().isGranted) {
        resultList = await FilePicker.platform.pickFiles(
          type: widget.type,
          allowedExtensions: widget.allowedExtensions,
          allowCompression: widget.allowCompression,
          onFileLoading: widget.onFileLoading,
          allowMultiple: widget.allowMultiple,
          withData: widget.withData,
          withReadStream: widget.withReadStream,
        );
        if (resultList != null) {
          var files = resultList.files;
          widget.onFileSelected(files);
        }
      } else {
        throw Exception('Storage Permission not granted');
      }
    } on Exception catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget res = Container(
      height: 100,
      width: MediaQuery.of(context).size.width,
      padding: widget.bottomSheetPadding,
      child: SizedBox(
        height: 100,
        child: Wrap(
          alignment: WrapAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () => _onPickImage(ImageSource.camera),
              icon: widget.cameraIcon!,
              label: widget.cameraLabel!,
            ),
            const SizedBox(
              width: 40,
            ),
            ElevatedButton.icon(
              onPressed: () => _onPickImage(ImageSource.gallery),
              icon: widget.galleryIcon!,
              label: widget.galleryLabel!,
            ),
            ElevatedButton.icon(
              onPressed: _onFilesSelected,
              icon: const Icon(Icons.folder),
              label: const Text('Pick from files'),
            ),
          ],
        ),
      ),
    );
    if (widget.preventPop) {
      res = WillPopScope(
        onWillPop: () async => !_isPickingImage,
        child: res,
      );
    }
    return res;
  }
}
