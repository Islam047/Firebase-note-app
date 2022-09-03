import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/rtdb_service.dart';
import '../services/storage_service.dart';
import '../services/utils_service.dart';

class DetailPage extends StatefulWidget {
  static const id = "/detail_page";
  final DetailState state;
  final Post? post;

  const DetailPage({this.state = DetailState.create, this.post, Key? key})
      : super(key: key);

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  TextEditingController firstnameController = TextEditingController();
  TextEditingController lastnameController = TextEditingController();
  TextEditingController contentController = TextEditingController();
  TextEditingController dateController = TextEditingController();
  bool isLoading = false;
  Post? updatePost;

  // for image
  final ImagePicker _picker = ImagePicker();
  File? file;

  @override
  void initState() {
    super.initState();
    _detectState();
  }

  void _detectState() {
    if (widget.state == DetailState.update && widget.post != null) {
      updatePost = widget.post;
      firstnameController.text = updatePost!.firstname;
      lastnameController.text = updatePost!.lastname;
      contentController.text = updatePost!.content;
      dateController.text = updatePost!.date;
      setState(() {});
    }
  }

  void _getImage() async {
    var image = await _picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        file = File(image.path);
      });
    } else {
      if (mounted) Utils.fireSnackBar("Please select image for post", context);
    }
  }

  void _addPost() async {
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String content = contentController.text.trim();
    String date = dateController.text.trim();
    String? imageUrl;

    if (firstname.isEmpty ||
        content.isEmpty ||
        lastname.isEmpty ||
        date.isEmpty) {
      Utils.fireSnackBar("Please fill all fields", context);
      return;
    }
    isLoading = true;
    setState(() {});

    String? userId = await DBService.loadUserId();

    if (userId == null) {
      if (mounted) {
        Navigator.pop(context);
        AuthService.signOutUser(context);
      }
      return;
    }

    if (file != null) {
      imageUrl = await StorageService.uploadImage(file!);
    }

    Post post = Post(
        postKey: "",
        userId: userId,
        firstname: firstname,
        lastname: lastname,
        date: date,
        content: content,
        image: imageUrl);

    await RTDBService.storePost(post).then((value) {
      Navigator.of(context).pop();
    });

    isLoading = false;
    setState(() {});
  }

  void _updatePost() async {
    String firstname = firstnameController.text.trim();
    String lastname = lastnameController.text.trim();
    String content = contentController.text.trim();
    String date = dateController.text.trim();
    String? imageUrl;

    if (firstname.isEmpty ||
        content.isEmpty ||
        lastname.isEmpty ||
        date.isEmpty) {
      Utils.fireSnackBar("Please fill all fields", context);
      return;
    }
    isLoading = true;
    setState(() {});

    if (file != null) {
      imageUrl = await StorageService.uploadImage(file!);
    }

    Post post = Post(
        postKey: updatePost!.postKey,
        userId: updatePost!.userId,
        firstname: firstname,
        lastname: lastname,
        date: date,
        content: content,
        image: imageUrl ?? updatePost!.image);

    await RTDBService.updatePost(post).then((value) {
      Navigator.of(context).pop();
    });

    isLoading = false;
    setState(() {});
  }

  void _selectDate() async {
    await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2122),
    ).then((date) {
      if (date != null) {
        dateController.text = date.toString();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromRGBO(246, 246, 246, 1),
      appBar: AppBar(
        title: widget.state == DetailState.update
            ? const Text("Update Post")
            : const Text("Add Post"),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              height: MediaQuery.of(context).size.height,
              padding: const EdgeInsets.all(25),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // #image
                  GestureDetector(
                    onTap: _getImage,
                    child: SizedBox(
                      height: 125,
                      width: 125,
                      child: (updatePost != null &&
                          updatePost!.image != null &&
                          file == null)
                          ? Image.network(updatePost!.image!)
                          : (file == null
                          ? const Image(
                        image: AssetImage("assets/images/img_2.png"),
                      )
                          : Image.file(file!)),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // #firstname
                  TextField(
                    controller: firstnameController,
                    decoration: const InputDecoration(
                      hintText: "Firstname",
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // #lastname
                  TextField(
                    controller: lastnameController,
                    decoration: const InputDecoration(
                      hintText: "Lastname",
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // #content
                  TextField(
                    controller: contentController,
                    decoration: const InputDecoration(
                      hintText: "Content",
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // #date
                  TextField(
                    controller: dateController,
                    readOnly: true,
                    onTap: _selectDate,
                    decoration: const InputDecoration(
                      hintText: "Date",
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                    keyboardType: TextInputType.text,
                    textInputAction: TextInputAction.done,
                  ),
                  const SizedBox(
                    height: 20,
                  ),

                  // #add_update
                  ElevatedButton(
                    onPressed: () {
                      if (widget.state == DetailState.update) {
                        _updatePost();
                      } else {
                        _addPost();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50)),
                    child: Text(
                      widget.state == DetailState.update ? "Update" : "Add",
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          )
        ],
      ),
    );
  }
}

enum DetailState {
  create,
  update,
}