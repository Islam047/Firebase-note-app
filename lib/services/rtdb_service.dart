
import 'package:firebase_database/firebase_database.dart';

import '../models/post_model.dart';

class RTDBService {
  static final database = FirebaseDatabase.instance.ref();

  static Future<Stream<DatabaseEvent>> storePost(Post post) async {
    String? key = database.child("posts").push().key;
    post.postKey = key!;
    await database.child("posts").child(post.postKey).set(post.toJson());
    return database.onChildAdded;
  }

  static Future<List<Post>> loadPosts(String id) async {
    List<Post> items = [];
    Query query = database.child("posts").orderByChild("userId").equalTo(id);
    var snapshot = await query.once();
    var result = snapshot.snapshot.children;

    for(DataSnapshot item in result) {
      if(item.value != null) {
        items.add(Post.fromJson(Map<String, dynamic>.from(item.value as Map)));
      }
    }

    return items;
  }

  static Future<void> deletePost(String postKey) async {
    await database.child("posts").child(postKey).remove();
  }

  static Future<Stream<DatabaseEvent>> updatePost(Post post) async {
    await database.child("posts").child(post.postKey).set(post.toJson());
    return database.onChildAdded;
  }
}