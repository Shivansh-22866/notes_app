import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mime/mime.dart';
import 'package:notes_app/constants/colors.dart';
import 'package:notes_app/models/note.dart';
import 'package:notes_app/screens/FadePageRoute.dart';
import 'package:notes_app/screens/edit.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<Note> filteredNotes = [];
  bool sorted = false;

  @override
  void initState() {
    super.initState();
    loadNotes().then((loadedNotes) {
      setState(() {
        sampleNotes = loadedNotes.isNotEmpty ? loadedNotes : [];
        filteredNotes = List.from(sampleNotes); // Create a copy
      });
    });
  }

  Future<List<Note>> loadNotes() async {
    final prefs = await SharedPreferences.getInstance();
    final List<String>? notesJson = prefs.getStringList('notes');

    if (notesJson == null) {
      // If no notes are found in SharedPreferences, return an empty list
      return [];
    }

    return notesJson.map((json) => Note.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> notesJson =
        notes.map((note) => jsonEncode(note.toJson())).toList();
    await prefs.setStringList('notes', notesJson);
  }

  Future<void> shareNote(Note note, String format) async {
    late String filePath;
    late String mimeType;

    if (format == 'txt') {
      filePath = await _saveNoteAsTxt(note);
      mimeType = 'text/plain';
    } else if (format == 'docx') {
      filePath = await _saveNoteAsHtml(note);
      mimeType = 'text/html';
    } else if (format == 'pdf') {
      filePath = await _saveNoteAsPdf(note);
      mimeType = 'application/pdf';
    } else {
      return; // Unsupported format
    }

    Share.shareFiles([filePath],
        text: 'Sharing ${note.title}', mimeTypes: [mimeType]);
  }

  Future<String> _saveNoteAsPdf(Note note) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(note.title,
                  style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold, fontSize: 18)),
              pw.SizedBox(height: 10),
              pw.Text(note.content, style: const pw.TextStyle(fontSize: 14)),
              pw.SizedBox(height: 10),
              if (note.imagePaths.isNotEmpty) ...{
                pw.Column(
                  children: [
                    for (var i = 0; i < note.imagePaths.length; i += 3)
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.start,
                        crossAxisAlignment: pw.CrossAxisAlignment.center,
                        children: [
                          for (var j = i;
                              j < i + 3 && j < note.imagePaths.length;
                              j++)
                            pw.Container(
                              margin: const pw.EdgeInsets.only(right: 10),
                              child: pw.Image(
                                  pw.MemoryImage(File(note.imagePaths[j])
                                      .readAsBytesSync()),
                                  width: 100),
                            ),
                        ],
                      ),
                  ],
                ),
              }
            ],
          );
        },
      ),
    );

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${note.title}.pdf';
    final outputFile = File(filePath);

    await outputFile.writeAsBytes(await pdf.save());

    return filePath;
  }

  Future<String> _saveNoteAsHtml(Note note) async {
    final StringBuffer htmlContent = StringBuffer();

    htmlContent.write('<html><body>');
    htmlContent.write('<h1>${note.title}</h1>');

    // Replace newlines with HTML line breaks
    htmlContent.write('<p>${note.content.replaceAll('\n', '<br>')}</p>');

    if (note.imagePaths.isNotEmpty) {
      htmlContent.write('<h2>Images:</h2>');
      htmlContent.write('<div style="display: flex; flex-wrap: wrap;">');

      // Add images
      for (var imagePath in note.imagePaths) {
        final imageData = File(imagePath).readAsBytesSync();
        final mimeType = lookupMimeType(imagePath);
        final base64Image = base64Encode(imageData);
        final imageSrc = 'data:$mimeType;base64,$base64Image';

        // Adjust style to create a grid with 3 items per row
        htmlContent.write(
            '<div style="width: 30%; padding: 10px; box-sizing: border-box;">');
        htmlContent.write(
            '<img src="$imageSrc" style="width: 100%; height: auto; display: block;"/>');
        htmlContent.write('</div>');
      }

      htmlContent.write('</div>');

      if (note.videoPaths.isNotEmpty) {
        htmlContent.write('<h2>Videos:</h2>');
        htmlContent.write('<div style="display: flex; flex-wrap: wrap;">');
        // Add videos
        for (var videoPath in note.videoPaths) {
          final videoData = File(videoPath).readAsBytesSync();
          final videoMimeType = lookupMimeType(videoPath);
          final base64Video = base64Encode(videoData);

          // Adjust style to create a grid with 3 items per row
          htmlContent.write(
              '<div style="width: 40%; padding: 10px; box-sizing: border-box;">');
          htmlContent.write('<video width="100%" height="auto" controls>');
          htmlContent.write(
              '<source src="data:$videoMimeType;base64,$base64Video" type="video/mp4">');
          htmlContent.write('Your browser does not support the video tag.');
          htmlContent.write('</video>');
          htmlContent.write('</div>');
        }
      }

      htmlContent.write('</div>');
    }

    htmlContent.write('</body></html>');

    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${note.title}.html';
    final outputFile = File(filePath);

    await outputFile.writeAsString(htmlContent.toString());

    return filePath;
  }

  Future<String> _saveNoteAsTxt(Note note) async {
    final directory = await getTemporaryDirectory();
    final filePath = '${directory.path}/${note.title}.txt';

    final file = File(filePath);
    await file.writeAsString('${note.title}\n\n${note.content}');

    return filePath;
  }

  List<Note> sortedNotesByModifiedTime(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) => a.modifiedTime.compareTo(b.modifiedTime));
    } else {
      notes.sort((b, a) => a.modifiedTime.compareTo(b.modifiedTime));
    }

    sorted = !sorted;

    return notes;
  }

  List<Note> sortedNotesByCategory(List<Note> notes) {
    if (sorted) {
      notes.sort((a, b) =>
          categoryMap[a.category]!.compareTo(categoryMap[b.category]!));
    } else {
      notes.sort((b, a) =>
          categoryMap[a.category]!.compareTo(categoryMap[b.category]!));
    }

    sorted = !sorted;

    return notes;
  }

  getRandom(int index) {
    int color = categoryMap[filteredNotes[index].category]!;
    return backgroundColors[color];
  }

  void onSearchTextChanged(String searchText) {
    setState(() {
      filteredNotes = sampleNotes
          .where((note) =>
              note.content.toLowerCase().contains(searchText.toLowerCase()) ||
              note.title.toLowerCase().contains(searchText.toLowerCase()))
          .toList();
    });
  }

  void deleteNote(int index) {
    setState(() {
      Note note = filteredNotes[index];
      sampleNotes.remove(note);
      saveNotes(sampleNotes);
      filteredNotes = List.from(sampleNotes);
      loadNotes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Padding(
          padding: const EdgeInsets.all(25),
          child: Column(children: [
            const SizedBox(
              height: 12,
            ),
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              const Text("Notes App",
                  style: TextStyle(
                      fontFamily: 'Archivo',
                      fontSize: 30,
                      color: Colors.white)),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      setState(() {
                        filteredNotes = sortedNotesByModifiedTime(filteredNotes);
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.sort,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        filteredNotes = sortedNotesByCategory(filteredNotes);
                      });
                    },
                    padding: const EdgeInsets.all(0),
                    icon: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(.8),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Icon(
                        Icons.category,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ]),
            const SizedBox(
              height: 12,
            ),
            TextField(
              onChanged: onSearchTextChanged,
              style: const TextStyle(
                fontFamily: 'Archivo',
                fontSize: 16,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                  hintText: "Search...",
                  hintStyle: const TextStyle(
                      fontFamily: 'Archivo', color: Colors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                  ),
                  fillColor: Colors.grey[800],
                  filled: true,
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: const BorderSide(color: Colors.transparent),
                  )),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
                child: ListView.builder(
              itemCount: filteredNotes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: getRandom(index),
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  margin: const EdgeInsets.only(bottom: 20),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      onTap: () async {
                        final result = await Navigator.push(
                            context,
                            FadePageRoute(
                                builder: (BuildContext context) =>
                                    EditPage(note: filteredNotes[index])));
                        if (result != null) {
                          setState(() {
                            int ind = sampleNotes.indexOf(filteredNotes[index]);
                            sampleNotes[ind] = Note(
                                id: sampleNotes[ind].id,
                                title: result[0],
                                content: result[1],
                                modifiedTime: DateTime.now(),
                                category: result[2],
                                imagePaths: result[3],
                                videoPaths: result[4]);
                            filteredNotes[index] = Note(
                              id: filteredNotes[index].id,
                              title: result[0],
                              content: result[1],
                              modifiedTime: DateTime.now(),
                              category: result[2],
                              imagePaths: result[3],
                              videoPaths: result[4],
                            );
                            saveNotes(sampleNotes);
                            loadNotes();
                            filteredNotes = sampleNotes;
                          });
                        }
                      },
                      title: RichText(
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          text: TextSpan(
                              text: "${filteredNotes[index].title} \n",
                              style: const TextStyle(
                                fontFamily: 'PTSans',
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                height: 1.5,
                              ),
                              children: [
                                TextSpan(
                                    text: filteredNotes[index].content,
                                    style: TextStyle(
                                      fontFamily: 'PTSans',
                                      color: Colors.grey[900],
                                      fontWeight: FontWeight.normal,
                                      fontSize: 14,
                                      height: 1.5,
                                    ))
                              ])),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                            '${DateFormat('EEE MMM d, yyyy h:mm a').format(filteredNotes[index].modifiedTime)}\n${filteredNotes[index].category}',
                            style: TextStyle(
                                fontFamily: 'PTSans',
                                fontSize: 10,
                                fontStyle: FontStyle.italic,
                                color: Colors.grey[800])),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          IconButton(
                              onPressed: () async {
                                final result = await confirmDialog(context);
                                if (result != null && result) {
                                  deleteNote(index);
                                }
                              },
                              icon: const Icon(
                                Icons.delete,
                              )),
                          IconButton(
                            onPressed: () async {
                              // Show a dialog to let the user choose the format
                              final format = await showDialog<String>(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    backgroundColor: Colors.grey[800],
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 12),
                                        child: Text(
                                          'Select Format',
                                          style: TextStyle(
                                            fontFamily: 'PTSans',
                                            fontSize: 32,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(context, 'txt'),
                                        child: const Text(
                                          'Text File (.txt)',
                                          style: TextStyle(
                                            fontFamily: 'PTSans',
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(context, 'docx'),
                                        child: const Text(
                                          'HTML Document (.html)',
                                          style: TextStyle(
                                            fontFamily: 'PTSans',
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                      SimpleDialogOption(
                                        onPressed: () =>
                                            Navigator.pop(context, 'pdf'),
                                        child: const Text(
                                          'PDF (.pdf)',
                                          style: TextStyle(
                                            fontFamily: 'PTSans',
                                            fontSize: 20,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (format != null) {
                                shareNote(filteredNotes[index], format);
                              }
                            },
                            icon: const Icon(Icons.ios_share_outlined),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ))
          ])),
      floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final result = await Navigator.push(
              context,
              FadePageRoute(
                builder: (BuildContext context) => EditPage(),
              ),
            );

            if (result != null) {
              setState(() {
                sampleNotes.add(Note(
                  id: sampleNotes.length,
                  title: result[0],
                  content: result[1],
                  modifiedTime: DateTime.now(),
                  category: result[2],
                  imagePaths: result[3],
                  videoPaths: result[4],
                ));
                saveNotes(sampleNotes);
                loadNotes();
                filteredNotes = sampleNotes;
              });
            }
          },
          elevation: 10,
          backgroundColor: Colors.grey[800],
          child: const Icon(
            Icons.add,
            size: 30,
            color: Colors.white,
          )),
    );
  }

  @override
  void dispose() {
    saveNotes(sampleNotes); // Save notes when the app is closed
    super.dispose();
  }

  Future<dynamic> confirmDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.grey[800],
            icon: const Icon(
              Icons.info,
              color: Colors.white,
            ),
            title: const Text("Are you sure you want to delete this Note?",
                style: TextStyle(
                    fontFamily: 'PTSans', color: Colors.white, fontSize: 32)),
            content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        child: const Text(
                          "Yes",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'PTSans',
                              fontSize: 20,
                              color: Colors.white),
                        )),
                  ),
                  SizedBox(
                    width: 120,
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context, false);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        child: const Text(
                          "No",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontFamily: 'PTSans',
                              fontSize: 20,
                              color: Colors.white),
                        )),
                  )
                ]),
          );
        });
  }
}
