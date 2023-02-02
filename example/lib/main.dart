import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_file_picker/form_builder_file_picker.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _useCustomFileViewer = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FormBuilder FilePicker Example'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            children: <Widget>[
              FormBuilderFilePicker(
                name: 'images',
                decoration:
                    const InputDecoration(labelText: 'Multi Attachments'),
                maxFiles: null,
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: const ['jpg', 'png', 'pdf'],
                previewImages: true,
                showImagePickerOnImageExtensions: true,
                withData: false,
                withReadStream: false,
                onChanged: (val) => debugPrint(val.toString()),
                selector: Row(
                  children: const <Widget>[
                    Icon(Icons.file_upload),
                    Text('Upload'),
                  ],
                ),
                onFileLoading: (val) {
                  debugPrint(val.toString());
                },
                customFileViewerBuilder:
                    _useCustomFileViewer ? customFileViewerBuilder : null,
              ),
              const SizedBox(height: 20),
              FormBuilderFilePicker(
                name: 'images_maxfiles',
                decoration: const InputDecoration(
                    labelText: 'Attachments with max files'),
                maxFiles: 4,
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: const ['jpg', 'png'],
                previewImages: true,
                showImagePickerOnImageExtensions: true,
                withData: false,
                withReadStream: false,
                onChanged: (val) => debugPrint(val.toString()),
                selector: Row(
                  children: const <Widget>[
                    Icon(Icons.file_upload),
                    Text('Upload'),
                  ],
                ),
                onFileLoading: (val) {
                  debugPrint(val.toString());
                },
                customFileViewerBuilder:
                    _useCustomFileViewer ? customFileViewerBuilder : null,
              ),
              FormBuilderFilePicker(
                name: 'photo',
                decoration:
                    const InputDecoration(labelText: 'Multi Attachments'),
                maxFiles: 1,
                allowMultiple: false,
                type: FileType.custom,
                allowedExtensions: const [
                  'jpg',
                  'png',
                ],
                previewImages: true,
                showImagePickerOnImageExtensions: true,
                withData: false,
                withReadStream: false,
                onChanged: (val) => debugPrint(val.toString()),
                onFieldClicked: (field) async {
                  return null;
                
                 
                },
                selector: Row(
                  children: const <Widget>[
                    Icon(Icons.file_upload),
                    Text('Upload'),
                  ],
                ),
                onFileLoading: (val) {
                  debugPrint(val.toString());
                },
                customFileViewerBuilder:
                    _useCustomFileViewer ? customFileViewerBuilder : null,
              ),
              FormBuilderFilePicker(
                name: 'docs',
                decoration:
                    const InputDecoration(labelText: 'DOCS'),
                maxFiles: 5,
                allowDocScan: true,
                allowMultiple: true,
                type: FileType.custom,
                allowedExtensions: const ['jpg', 'png', 'pdf'],
                previewImages: true,
                
                showImagePickerOnImageExtensions: true,
                withData: false,
                withReadStream: false,
                onChanged: (val) => debugPrint(val.toString()),
                selector: Row(
                  children: const <Widget>[
                    Icon(Icons.file_upload),
                    Text('Upload'),
                  ],
                ),
                onFileLoading: (val) {
                  debugPrint(val.toString());
                },
                customFileViewerBuilder:
                    _useCustomFileViewer ? customFileViewerBuilder : null,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    child: const Text('Submit'),
                    onPressed: () {
                      _formKey.currentState!.save();
                      debugPrint(_formKey.currentState!.value.toString());
                    },
                  ),
                  const Spacer(),
                  ElevatedButton(
                    child: Text(_useCustomFileViewer
                        ? 'Use Default File Viewer'
                        : 'Use Custom File Viewer'),
                    onPressed: () {
                      setState(
                          () => _useCustomFileViewer = !_useCustomFileViewer);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customFileViewerBuilder(
    List<PlatformFile>? files,
    FormFieldSetter<List<PlatformFile>> setter,
  ) {
    return ListView.separated(
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final file = files![index];
        return ListTile(
          title: Text(file.name),
          trailing: IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () {
              files.removeAt(index);
              setter.call([...files]);
            },
          ),
        );
      },
      separatorBuilder: (context, index) => const Divider(
        color: Colors.blueAccent,
      ),
      itemCount: files!.length,
    );
  }
}
