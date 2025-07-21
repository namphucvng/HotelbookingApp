class Room {
  final String id;
  final String name;
  final String location;
  final String branch;
  final String branchId;
  final String type;
  final String typeId;
  final int price;
  final String description;
  final List<String> imageUrls;
  final double latitude;
  final double longitude;
  final List<String> amenities;
  final List<FoodItem> foods;
  final double rating;

  Room({
    required this.id,
    required this.name,
    required this.location,
    required this.branch,
    required this.branchId,
    required this.type,
    required this.typeId,
    required this.price,
    required this.description,
    required this.imageUrls,
    required this.latitude,
    required this.longitude,
    required this.amenities,
    required this.foods,
    required this.rating,
  });

  factory Room.fromFirestore(String id, Map<String, dynamic> data) {
    return Room(
      id: id,
      name: data['name'] ?? '',
      location: data['location'] ?? '',
      branch: data['branch'] ?? '',
      branchId: data['branchId'] ?? '',
      type: data['type'] ?? '',
      typeId: data['typeId'] ?? '',
      price: (data['price'] ?? 0).toInt(),
      description: data['description'] ?? '',
      imageUrls: List<String>.from(data['imageUrls'] ?? []),
      latitude: (data['latitude'] ?? 0.0).toDouble(),
      longitude: (data['longitude'] ?? 0.0).toDouble(),
      amenities: List<String>.from(data['amenities'] ?? []),
      foods: (data['foods'] as List<dynamic>? ?? []).map((f) => FoodItem.fromMap(f)).toList(),
      rating: (data['rating'] ?? 0.0).toDouble(),
    );
  }
}

class FoodItem {
  final String name;
  final String image;

  FoodItem({required this.name, required this.image});

  factory FoodItem.fromMap(Map<String, dynamic> data) {
    return FoodItem(
      name: data['name'] ?? '',
      image: data['image'] ?? '',
    );
  }
}
