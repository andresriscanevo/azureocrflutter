import 'dart:io';
import 'package:demoocrcamera/App/Api/azure_Api.dart';
import 'package:demoocrcamera/App/model/queries/queries.dart';
import 'package:demoocrcamera/App/services/gql_client_service.dart';
import 'package:demoocrcamera/App/services/take_photo.dart';
import 'package:demoocrcamera/App/theme/AppTheme.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:image_picker/image_picker.dart';

const appBarBackgroundColor = Colors.blueAccent;
const appBarTitleStyle =
    TextStyle(color: Colors.black, fontWeight: FontWeight.bold);
const buttonBackgroundColor = Colors.blueAccent;
const buttonTextColor = Colors.white;
const containerBackgroundColor = Colors.blueGrey;
const errorMessageStyle = TextStyle(fontSize: 20);

final selectedTextProvider = StateProvider<String?>((ref) => null);
final selectedImageProvider = StateProvider<String?>((ref) => null);

class CameraOCR extends ConsumerStatefulWidget {
  const CameraOCR({super.key});

  @override
  ConsumerState<CameraOCR> createState() => _CameraOCRState();
}

class _CameraOCRState extends ConsumerState<CameraOCR> {
  String? urlsrf;
  Future<String>? futureData;
  String? selectedText;

  @override
  Widget build(BuildContext context) {
    final selectedImage = ref.watch(selectedImageProvider.notifier).state;
    final selectedText = ref.watch(selectedTextProvider.notifier).state;
    return Scaffold(
      backgroundColor: Color.fromRGBO(208, 231, 233, 1),
      appBar: AppBar(
        title: const Text('', style: appBarTitleStyle),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(2),
            color: Color.fromRGBO(208, 231, 233, 1),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildCaptureButton(),
                _buildSendDataButton(
                    selectedImage ?? '', selectedText ?? '002'),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(2),
            color: Color.fromRGBO(208, 231, 233, 1),
            child: Column(
              children: [
                const Text(
                  'Texto seleccionado:',
                  style: TextStyle(color: AppTheme.grey),
                ),
                Center(
                    child: Text(
                  selectedText ?? '',
                  style: const TextStyle(
                      color: AppTheme.grey, fontWeight: FontWeight.bold),
                )),
              ],
            ),
          ),
          selectedImage != null
              ? Container(
                  height: 300,
                  width: 300,
                  padding: const EdgeInsets.all(2),
                  color: Color.fromRGBO(208, 231, 233, 1),
                  child: Image.network(selectedImage.toString()))
              : Container(),
          Expanded(child: _buildResultDisplay()),
        ],
      ),
    );
  }

  Widget _buildCaptureButton() => Container(
        padding: const EdgeInsets.all(10),
        child: TextButton.icon(
          onPressed: () async {
            var tempUrl = await TakePhoto.pickImage(context: context);
            if (tempUrl != null) {
              setState(() {
                urlsrf = tempUrl;
                futureData = azureApi(urlsrf);
                ref.read(selectedImageProvider.notifier).state = urlsrf;
              });
            }
          },
          style: TextButton.styleFrom(
            surfaceTintColor: Colors.grey,
            backgroundColor: buttonBackgroundColor,
          ),
          icon: const Icon(Icons.camera_alt, color: buttonTextColor),
          label:
              const Text("Capturar", style: TextStyle(color: buttonTextColor)),
        ),
      );
  Widget _buildSendDataButton(String image, String name) => Container(
        margin: const EdgeInsets.all(20),
        child: TextButton.icon(
          onPressed: () async {
            try {
              final gqlClient =
                  ref.read(GraphQLClientService().gqlClientProvider).value;

              final result = await gqlClient.mutate(
                MutationOptions(
                  document: gql(QueriesAzureOCR.insertData),
                  variables: {
                    "image": image,
                    "name": name,
                  },
                ),
              );
              final data = result.data;
              if (data != null) {
                Fluttertoast.showToast(
                    msg: "Datos enviados correctamente",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    timeInSecForIosWeb: 1,
                    backgroundColor: Colors.green,
                    textColor: Colors.white,
                    fontSize: 16.0);
              }
              if (result.hasException) {
                throw result.exception!;
              }
            } on GraphQLError catch (error) {
              if (kDebugMode) {
                print(error.message);
              }
              return Future.error(error);
            } catch (error) {
              if (kDebugMode) {
                print(error);
              }
              return Future.error(error);
            }
          },
          style: TextButton.styleFrom(
            surfaceTintColor: Colors.grey,
            backgroundColor: buttonBackgroundColor,
          ),
          icon: const Icon(Icons.send, color: buttonTextColor),
          label: const Text("Enviar", style: TextStyle(color: buttonTextColor)),
        ),
      );

  Widget _buildResultDisplay() => SafeArea(
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: futureData == null
              ? const Center(
                  child: Text(
                  'Seleccione una imagen para analizar.',
                  style: TextStyle(color: AppTheme.colorsDarkTheme),
                ))
              : FutureBuilder<String>(
                  future: futureData,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Text("Obteniendo datos...");
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}',
                          style: errorMessageStyle);
                    } else if (snapshot.hasData) {
                      List<String> lines = snapshot.data!.split('\n');
                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 2,
                              width: 280,
                              child: ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 80),
                                  itemCount: lines.length,
                                  itemBuilder: (context, index) {
                                    return Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ListTile(
                                        //contentPadding: const EdgeInsets.all(1),
                                        tileColor: Colors.lightBlue,

                                        title: Text(lines[index]),
                                        onTap: () {
                                          showDialog(
                                              context: context,
                                              builder: (context) => AlertDialog(
                                                      title: const Text(
                                                        'Confirmacion de seleccion',
                                                        style: TextStyle(
                                                            fontSize: 14,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      content: RichText(
                                                        text: TextSpan(
                                                          style: DefaultTextStyle
                                                                  .of(context)
                                                              .style,
                                                          children: <TextSpan>[
                                                            const TextSpan(
                                                                text:
                                                                    'Desea seleccionar el texto: '),
                                                            TextSpan(
                                                                text: lines[
                                                                    index],
                                                                style: const TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold)),
                                                          ],
                                                        ),
                                                      ),
                                                      actions: [
                                                        TextButton(
                                                            onPressed: () {
                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            style: TextButton
                                                                .styleFrom(
                                                              backgroundColor:
                                                                  AppTheme
                                                                      .colorPrimary,
                                                            ),
                                                            child: const Text(
                                                              'Cerrar',
                                                              style: TextStyle(
                                                                  color: AppTheme
                                                                      .colosrLightTheme),
                                                            )),
                                                        TextButton(
                                                            style: TextButton.styleFrom(
                                                                backgroundColor:
                                                                    AppTheme
                                                                        .colorPrimary),
                                                            onPressed: () {
                                                              setState(() {
                                                                ref
                                                                        .watch(selectedTextProvider
                                                                            .notifier)
                                                                        .state =
                                                                    lines[
                                                                        index];
                                                              });

                                                              Navigator.pop(
                                                                  context);
                                                            },
                                                            child: const Text(
                                                              'Seleccionar',
                                                              style: TextStyle(
                                                                  color: AppTheme
                                                                      .colosrLightTheme),
                                                            ))
                                                      ]));
                                        },
                                      ),
                                    );
                                  }),
                            ),
                          ],
                        ),
                      );
                    } else {
                      return const Text('No hay datos');
                    }
                  },
                ),
        ),
      );
}
