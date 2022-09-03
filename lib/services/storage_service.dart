import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class StorageService {
  static final _storage = FirebaseStorage.instance.ref();
  static const folder = "post_images";

  static Future<String> uploadImage(File image) async {
    String imageName = "image_${DateTime.now()}";
    Reference reference = _storage.child(folder).child(imageName);

    UploadTask uploadTask = reference.putFile(image);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }
  static Future<List<String>> uploadImageList(List<File> list) async {
    List<String> items = await Future.wait(list.map((e) => uploadImage(e)));
    return items;
  }
}