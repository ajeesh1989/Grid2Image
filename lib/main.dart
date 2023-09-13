import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const GridApp(),
      theme: ThemeData.dark(),
    );
  }
}

class GridApp extends StatefulWidget {
  const GridApp({Key? key}) : super(key: key);

  @override
  _GridAppState createState() => _GridAppState();
}

class _GridAppState extends State<GridApp> {
  int rows = 3;
  int columns = 3;
  Color gridColor = Colors.black;
  bool showNumbers = true;
  double lineWidth = 1.0;
  File? imagePath;
  CroppedFile? _croppedFile;
  bool showGrid = false;
  double gridWidth = 0; // Add this to store the grid width
  double gridHeight = 0; // Add this to store the grid height
  void changeGridColor(Color color) {
    setState(() {
      gridColor = color;
    });
  }

  void toggleShowNumbers() {
    setState(() {
      showNumbers = !showNumbers;
    });
  }

  void increaseLineWidth() {
    setState(() {
      lineWidth += 0.5;
    });
  }

  void decreaseLineWidth() {
    if (lineWidth > 0.5) {
      setState(() {
        lineWidth -= 0.5;
      });
    }
  }

  void increaseRows() {
    setState(() {
      rows++;
      columns++;
    });
  }

  void decreaseRows() {
    if (rows > 1) {
      setState(() {
        rows--;
        columns--;
      });
    }
  }

  void resetImageAndGrid() {
    setState(() {
      imagePath = null;
      showGrid = false; // Hide the grid
    });
  }

  Future<void> pickImage({required ImageSource imageSource}) async {
    final image = await ImagePicker().pickImage(source: imageSource);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        imagePath = file;
        showGrid = true; // Show the grid when an image is selected
      });
      final img = await _cropImage(imagefile: file);

      setState(() {
        imagePath = img;
      });
    }
  }

  Future<void> reCropImage() async {
    if (imagePath != null) {
      final newCroppedImage = await _cropImage(imagefile: imagePath!);
      if (newCroppedImage != null) {
        setState(() {
          imagePath = newCroppedImage;
        });
      }
    }
  }

  Future<File?> _cropImage({required File imagefile}) async {
    if (imagePath != null) {
      final croppedFile = await ImageCropper().cropImage(
        sourcePath: imagefile.path,
        compressFormat: ImageCompressFormat.jpg,
        compressQuality: 100,
        uiSettings: [
          AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.blue,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false,
          ),
          IOSUiSettings(
            title: 'Cropper',
          ),
          WebUiSettings(
            context: context,
            presentStyle: CropperPresentStyle.dialog,
            boundary: const CroppieBoundary(
              width: 520,
              height: 520,
            ),
            viewPort: const CroppieViewPort(
              width: 480,
              height: 480,
              type: 'circle',
            ),
            enableExif: true,
            enableZoom: true,
            showZoomer: true,
          ),
        ],
      );

      if (croppedFile != null) {
        final img = Image.file(File(croppedFile.path));
        img.image.resolve(const ImageConfiguration()).addListener(
          ImageStreamListener((ImageInfo info, bool _) {
            setState(() {
              gridWidth = info.image.width.toDouble();
              gridHeight = info.image.height.toDouble();
              // Calculate the number of rows and columns based on image dimensions
              rows = gridHeight ~/ (gridHeight / rows);
              columns = gridWidth ~/ (gridWidth / columns);
            });
          }),
        );

        return File(croppedFile.path);
      }
    }
    return null;
  }

  void showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
      ),
      builder: (BuildContext context) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(30.0)),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 10),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 8,
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      onTap: () async {
                        await pickImage(imageSource: ImageSource.gallery);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.image),
                          SizedBox(width: 8),
                          Text(
                            'Browse Gallery',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text('OR'),
                const SizedBox(height: 16),
                Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                  elevation: 8,
                  child: SizedBox(
                    height: 50,
                    child: GestureDetector(
                      onTap: () async {
                        await pickImage(imageSource: ImageSource.camera);
                        // ignore: use_build_context_synchronously
                        Navigator.pop(context);
                      },
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt_outlined),
                          SizedBox(width: 8),
                          Text(
                            'Use a Camera',
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        );
      },
    );
  }

  void saveImageToGallery() async {
    if (imagePath != null) {
      final result = await ImageGallerySaver.saveFile(imagePath!.path);
      print('Image saved to gallery: $result');
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image saved to gallery'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void sendImageToWhatsApp() async {
    if (imagePath != null) {
      await Share.shareFiles([imagePath!.path], text: '');
    } else {
      throw 'No image selected';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grid App'),
        actions: <Widget>[
          IconButton(
            onPressed: resetImageAndGrid,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (imagePath != null)
                  Image.file(
                    imagePath!,
                    fit: BoxFit.cover,
                  ),
                if (showGrid)
                  GridView.builder(
                    itemCount: rows * columns,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                    ),
                    itemBuilder: (context, index) {
                      final number = showNumbers ? (index + 1).toString() : '';
                      return Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: gridColor,
                            width: lineWidth,
                          ),
                        ),
                        child: Center(
                          child: Text(number),
                        ),
                      );
                    },
                  ),
                if (imagePath == null &&
                    !showGrid) // Display message when nothing is selected
                  Container(
                    width: 80, // Adjust the width as needed
                    height: 80, // Adjust the height as needed
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey.shade800, // Background color
                    ),
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          showImageSourceSelection();
                        },
                        icon: const Icon(
                          Icons.add,
                          size: 30, // Adjust the size as needed
                          color: Colors.white, // Icon color
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                Container(
                  color: Colors.blue.shade100,
                  child: Column(
                    children: [
                      const SizedBox(
                        height: 5,
                      ),
                      const Text(
                        'Rows',
                        style: TextStyle(color: Colors.black),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: increaseRows,
                            icon: const Icon(Icons.add, color: Colors.black),
                          ),
                          IconButton(
                            onPressed: decreaseRows,
                            icon:
                                const Icon(Icons.minimize, color: Colors.black),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Pick a Color'),
                          content: SingleChildScrollView(
                            child: ColorPicker(
                              pickerColor: gridColor,
                              onColorChanged: changeGridColor,
                              // ignore: deprecated_member_use
                              showLabel: true,
                              pickerAreaHeightPercent: 0.8,
                            ),
                          ),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade100,
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  ),
                  child: const Text(
                    'Change Color',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: toggleShowNumbers,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                child: Text(showNumbers ? 'Hide Numbers' : 'Show Numbers'),
              ),
              ElevatedButton(
                onPressed: increaseLineWidth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                child: const Text('Inc Line Width'),
              ),
              ElevatedButton(
                onPressed: decreaseLineWidth,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                ),
                child: const Text('Dec Line Width'),
              ),
            ],
          ),
          const SizedBox(
            height: 10,
          ),
          if (imagePath != null)
            Column(
              children: [
                Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      sendImageToWhatsApp();
                    },
                    child: const Center(
                      child: Text('Sent to WhatsApp'),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      saveImageToGallery();
                    },
                    child: const Center(
                      child: Text('Save to Gallery'),
                    ),
                  ),
                ),
                Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.black,
                      width: 1,
                    ),
                  ),
                  child: TextButton(
                    onPressed: () {
                      reCropImage();
                    },
                    child: const Center(
                      child: Text('Re-Crop Image'),
                    ),
                  ),
                ),
              ],
            ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
