import 'package:flutter/material.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.grey.shade900,
        title: const Text('About GridPic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'GridPic - Image Grid App',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Description:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    'GridPic is a simple image grid app that allows you to overlay a grid with custom settings on your images. You can adjust the grid size, line width, colors, and more to create stunning grid-based images.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'How to Use:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(
                    '1. Tap the "+" button or "Browse Gallery" to select an image from your device\'s gallery or use the camera to take a new photo.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    '2. Once an image is selected, you can crop it using the "Crop" button if needed.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    '3. Adjust the grid settings as desired. You can change the grid color, line width, and toggle the display of numbers on the grid.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    '4. To save the image with the grid, use the "Save" button, which will save the image to your device\'s gallery.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                  Text(
                    '5. You can also share the image directly to WhatsApp using the "Send to WhatsApp" button.',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w200),
                  ),
                ],
              ),
              const SizedBox(
                height: 150,
              ),
              const Center(
                child: Text(
                  'Version: 1.0.0',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              Center(
                child: RichText(
                  text: const TextSpan(
                    text: 'Developer name   ',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w200,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'aj_labs',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
