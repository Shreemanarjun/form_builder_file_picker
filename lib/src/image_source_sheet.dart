import 'package:document_scanner_flutter/configs/configs.dart';
import 'package:document_scanner_flutter/document_scanner_flutter.dart';
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

  /// Callback when images is selected.
  final void Function(Iterable<XFile> docFiles) onDocSelected;
  // Callback when files are selected.
  final void Function(List<PlatformFile> files) onFileSelected;

  final Widget bottomSheetHeader;
  final Widget cameraIcon;
  final Widget galleryIcon;
  final Widget cameraLabel;
  final Widget galleryLabel;
  final Widget docCameraIcon;
  final Widget docCameraLabel;
  final Widget docGalleryIcon;
  final Widget docGalleryLabel;
  final Widget fileIcon;
  final Widget fileLabel;
  final EdgeInsets? bottomSheetPadding;
  final bool preventPop;

  final FileType type;
  final List<String>? allowedExtensions;
  final Function(FilePickerStatus)? onFileLoading;
  final bool allowCompression;
  final bool allowMultiple;
  final bool withData;
  final bool withReadStream;
  final bool allowDocScan;

  const ImageSourceBottomSheet({
    Key? key,
    this.remainingImages,
    this.preventPop = false,
    this.maxHeight,
    this.maxWidth,
    this.imageQuality,
    this.preferredCameraDevice = CameraDevice.rear,
    required this.onImageSelected,
    this.cameraIcon = const Icon(Icons.camera_enhance),
    this.cameraLabel = const Text('Camera'),
    this.galleryIcon = const Icon(Icons.image),
    this.galleryLabel = const Text('Gallery'),
    this.fileIcon = const Icon(Icons.folder),
    this.fileLabel = const Text('Pick from files'),
    this.docCameraIcon=const Icon(Icons.document_scanner),
    this.docCameraLabel=const Text("Camera Scanner"),
    this.docGalleryIcon=const Icon(Icons.image),
    this.docGalleryLabel=const Text("Gallery"),
    this.bottomSheetPadding,
    this.type = FileType.any,
    this.allowedExtensions,
    this.onFileLoading,
    this.allowCompression = true,
    this.allowMultiple = false,
    this.withData = false,
    this.withReadStream = false,
    required this.onFileSelected,
    this.bottomSheetHeader = const Padding(
      padding: EdgeInsets.all(8.0),
      child: Text("Select Files From "),
    ),
    required this.onDocSelected, required this.allowDocScan,
  }) : super(key: key);

  @override
  State<ImageSourceBottomSheet> createState() => _ImageSourceBottomSheetState();
}

class _ImageSourceBottomSheetState extends State<ImageSourceBottomSheet> {
  bool _isPickingImage = false;

  Future<void> _docScan(
      {required BuildContext context,
      required ScannerFileSource source}) async {
    final image = await DocumentScannerFlutter.launch(context, source: source);
    try {
      if (image != null) {
        final imageXfile = XFile(image.path,
            bytes: image.readAsBytesSync(),
            length: image.lengthSync(),
            lastModified: image.lastModifiedSync());
        widget.onDocSelected([imageXfile]);
      }
    } catch (e) {
      rethrow;
    }
  }

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
        if (pickedFiles.isNotEmpty) {
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
      height: MediaQuery.of(context).size.height * 0.2,
      width: MediaQuery.of(context).size.width,
      padding: widget.bottomSheetPadding,
      child: Column(
        children: [
          widget.bottomSheetHeader,
          Wrap(
            alignment: WrapAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: () => _onPickImage(ImageSource.camera),
                icon: widget.cameraIcon,
                label: widget.cameraLabel,
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton.icon(
                onPressed: () => _onPickImage(ImageSource.gallery),
                icon: widget.galleryIcon,
                label: widget.galleryLabel,
              ),
              const SizedBox(
                width: 8,
              ),
              ElevatedButton.icon(
                onPressed: _onFilesSelected,
                icon: widget.fileIcon,
                label: widget.fileLabel,
              ),
               const SizedBox(
                width: 8,
              ),
          if(widget.allowDocScan
            )  ...[
               ElevatedButton.icon(
                onPressed: () => _docScan(context: context, source: ScannerFileSource.CAMERA),
                icon: widget.docCameraIcon,
                label: widget.docCameraLabel,
              ),
                const SizedBox(
                width: 8,
              ),
               ElevatedButton.icon(
                onPressed: () => _docScan(context: context, source: ScannerFileSource.GALLERY),
                icon: widget.docGalleryIcon,
                label: widget.docGalleryLabel,
              ),
            ]
            ],
          ),
        ],
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
