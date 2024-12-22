class itemBox{
  final String name;
  final String description;
  final String urlImg;
  itemBox({
    required this.name,
    required this.description,
    required this.urlImg,
  });
}

class itemBGame{
  final String name;
  final String description;
  final String urlImg;
  final bool lock;
  itemBGame({
    required this.name,
    required this.description,
    required this.urlImg,
    required this.lock,
  });
}