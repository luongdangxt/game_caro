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

class Room {
  final String id;
  final String roomId;
  final String roomName;
  final String roomType;
  final String playerLeft;
  final String playerRight;
  final List<int> game;
  final int turnGame;

  Room({
    required this.id,
    required this.roomId,
    required this.roomName,
    required this.roomType,
    required this.playerLeft,
    required this.playerRight,
    required this.game,
    required this.turnGame,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      id: json['_id'],
      roomId: json['roomId'],
      roomName: json['roomName'],
      roomType: json['roomType'],
      playerLeft: json['playerLeft'],
      playerRight: json['playerRight'],
      game: List<int>.from(json['game']),
      turnGame: json['turnGame'],
    );
  }

  @override
  String toString() {
    return 'items(id: $id, roomId: $roomId, roomName: $roomName, roomType: $roomType, playerLeft: $playerLeft, playerRight: $playerRight, game: $game, turnGame: $turnGame)';
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final String time;
  final String v;
  User({
    required this.id,
    required this.username,
    required this.email,
    required this.time,
    required this.v,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      email: json['email'],
      time: json['time'],
      v: json['__v'].toString(),
    );
  }

  @override
  String toString() {
    return 'User(id: $id, Username: $username, Email: $email, Time: $time, __v: $v)';
  }
}