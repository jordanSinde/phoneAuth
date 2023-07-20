import 'package:dio/dio.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:path_provider/path_provider.dart';

class UploadDownloadFileInStorage extends StatefulWidget {
  const UploadDownloadFileInStorage({super.key});

  @override
  State<UploadDownloadFileInStorage> createState() =>
      _UploadDownloadFileInStorageState();
}

class _UploadDownloadFileInStorageState
    extends State<UploadDownloadFileInStorage> {
  late Future<ListResult> futureFiles;
  Map<int, double> downloadProgress = {};
  @override
  void initState() {
    super.initState();
    futureFiles = FirebaseStorage.instance.ref().child('/files').listAll();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<ListResult>(
        future: futureFiles,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            final files = snapshot.data!.items;
            return ListView.builder(
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = files[index];
                double? progress = downloadProgress[index];
                return ListTile(
                  title: Text(file.name),
                  subtitle: progress != null
                      ? LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black26,
                        )
                      : null,
                  trailing: IconButton(
                    onPressed: () => downloadFile(index, file, () {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Download ${file.name}'),
                        ),
                      );
                    }),
                    icon: const Icon(
                      Icons.download,
                    ),
                  ),
                );
              },
            );
          } else if (snapshot.hasError) {
            return const Center(
              child: Text("Error Occured !"),
            );
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }

  Future downloadFile(
      int index, Reference ref, VoidCallback onDownloaded) async {
    final url = await ref.getDownloadURL();
    print(url);

    final tempDir = await getTemporaryDirectory();
    final path = '${tempDir.path}/${ref.name}';
    await Dio().download(
      url,
      path,
      onReceiveProgress: (count, total) {
        double progress = count / total;
        setState(() {
          downloadProgress[index] = progress;
        });
      },
    );

    if (url.contains('.mp4')) {
      await GallerySaver.saveVideo(path, toDcim: true);
    } else if (url.contains('.jpg')) {
      await GallerySaver.saveImage(path, toDcim: true);
    }

    onDownloaded.call();
  }
}
