import 'dart:io';
import 'dart:convert';
import 'dart:async';

import 'package:keep/secureStorage.dart';
import 'package:googleapis/drive/v3.dart' as ga;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as p;
import 'package:url_launcher/url_launcher.dart';
import 'package:_discoveryapis_commons/_discoveryapis_commons.dart' as commons;

const _clientId = "896708728874-1g8gckc91e8tv9e2fsqrbml891gdg9ud.apps.googleusercontent.com";
const _clientSecret = "QfI6_4C5sEDVjqwZQed2PvJ7";
const _scopes = [ga.DriveApi.DriveScope];

class GoogleDrive {
  final storage = SecureStorage();

  //Get Authenticated Http Client
  Future<http.Client> getHttpClient() async {
    //Get Credentials
//    storage.clear();
    var credentials = await storage.getCredentials();
    if (credentials == null) {
      //Needs user authentication
      var authClient = await clientViaUserConsent(
          ClientId(_clientId, _clientSecret), _scopes, (url) {
        //Open Url in Browser
        launch(url);
      });
      //Save Credentials
      await storage.saveCredentials(authClient.credentials.accessToken,
          authClient.credentials.refreshToken);
      return authClient;
    } else {
      print(credentials["expiry"]);
      //Already authenticated
      var authClient = authenticatedClient(
          http.Client(),
          AccessCredentials(
              AccessToken(credentials["type"], credentials["data"],
                  DateTime.tryParse(credentials["expiry"])),
              credentials["refreshToken"],
              _scopes));
      return authClient;
    }
  }

  //Upload File
  Future upload(File file) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    print("Uploading file");
    var response = await drive.files.create(
        ga.File()..name = p.basename(file.absolute.path),
        uploadMedia: ga.Media(file.openRead(), file.lengthSync()));

    print("Result ${response.toJson()}");
  }

  Future list() async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);

    try {
      ga.FileList list = await drive.files.list($fields: '*', q: "mimeType='application/vnd.google-apps.document'");
      return list.files;
    } on AccessDeniedException {
      storage.clear();
      return list();
    }
  }

  Future read(fileId) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    ga.Media file = await drive.files.export(fileId, 'text/plain', downloadOptions: commons.DownloadOptions.FullMedia);
    var lines = new List();
    file.stream
        .transform(utf8.decoder)       // Decode bytes to UTF-8.
        .transform(new LineSplitter()) // Convert stream to individual lines.
        .listen((String line) { lines.add(line); },
        onDone: () { print('File is now closed.'); },
        onError: (e) { print(e.toString()); });
    return lines;
  }

  Future readMetadata(fileId) async {
    var client = await getHttpClient();
    var drive = ga.DriveApi(client);
    ga.File file = await drive.files.get(fileId);
    return file;
  }
}