class Player {
  String name;
  int age;
  double height;
  int runs;
  int balls;
  bool isOut;

  Player({
    required this.name,
    required this.age,
    required this.height,
    this.runs = 0,
    this.balls = 0,
    this.isOut = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'age': age,
      'height': height,
      'runs': runs,
      'balls': balls,
      'isOut': isOut,
    };
  }

  static Player fromMap(Map<String, dynamic> map) {
    return Player(
      name: map['name'],
      age: map['age'],
      height: map['height'],
      runs: map['runs'],
      balls: map['balls'],
      isOut: map['isOut'],
    );
  }
}