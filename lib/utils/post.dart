class Post {
  String text;
  String image_url;
  String date;
  int likeCount;
  int commentCount;
  Map<String, String> comments;

  Post({
    required this.text,
    required this.image_url,
    required this.date,
    required this.likeCount,
    required this.commentCount,
    required this.comments,
  });

  @override
  String toString() => 'Post: $text\nDate: $date\nLikes: $likeCount\nComments: $commentCount';
}


