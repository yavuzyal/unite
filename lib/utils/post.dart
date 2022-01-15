class Post {
  String text;
  String image_url;
  String date;
  int likeCount;
  int commentCount;
  List<dynamic> comments;
  String postId;
  String owner = '';
  String owner_name = '';

  Post({
    required this.postId,
    required this.text,
    required this.image_url,
    required this.date,
    required this.likeCount,
    required this.commentCount,
    required this.comments,
    this.owner = '',
    this.owner_name = ''
  });

  @override
  String toString() => 'Post: $text\nDate: $date\nLikes: $likeCount\nComments: $commentCount';
}