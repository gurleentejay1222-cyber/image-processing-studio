import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:file_saver/file_saver.dart';

void main() {
  runApp(const ImageStudioApp());
}

class ImageStudioApp extends StatelessWidget {
  const ImageStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Image Processing Studio',
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  Uint8List? imageBytes;
  Uint8List? originalBytes;

  final ImagePicker picker = ImagePicker();

  Future pickImage() async {

    final XFile? image =
        await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {

      final bytes = await image.readAsBytes();

      setState(() {

        imageBytes = bytes;
        originalBytes = bytes;

      });

    }
  }

  void applyGrayFilter() {

    if (imageBytes == null) return;

    img.Image? originalImage =
        img.decodeImage(imageBytes!);

    if (originalImage == null) return;

    img.Image grayImage =
        img.grayscale(originalImage);

    Uint8List grayBytes =
        Uint8List.fromList(img.encodeJpg(grayImage));

    setState(() {

      imageBytes = grayBytes;

    });
  }
  void applyNegativeFilter() {

  if (imageBytes == null) return;

  img.Image? originalImage =
      img.decodeImage(imageBytes!);

  if (originalImage == null) return;

  for (int y = 0; y < originalImage.height; y++) {

    for (int x = 0; x < originalImage.width; x++) {

      final pixel = originalImage.getPixel(x, y);

      int r = 255 - pixel.r.toInt();
      int g = 255 - pixel.g.toInt();
      int b = 255 - pixel.b.toInt();

      originalImage.setPixelRgba(
        x,
        y,
        r,
        g,
        b,
        pixel.a.toInt(),
      );
    }
  }

  Uint8List negativeBytes =
      Uint8List.fromList(img.encodeJpg(originalImage));

  setState(() {

    imageBytes = negativeBytes;

  });
}
void resetImage() {

  if (originalBytes == null) return;

  setState(() {

    imageBytes = originalBytes;

  });
}
void applyBlurFilter() {

  if (imageBytes == null) return;

  img.Image? originalImage =
      img.decodeImage(imageBytes!);

  if (originalImage == null) return;

  img.Image blurredImage =
      img.gaussianBlur(originalImage, radius: 10);

  Uint8List blurBytes =
      Uint8List.fromList(img.encodeJpg(blurredImage));

  setState(() {

    imageBytes = blurBytes;

  });
}
Future<void> saveImage() async {

  if (imageBytes == null) return;

  await FileSaver.instance.saveFile(
    name: "edited_image",
    bytes: imageBytes!,
    
    mimeType: MimeType.other,
  );

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text("Image Saved Successfully"),
    ),
  );
}

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Image Processing Studio"),
        centerTitle: true,
      ),

      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Container(
            height: 300,
            width: 300,
            margin: const EdgeInsets.all(20),

            decoration: BoxDecoration(
              border: Border.all(color: Colors.white),
              borderRadius: BorderRadius.circular(20),
            ),

            child: imageBytes != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.memory(
                      imageBytes!,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Center(
                    child: Text(
                      "Image Preview",
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
          ),

          ElevatedButton(
            onPressed: pickImage,
            child: const Text("Upload Image"),
          ),

          const SizedBox(height: 30),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              ElevatedButton(
                onPressed: applyGrayFilter,
                child: const Text("Gray"),
              ),

              ElevatedButton(
                onPressed: applyNegativeFilter,
                child: const Text("Negative"),
              ),
              ElevatedButton(
                onPressed: applyBlurFilter,
                child: const Text("Blur"),
              ),

              ElevatedButton(
                onPressed: resetImage,
                child: const Text("Reset"),
              ),
              ElevatedButton(
                onPressed: saveImage,
                child: const Text("Save"),
              ),

            ],
          ),

        ],
      ),
    );
  }
}

