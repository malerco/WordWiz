class Point{
  final double x;
  final double y;

  Point({required this.x, required this.y});


  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
    };
  }

  factory Point.fromJson(Map<String, dynamic> json) {
    return Point(x: json['x'] as double, y: json['y'] as double);
  }
}