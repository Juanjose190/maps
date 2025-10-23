

class RoommateListing {
  final String id;
  final String title;
  final String description;
  final double price;
  final String listingType;
  final double? latitude;
  final double? longitude;
  final String location;
  final String? address;
  final List<String> amenities;
  final List<String> photos;
  final String ownerName;
  final String? ownerAvatar;
  final bool ownerVerified;
  final int? bedrooms;
  final int? bathrooms;
  final bool furnished;
  final bool allowsPets;
  final bool allowsSmoking;
  final String status;
  final DateTime createdAt;

  RoommateListing({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.listingType,
    this.latitude,
    this.longitude,
    required this.location,
    this.address,
    required this.amenities,
    required this.photos,
    required this.ownerName,
    this.ownerAvatar,
    required this.ownerVerified,
    this.bedrooms,
    this.bathrooms,
    required this.furnished,
    required this.allowsPets,
    required this.allowsSmoking,
    required this.status,
    required this.createdAt,
  });

  factory RoommateListing.fromJson(Map<String, dynamic> json) {
    return RoommateListing(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? 'Sin título',
      description: json['description'] ?? '',
      price: (json['price'] as num).toDouble(),
      listingType: json['listing_type'] ?? 'room',
      latitude: json['latitude'] != null
          ? (json['latitude'] as num).toDouble()
          : null,
      longitude: json['longitude'] != null
          ? (json['longitude'] as num).toDouble()
          : null,
      location: json['location'] ?? 'Pasto, Nariño',
      address: json['address'],
      amenities: json['amenities'] != null
          ? List<String>.from(json['amenities'])
          : [],
      photos: json['photos'] != null ? List<String>.from(json['photos']) : [],
      ownerName: json['owner_name'] ?? 'Usuario', 
      ownerAvatar: json['owner_avatar'], 
      ownerVerified: json['owner_verified'] ?? false, 
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      furnished: json['furnished'] ?? false,
      allowsPets: json['allows_pets'] ?? false,
      allowsSmoking: json['allows_smoking'] ?? false,
      status: json['status'] ?? 'active',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  String get typeIcon {
    switch (listingType) {
      case 'apartment':
        return '🏢';
      case 'house':
        return '🏠';
      case 'room':
      default:
        return '🚪';
    }
  }

  String get typeLabel {
    switch (listingType) {
      case 'apartment':
        return 'Apartamento';
      case 'house':
        return 'Casa';
      case 'room':
      default:
        return 'Habitación';
    }
  }
}
