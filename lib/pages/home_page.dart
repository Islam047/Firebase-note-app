import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../main.dart';
import '../models/post_model.dart';
import '../services/auth_service.dart';
import '../services/database_service.dart';
import '../services/remote_service.dart';
import '../services/rtdb_service.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  static const id = "/home_page";

  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with RouteAware {
  bool isLoading = false;
  List<Post> items = [];

  @override
  void initState() {
    super.initState();
    _getAllPost();
  }

  void _getAllPost() async {
    isLoading = true;
    setState(() {});

    String userId = await DBService.loadUserId() ?? "null";
    items = await RTDBService.loadPosts(userId);

    // remote config
    await RemoteService.initConfig();

    isLoading = false;
    setState(() {});
  }

  void _logout() {
    AuthService.signOutUser(context);
  }

  void _openDetailPage() {

    Navigator.pushNamed(context, DetailPage.id);
  }

  void _deleteDialog(String postKey) async {
    showDialog(
      context: context,
      builder: (context) {
        if (Platform.isIOS) {
          return CupertinoAlertDialog(
            title: const Text("Delete Post"),
            content: const Text("Do you want to delete this post?"),
            actions: [
              CupertinoDialogAction(
                onPressed: () => _deletePost(postKey),
                child: const Text("Confirm"),
              ),
              CupertinoDialogAction(
                onPressed: _cancel,
                child: const Text("Cancel"),
              ),
            ],
          );
        } else {
          return AlertDialog(
            title: const Text("Delete Post"),
            content: const Text("Do you want to delete this post?"),
            actions: [
              TextButton(
                onPressed: () => _deletePost(postKey),
                child: const Text("Confirm"),
              ),
              TextButton(
                onPressed: _cancel,
                child: const Text("Cancel"),
              ),
            ],
          );
        }
      },
    );
  }

  void _cancel() {
    Navigator.pop(context);
  }

  void _deletePost(String postKey) async {
    Navigator.pop(context);
    isLoading = true;
    setState(() {});

    await RTDBService.deletePost(postKey);
    _getAllPost();
  }

  void _editPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          return DetailPage(
            state: DetailState.update,
            post: post,
          );
        },
      ),
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    MyFirebaseApp.routeObserver
        .subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    _getAllPost();
    super.didPopNext();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Icon(RemoteService.availableIcons[RemoteService.iconMy]),
        backgroundColor: RemoteService.availableBackgroundColors[RemoteService.backgroundColor],
        title: const Text("All Post"),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          return _itemOfList(items[index]);
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: RemoteService.availableBackgroundColors[RemoteService.backgroundColor],
        onPressed: _openDetailPage,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _itemOfList(Post post) {
    return GestureDetector(
      onLongPress: () => _deleteDialog(post.postKey),
      onDoubleTap: () => _editPost(post),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 250,
              width: double.infinity,
              child: post.image != null
                  ? Image.network(
                post.image!,
                fit: BoxFit.cover,
              )
                  : const Image(
                image: AssetImage(
                  "assets/images/img_2.png",
                ),
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            Text(
              "${post.firstname} ${post.lastname}",
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            Text(
              post.date.substring(0, 10),
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              post.content,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}