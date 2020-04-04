
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:keep/googleDrive.dart';

class FileSelect extends StatefulWidget {
  final callback;
  FileSelect(this.callback);

  @override
  _FileSelectState createState() => _FileSelectState(callback);
}

class _FileSelectState extends State<FileSelect>  {
  final drive = GoogleDrive();
  Future filesFuture;
  final callback;

  _FileSelectState(this.callback) {
    filesFuture = drive.list();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: filesFuture,
      builder: (context, snapshot) {
        List<ga.File> files = snapshot.data;
        return Scaffold(
            appBar: AppBar(
              title: Text("어떤 파일을 추가하시겠어요?"),
            ),
            body: ListView.builder(
              itemCount: files == null ? 0 : files.length,
              itemBuilder: (BuildContext context, int index) {
                return new FlatButton(
                    onPressed: () {
                      callback(files[index].id);
                      Navigator.pop(context);
                    },
                    child: ListTile(
                      title: Text(files[index].name),
                      subtitle: Text(files[index].modifiedTime.toString()),
                      selected: false,
                    )
                );
              },
            )
        );
      },
    );
  }
}