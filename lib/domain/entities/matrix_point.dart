class MatrixPoint{
  int x;
  int y;
  final String value;

  MatrixPoint({required this.x, required this.y, required this.value});


  Map<String, dynamic> toJson() {
    return {
      'x': x,
      'y': y,
      'value': value,
    };
  }

  factory MatrixPoint.fromJson(Map<String, dynamic> json) {
    return MatrixPoint(
      x: json['x'] as int,
      y: json['y'] as int,
      value: json['value'] as String,
    );
  }
}