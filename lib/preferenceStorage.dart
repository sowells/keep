import 'package:localstorage/localstorage.dart';

class PreferenceStorage {
  static final LocalStorage storage = new LocalStorage('preference.json');

  static Future addFileId(String fileId) async {
    var managedFile = storage.getItem("managedFile");
    if(managedFile == null) managedFile = new List<String>();
    managedFile.add(fileId);
    storage.setItem("managedFile", managedFile);
  }

  static Future getFileIds() async {
    var managedFile = storage.getItem("managedFile");
    if(managedFile == null) managedFile = new List<String>();
    return managedFile;
  }
}