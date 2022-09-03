class Post {
  late String postKey;
  late String userId;
  late String firstname;
  late String lastname;
  late String date;
  late String content;
  String? image;

  Post({
    required this.postKey,
    required this.userId,
    required this.firstname,
    required this.lastname,
    required this.date,
    required this.content,
    this.image});

  Post.fromJson(Map<String, dynamic> json) {
    postKey = json['postKey'];
    userId = json['userId'];
    firstname = json['firstname'];
    lastname = json['lastname'];
    date = json['date'];
    content = json['content'];
    image = json['image'];
  }

  Map<String, dynamic> toJson() => {
    'postKey': postKey,
    'userId': userId,
    'firstname': firstname,
    'lastname': lastname,
    'date': date,
    'content': content,
    'image': image,
  };
}