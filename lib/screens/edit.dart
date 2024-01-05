import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:notes_app/screens/VideoThumbnailWidget.dart';
import 'package:notes_app/models/note.dart';
import 'package:video_player/video_player.dart';

DateTime Date = DateTime.now();

class EditPage extends StatefulWidget {
  final Note? note;
  EditPage({super.key, this.note});
  final picker = ImagePicker();
  final videoPlayerController = VideoPlayerController.file(File(""));

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  TextEditingController _titleController = TextEditingController();
  TextEditingController _contentController = TextEditingController();
  String category = "Trivial";
  List<String> imagePaths = [];
  List<String> videoPaths = [];

  @override
  void initState() {
    if (widget.note != null) {
      _titleController = TextEditingController(text: widget.note!.title);
      _contentController = TextEditingController(text: widget.note!.content);
      category = widget.note!.category;
      imagePaths = List.from(widget.note!.imagePaths);
      videoPaths = List.from(widget.note!.videoPaths);
    }
    super.initState();
  }

  void _showRemoveImageDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Image'),
          content: const Text('Do you want to remove this image?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  imagePaths.removeAt(index); // Remove the image path
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  VoidCallback _createRemoveVideoDialog(BuildContext context, int index) {
    return () {
      _showRemoveVideoDialog(context, index);
    };
  }

  void _showRemoveVideoDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Remove Video'),
          content: Text('Do you want to remove this video?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  videoPaths.removeAt(index);
                  videoPaths = videoPaths; // Remove the video path
                });
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      appBar: AppBar(
        backgroundColor: Colors.grey[900],
        actions: [
          IconButton(
            icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.add_a_photo,
                  color: Colors.white,
                )),
            onPressed: () async {
              if (imagePaths.length >= 6) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Image limit exceeded'),
                        content:
                            const Text('You can add upto 6 images in a note'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              } else {
                final pickedFile =
                    await widget.picker.pickImage(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    imagePaths.add(pickedFile.path);
                  });
                }
              }
            },
          ),
          IconButton(
            icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.video_file,
                  color: Colors.white,
                )),
            onPressed: () async {
              if (videoPaths.length >= 4) {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Video limit exceeded'),
                        content:
                            const Text('You can add upto 4 videos in a note'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context); // Close the dialog
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    });
              } else {
                final pickedFile =
                    await widget.picker.pickVideo(source: ImageSource.gallery);
                if (pickedFile != null) {
                  setState(() {
                    videoPaths.add(pickedFile.path);
                  });
                }
              }
            },
          ),
        ],
        title: const Text(
          "Notes",
          style: TextStyle(fontFamily: 'Archivo', color: Colors.white),
        ),
        leading: IconButton(
            onPressed: () {
              imagePaths = List.from(widget.note?.imagePaths ?? []);
              Navigator.pop(context);
            },
            icon: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                ))),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 25, left: 5, right: 20, bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: ListView(
              padding: const EdgeInsets.only(left: 10),
              children: [
                TextField(
                  controller: _titleController,
                  style: const TextStyle(fontFamily: 'Archivo',color: Colors.white, fontSize: 45),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Title',
                    hintStyle: TextStyle(
                        fontFamily: 'Archivo',
                        color: Colors.grey,
                        fontSize: 45),
                  ),
                ),
                DropdownButtonFormField<String>(
                  value: category,
                  dropdownColor: Colors.grey.shade900,
                  icon: const Icon(Icons.arrow_drop_down_circle_rounded,
                      color: Colors.white),
                  style: const TextStyle(color: Colors.white),
                  onChanged: (String? val) {
                    setState(() {
                      category = val!;
                    });
                  },
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                      prefixIcon: Icon(
                        Icons.category_rounded,
                        color: Colors.white,
                      ),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.white)),
                      labelText: "Importance Category",
                      labelStyle:
                          TextStyle(fontFamily: 'PTSans', fontSize: 16, color: Colors.grey)),
                  items: const [
                    DropdownMenuItem<String>(
                      value: 'Critical',
                      child: Text(
                        'Critical',
                        style:
                            TextStyle(fontFamily: 'PTSans',fontSize: 20, color: Color.fromARGB(255, 226, 124, 131)),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Essential',
                      child: Text(
                        'Essential',
                        style: TextStyle(fontFamily: 'PTSans',fontSize: 20, color: Color.fromARGB(255, 240, 158, 158)),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Relevant',
                      child: Text(
                        'Relevant',
                        style: TextStyle(fontFamily: 'PTSans',fontSize: 20, color: Color.fromARGB(255, 245, 183, 193)),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Routine',
                      child: Text(
                        'Routine',
                        style: TextStyle(fontFamily: 'PTSans',fontSize: 20, color: Color.fromRGBO(174, 214, 232, 1)),
                      ),
                    ),
                    DropdownMenuItem<String>(
                      value: 'Trivial',
                      child: Text(
                        'Trivial',
                        style: TextStyle(fontFamily: 'PTSans',fontSize: 20, color: Color.fromARGB(255, 98, 173, 211)),
                      ),
                    ),
                  ],
                ),
                TextField(
                  maxLines: null,
                  controller: _contentController,
                  style: const TextStyle(fontFamily: 'PTSans',fontWeight: FontWeight.bold,color: Colors.white, fontSize: 20),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Type something',
                    hintStyle: TextStyle(fontFamily: 'PTSans',fontWeight: FontWeight.bold,color: Colors.grey, fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    for (int index = 0; index < imagePaths.length; index++)
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ImageDisplayScreen(
                                  imagePath: imagePaths[index]),
                            ),
                          );
                        },
                        onLongPress: () {
                          _showRemoveImageDialog(context, index);
                        },
                        child: Container(
                          margin: const EdgeInsets.only(
                              right: 8.0), // Optional spacing between images
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: FileImage(File(imagePaths[index])),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(
                  height: 40,
                ),
                Row(
                  children: [
                    for (int index = 0; index < videoPaths.length; index++)
                      GestureDetector(
                        onTap: () {
                          VideoThumbnailWidget(videoPath: videoPaths[index]);
                        },
                        onLongPress: _createRemoveVideoDialog(context, index),
                        child:
                            VideoThumbnailWidget(videoPath: videoPaths[index]),
                      ),
                  ],
                ),
              ],
            ))
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pop(context, [
            _titleController.text,
            _contentController.text,
            category,
            imagePaths,
            videoPaths
          ]);
        },
        elevation: 10,
        backgroundColor: Colors.grey[800],
        child: const Icon(
          Icons.save,
          color: Colors.white,
        ),
      ),
    );
  }
}

class ImageDisplayScreen extends StatelessWidget {
  final String imagePath;

  ImageDisplayScreen({required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade900,
      body: Center(
        child: Image.file(File(imagePath)),
      ),
    );
  }
}
