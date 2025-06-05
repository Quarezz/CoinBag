class Category {
  final String id;
  final String name;
  final String iconName;
  final String colorHex;

  Category({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });

  Category copyWith({
    String? id,
    String? name,
    String? iconName,
    String? colorHex,
    String? userId,
  }) => Category(
    id: id ?? this.id,
    name: name ?? this.name,
    iconName: iconName ?? this.iconName,
    colorHex: colorHex ?? this.colorHex,
  );

  factory Category.fromJson(Map<String, dynamic> json) => Category(
    id: json['id'],
    name: json['name'],
    iconName: json['icon_name'],
    colorHex: json['color_hex'],
  );
}

class CategoryCreationDTO {
  final String name;
  final String icon;
  final String color;

  CategoryCreationDTO({
    required this.name,
    required this.icon,
    required this.color,
  });

  Map<String, dynamic> toJson() => {
    'in_name': name,
    'in_icon': icon,
    'in_color': color,
  };
}

class CategoryUpdateDTO {
  final String id;
  final String? name;
  final String? iconName;
  final String? colorHex;

  CategoryUpdateDTO({
    required this.id,
    required this.name,
    required this.iconName,
    required this.colorHex,
  });
}
