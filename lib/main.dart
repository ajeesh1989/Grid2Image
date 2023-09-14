// ignore_for_file: depend_on_referenced_packages, library_private_types_in_public_api, use_build_context_synchronously

import 'dart:typed_data';
import 'package:grid_1/box.dart';
import 'package:grid_1/info.dart';
import 'package:path_provider/path_provider.dart';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:io';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:screenshot/screenshot.dart';

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
  int currentRows = 3;
  int currentColumns = 3;
  Color gridColor = Colors.black;
  bool showNumbers = true;
  double lineWidth = 1.0;
  File? imagePath;
  CroppedFile? _croppedFile;
  bool showGrid = false;
  double gridWidth = 0;
  double gridHeight = 0;
  final ScreenshotController screenshotController =
      ScreenshotController(); // Add this line
  Color numberColor = Colors.white; // Added color for numbers
  bool isGridVisible = true;

  void changeGridColor(Color color) {
    setState(() {
      gridColor = color;
    });
  }

  void changeNumberColor(Color color) {
    setState(() {
      numberColor = color; // Update the number color
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
      currentRows++;
      currentColumns++;
    });
  }

  void decreaseRows() {
    if (currentRows > 1) {
      setState(() {
        currentRows--;
        currentColumns--;
      });
    }
  }

  void resetImageAndGrid() {
    setState(() {
      imagePath = null;
      showGrid = false;
    });
  }

  Future<void> pickImage({required ImageSource imageSource}) async {
    final image = await ImagePicker().pickImage(source: imageSource);
    if (image != null) {
      final file = File(image.path);
      setState(() {
        imagePath = file;
        showGrid = true;
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
              currentRows = gridHeight ~/ (gridHeight / currentRows);
              currentColumns = gridWidth ~/ (gridWidth / currentColumns);
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
            color: Colors.grey.shade900,
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

  void sendImageToWhatsApp() async {
    if (imagePath != null) {
      try {
        final image = await screenshotController.capture();
        if (image != null) {
          // Get the temporary directory
          final tempDir = await getTemporaryDirectory();
          final tempFile = File('${tempDir.path}/temp_image.png');

          // Save the captured image to a temporary file
          await tempFile.writeAsBytes(Uint8List.fromList(image));

          // Share the temporary file
          // ignore: deprecated_member_use
          await Share.shareFiles([tempFile.path],
              text: 'Check out this image made with GridPic');
        } else {
          print('Error: Captured image is null');
        }
      } catch (e) {
        print('Error sending image to WhatsApp: $e');
      }
    } else {
      print('No image selected');
    }
  }

  void saveImageWithGrid() async {
    try {
      final image = await screenshotController.capture();
      if (image != null) {
        final result =
            await ImageGallerySaver.saveImage(Uint8List.fromList(image));
        if (result != null && result.isNotEmpty) {
          print('Image with grid saved to gallery: $result');

          // ignore: use_build_context_synchronously
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Image with grid saved to gallery'),
              duration: Duration(seconds: 3),
            ),
          );
        } else {
          print('Error: Unable to save image to gallery');
        }
      } else {
        print('Error: Captured image is null');
      }
    } catch (e) {
      print('Error saving image with grid: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 26, 25, 25),
        title: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            'GridPic',
            style: TextStyle(color: Colors.grey.shade400),
          ),
        ),
        actions: <Widget>[
          IconButton(
            onPressed: resetImageAndGrid,
            icon: Icon(Icons.refresh, color: Colors.grey.shade400),
          ),
          const SizedBox(
            width: 5,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          Expanded(
            child: Screenshot(
              controller: screenshotController,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Render the image
                  if (imagePath != null)
                    Image.file(
                      imagePath!,
                      fit: BoxFit.cover,
                    ),

                  // Render the grid conditionally
                  if (isGridVisible)
                    GridView.builder(
                      itemCount: currentRows * currentColumns,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: currentColumns,
                      ),
                      itemBuilder: (context, index) {
                        final row = index ~/ currentColumns + 1;
                        final column = index % currentColumns + 1;
                        String text = '';
                        if (showNumbers) {
                          if (row == 1 || column == 1) {
                            if (row == 1 && column == 1) {
                              text = '$column';
                            } else if (row == 1) {
                              text = '$column';
                            } else {
                              text = '$row';
                            }
                          }
                        }
                        return Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: gridColor,
                              width: lineWidth,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              text,
                              style: TextStyle(
                                fontSize: 16,
                                color: numberColor,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  if (imagePath == null && !showGrid)
                    GestureDetector(
                      onTap: () {
                        showImageSourceSelection();
                      },
                      child: Container(
                        color: Colors.grey.shade900,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Center(
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey.shade800,
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    showImageSourceSelection();
                                  },
                                  icon: Icon(
                                    Icons.add,
                                    size: 40,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Text(
                              'Tap anywhere to add photo',
                              style: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 15,
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (imagePath != null)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 23,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Column(
                            children: [
                              const Text(
                                'Grid',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Box(
                                    child: IconButton(
                                      onPressed: decreaseRows,
                                      icon: const Icon(Icons.remove,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Box(
                                    child: IconButton(
                                      onPressed: increaseRows,
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          Column(
                            children: [
                              const Text(
                                'Line width',
                                style: TextStyle(
                                    color: Colors.white, fontSize: 16),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  const SizedBox(width: 10),
                                  Box(
                                    child: IconButton(
                                      onPressed: decreaseLineWidth,
                                      icon: const Icon(Icons.remove,
                                          color: Colors.white),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Box(
                                    child: IconButton(
                                      onPressed: increaseLineWidth,
                                      icon: const Icon(Icons.add,
                                          color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 15),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
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
                              backgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                              ),
                            ),
                            child: const Text(
                              'Grid Color',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                          const SizedBox(
                            width: 5,
                          ),
                          ElevatedButton(
                            onPressed: toggleShowNumbers,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                              ),
                            ),
                            child: Text(
                              showNumbers ? 'Hide Numbers' : 'Show Numbers',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return AlertDialog(
                                    title: const Text('Pick a Color'),
                                    content: SingleChildScrollView(
                                      child: ColorPicker(
                                        pickerColor: numberColor,
                                        onColorChanged: changeNumberColor,
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
                              backgroundColor: Colors.grey.shade800,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 8.0,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    10.0), // Adjust the radius as needed
                              ),
                            ),
                            child: const Text(
                              'Num Color',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (imagePath != null)
                      const SizedBox(
                        height: 30,
                      ),
                    if (imagePath != null)
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      reCropImage();
                                    },
                                    icon: const Icon(Icons.crop,
                                        size: 30), // Icon for re-cropping
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      saveImageWithGrid();
                                    },
                                    icon: const Icon(Icons.arrow_downward,
                                        size: 30), // Icon for saving to gallery
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      sendImageToWhatsApp();
                                    },
                                    icon: const Icon(Icons.send,
                                        size:
                                            30), // Icon for sending to WhatsApp
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        isGridVisible = !isGridVisible;
                                      });
                                    },
                                    icon: Icon(
                                      isGridVisible
                                          ? Icons.grid_on
                                          : Icons.grid_off,
                                      size: 30,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.shade800,
                                      width: 1,
                                    ),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (context) => const AboutPage(),
                                      ));
                                    },
                                    icon: const Icon(Icons.info_outline,
                                        size:
                                            30), // Icon for sending to WhatsApp
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
