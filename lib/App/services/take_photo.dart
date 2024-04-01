import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_native_image/flutter_native_image.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class TakePhoto {
  static Future<String?> pickImage({required BuildContext context}) async {
    PermissionStatus status = await getPermissionStatus();
    if (status.isGranted) {
      return await getImage(context);
    } else if (status.isDenied) {
      bool isPermissionGranted = await showPermissionDialog(context);
      if (isPermissionGranted) {
        return await getImage(context);
      }
    }
    return await getImage(context);
  }

  static Future<PermissionStatus> getPermissionStatus() async {
    return await Permission.camera.status;
  }

  static Future<String?> getImage(BuildContext context) async {
    try {
      final ImagePicker imagePicker = ImagePicker();
      final pickedFile =
          await imagePicker.pickImage(source: ImageSource.camera);
      if (pickedFile != null) {
        final img = await FlutterNativeImage.compressImage(pickedFile.path);
        return await uploadImageToFirebase(img);
      }
    } catch (e) {
      print("Error $e");
    }
    return null;
  }

  static Future<String> uploadImageToFirebase(File img) async {
    FirebaseStorage storage = FirebaseStorage.instance;
    Reference ref =
        storage.ref().child("images/${DateTime.now().toIso8601String()}.jpg");
    UploadTask uploadTask = ref.putFile(img);
    TaskSnapshot taskSnapshot = await uploadTask;
    return await taskSnapshot.ref.getDownloadURL();
  }

  static Future<bool> showPermissionDialog(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text(
              'Permiso necesario',
            ),
            content: const Text(
              'El acceso a la cámara es necesario para tomar fotos.',
            ),
            actions: [
              TextButton(
                onPressed: () async {
                  Navigator.pop(context);
                  PermissionStatus status = await Permission.camera.request();
                  if (status.isGranted) {
                    true;
                  }
                },
                child: const Text('Permitir'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancelar'),
              ),
            ],
          ),
        ) ??
        false;
  }
}
