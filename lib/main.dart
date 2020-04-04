import 'package:flutter/material.dart';
import 'package:keep/fileSelect.dart';
import 'package:keep/googleDrive.dart';
import 'package:keep/preferenceStorage.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Drive',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ManagedFiles(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class File {
  String id;
  String name = "";

  File(this.id);
}

class _HomePageState extends State<HomePage> {
  final drive = GoogleDrive();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("더 기억할 게 있으신가요?"),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ManagedFiles()),
          );
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.green,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class ManagedFiles extends StatefulWidget {
  @override
  _ManagedFileState createState() => _ManagedFileState();
}


class _ManagedFileState extends State<ManagedFiles> {
  final drive = GoogleDrive();
  List<File> files = new List<File>();

  _ManagedFileState() {
    PreferenceStorage.getFileIds().then((ids) {
      for(var id in ids) {
        File file = new File(id);
        setState(() {
          files.add(file);
        });
        drive.readMetadata(id).then((meta) {
          setState(() {
            file.name = meta.name;
          });
        });
      }
    });
  }

  void callback(id) {
    PreferenceStorage.addFileId(id);
    File file = new File(id);
    setState(() {
      files.add(file);
    });
    drive.readMetadata(id).then((meta) {
      setState(() {
        file.name = meta.name;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("더 기억할게 있으신가요?"),
        ),
        body: ListView.builder(
          itemCount: files == null ? 0 : files.length,
          itemBuilder: (BuildContext context, int index) {
//                ga.File file = await drive.readMetadata(fileIds[index]);
            return new FlatButton(
                onPressed: () {
                },
                child: ListTile(
                  title: Text(files[index].name),
//                      subtitle: Text(files[index].modifiedTime.toString()),
                  selected: false,
                )
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => FileSelect(this.callback)),
            );
          },
          child: Icon(Icons.add),
          backgroundColor: Colors.green,
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}