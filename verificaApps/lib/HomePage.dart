import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:device_apps/device_apps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:install_plugin/install_plugin.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';

class HomePage extends StatefulWidget {
  final TargetPlatform platform;
  HomePage(this.platform);
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String packageName = "";
  String localPath;
  String apkFilePath;
  String downloadMessage = "Inicializando . . . .";
  bool _isDownloading = false;
  double _percentage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Download and Verify Apps"),
      ),
      body: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        right: 12, left: 12, top: 20, bottom: 12),
                    child: Column(
                      children: [
                        TextField(
                          onChanged: (value) {
                            packageName = value;
                          },
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Nome do pacote',
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        RaisedButton(
                          textColor: Colors.white,
                          color: Colors.red,
                          onPressed: () async {
                            Dio dio = Dio();
                            if (checkPermission() != null) {
                              bool isInstalled =
                                  await DeviceApps.isAppInstalled(packageName);
                              if (isInstalled) {
                                log("App instalado");
                                DeviceApps.openApp(packageName);
                              } else {
                                setState(() {
                                  _isDownloading = !_isDownloading;
                                });
                                log("App nao instalado");
                                dio.download('SEU LINK DE DOWNLOAD AQUI',
                                    '${localPath}/NOME DO SEU ARQUIVO',
                                    onReceiveProgress:
                                        (actualbytes, totalbytes) {
                                  log(totalbytes.toString());
                                  if (totalbytes == -1) {
                                    setState(() {
                                      downloadMessage = "Aplicativo já baixado";
                                    });
                                    installApk();
                                  } else {
                                    var percentage =
                                        actualbytes / totalbytes * 100;
                                    if (percentage < 100) {
                                      _percentage = percentage / 100;
                                      setState(() {
                                        downloadMessage =
                                            'Baixando . . . . ${percentage.floor()} %';
                                      });
                                    } else {
                                      setState(() {
                                        downloadMessage =
                                            "Download Concluído com sucesso !";
                                        installApk();
                                      });
                                    }
                                  }
                                });
                              }
                            }
                          },
                          child: Container(
                            width: double.infinity,
                            child: Text(
                              "Procurar",
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                        Text(downloadMessage ?? '',
                            style: Theme.of(context).textTheme.headline6),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: LinearProgressIndicator(
                            value: _percentage,
                          ),
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> setLocalPath() async {
    final directory = widget.platform == TargetPlatform.android
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    localPath = directory.path + Platform.pathSeparator + 'Download';

    final savedDir = Directory(localPath);
    bool hasExisted = await savedDir.exists();
    if (!hasExisted) {
      savedDir.create();
    }
  }

  @override
  void initState() {
    super.initState();

    setLocalPath();
  }

  Future<bool> checkPermission() async {
    if (widget.platform == TargetPlatform.android) {
      final status = await Permission.storage.status;
      if (status != PermissionStatus.granted) {
        final result = await Permission.storage.request();
        if (result == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  Future<void> installApk() async {
    apkFilePath = localPath + Platform.pathSeparator + "app.apk";
    if (apkFilePath.isEmpty) {
      print('make sure the apk file is set');
      return;
    }
    InstallPlugin.installApk(apkFilePath, 'com.example.verificaApps')
        .then((result) {
      print('install apk $result');
    }).catchError((error) {
      print('install apk error: $error');
    });
  }
}
