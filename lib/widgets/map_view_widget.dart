
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../models/osm_place.dart';
import '../models/roommate_listing.dart';

class SinglePlaceMapView extends StatelessWidget {
  final OsmPlace place;

  const SinglePlaceMapView({Key? key, required this.place}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    IconData icon = Icons.place;
    Color iconColor = Color(0xFF6C5CE7);

    if (place.amenity == 'university' || place.amenity == 'school') {
      icon = Icons.school;
      iconColor = Color(0xFF2196F3);
    } else if (place.amenity == 'hospital') {
      icon = Icons.local_hospital;
      iconColor = Color(0xFFE91E63);
    } else if (place.amenity == 'supermarket') {
      icon = Icons.shopping_cart;
      iconColor = Color(0xFF4CAF50);
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6C5CE7), Color(0xFF5F4FDB)],
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4),
                      Text(
                        place.amenity ?? place.shop ?? 'Lugar de interés',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

      
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: LatLng(place.lat, place.lon),
                initialZoom: 16.0,
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.roommate_finder',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      point: LatLng(place.lat, place.lon),
                      width: 60,
                      height: 60,
                      child: Container(
                        decoration: BoxDecoration(
                          color: iconColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: iconColor.withOpacity(0.5),
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(icon, color: Colors.white, size: 30),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Container(
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: Offset(0, -5),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: iconColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Coordenadas',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFF999999),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            '${place.lat.toStringAsFixed(6)}, ${place.lon.toStringAsFixed(6)}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1A1A1A),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class MapViewWidget extends StatefulWidget {
  final List<OsmPlace> places;
  final List<RoommateListing> listings; 
  final LatLng center;

  const MapViewWidget({
    Key? key,
    required this.places,
    required this.listings, 
    this.center = const LatLng(1.2136, -77.2811),
  }) : super(key: key);

  @override
  State<MapViewWidget> createState() => _MapViewWidgetState();
}

class _MapViewWidgetState extends State<MapViewWidget> {
  final MapController _mapController = MapController();
  
  dynamic _selectedItem;

  @override
  Widget build(BuildContext context) {

    final allMarkers = <Marker>[];

    
    allMarkers.addAll(
      widget.listings
          .where((l) => l.latitude != null && l.longitude != null)
          .map((listing) {
            return Marker(
              point: LatLng(listing.latitude!, listing.longitude!),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedItem = listing; 
                  });
                  _mapController.move(
                    LatLng(listing.latitude!, listing.longitude!),
                    _mapController.camera.zoom < 15.0
                        ? 15.0
                        : _mapController.camera.zoom,
                  );
                },
                child: _buildListingMarkerIcon(
                  listing,
                ), 
              ),
            );
          }),
    );

   
    allMarkers.addAll(
      widget.places.map((place) {
        return Marker(
          point: LatLng(place.lat, place.lon),
          width: 40,
          height: 40,
          child: GestureDetector(
            onTap: () {
              setState(() {
                _selectedItem = place; 
              });
              _mapController.move(
                LatLng(place.lat, place.lon),
                _mapController.camera.zoom < 15.0
                    ? 15.0
                    : _mapController.camera.zoom,
              );
            },
            child: _buildPOIMarkerIcon(place), 
          ),
        );
      }),
    );

    return Container(
      height: 600,
      margin: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            _buildMapHeader(),
            Expanded(
              child: Stack(
                children: [
                  FlutterMap(
                    mapController: _mapController,
                    options: MapOptions(
                      initialCenter: widget.center,
                      initialZoom: 13.0,
                      minZoom: 10.0,
                      maxZoom: 18.0,
                      onTap: (_, __) {
                        setState(() {
                          _selectedItem = null;
                        });
                      },
                      interactionOptions: const InteractionOptions(
                        flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                      ),
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.roommate_finder',
                      ),
                      
                      MarkerLayer(markers: allMarkers),
                    ],
                  ),

                  Positioned(
                    right: 16,
                    
                    bottom: _selectedItem != null ? 220 : 100,
                    child: Column(
                      children: [
                        _buildZoomButton(
                          icon: Icons.add,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom + 1,
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        _buildZoomButton(
                          icon: Icons.remove,
                          onPressed: () {
                            _mapController.move(
                              _mapController.camera.center,
                              _mapController.camera.zoom - 1,
                            );
                          },
                        ),
                        SizedBox(height: 8),
                        _buildZoomButton(
                          icon: Icons.my_location,
                          onPressed: () {
                            _mapController.move(widget.center, 13.0);
                          },
                        ),
                      ],
                    ),
                  ),

                  
                  if (_selectedItem != null)
                    Positioned(
                      left: 16,
                      right: 16,
                      bottom: 16,
                      child: _selectedItem is RoommateListing
                          ? _buildListingCard(
                              _selectedItem as RoommateListing,
                            ) 
                          : _buildPlaceCard(
                              _selectedItem as OsmPlace,
                            ), 
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMapHeader() {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF6C5CE7), Color(0xFF5F4FDB)],
        ),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        children: [
          Icon(Icons.map, color: Colors.white, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Explorar en el mapa',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(Icons.place, color: Colors.white, size: 16),
                SizedBox(width: 4),
                Text(
                  // CONTEO COMBINADO
                  '${widget.listings.length + widget.places.length} lugares',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildZoomButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 5),
        ],
      ),
      child: IconButton(
        icon: Icon(icon, color: Color(0xFF6C5CE7)),
        onPressed: onPressed,
      ),
    );
  }

  Widget _buildListingMarkerIcon(RoommateListing listing) {
    Color color = Color(0xFFFF9800); 
    IconData icon = Icons.house;

    if (listing.listingType == 'room') {
      icon = Icons.bed;
      color = Color(0xFFE91E63);
    } else if (listing.listingType == 'apartment') {
      icon = Icons.apartment;
      color = Color(0xFF4CAF50); 
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.white,
          width: 2,
        ), 
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }


  Widget _buildPOIMarkerIcon(OsmPlace place) {
    IconData icon = Icons.place;
    Color color = Color(0xFF6C5CE7); 

    if (place.amenity == 'university' || place.amenity == 'school') {
      icon = Icons.school;
      color = Color(0xFF2196F3);
    } else if (place.amenity == 'hospital') {
      icon = Icons.local_hospital;
      color = Color(0xFF757575); 
    } else if (place.amenity == 'supermarket') {
      icon = Icons.shopping_cart;
      color = Color(0xFFFFC107);
    }

    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.4),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );
  }


  Widget _buildListingCard(RoommateListing listing) {
    Color iconColor = Color(0xFFFF9800);

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: iconColor.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(Icons.bed, color: iconColor, size: 24),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  listing.title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              IconButton(
                icon: Icon(Icons.close, color: Color(0xFF999999)),
                onPressed: () {
                  setState(() {
                    _selectedItem = null;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(color: Color(0xFFEEEEEE), height: 1),
          SizedBox(height: 10),
          _buildInfoRow(
            Icons.monetization_on,
            'Precio',
            '\$${listing.price.toStringAsFixed(0)} / mes',
            Colors.green.shade700,
          ),
          _buildInfoRow(Icons.home, 'Tipo', listing.typeLabel, iconColor),
          _buildInfoRow(
            Icons.location_on,
            'Ubicación',
            listing.location,
            Color(0xFF666666),
          ),
        ],
      ),
    );
  }


  Widget _buildPlaceCard(OsmPlace place) {
    IconData icon = Icons.place;
    Color iconColor = Color(0xFF6C5CE7);

    if (place.amenity == 'university' || place.amenity == 'school') {
      icon = Icons.school;
      iconColor = Color(0xFF2196F3);
    } else if (place.amenity == 'hospital') {
      icon = Icons.local_hospital;
      iconColor = Color(0xFFE91E63);
    }

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  place.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF1A1A1A),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4),
                Text(
                  place.amenity ?? place.shop ?? 'Lugar de interés',
                  style: TextStyle(fontSize: 13, color: Color(0xFF666666)),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.close, color: Color(0xFF999999)),
            onPressed: () {
              setState(() {
                _selectedItem = null;
              });
            },
          ),
        ],
      ),
    );
  }

 
  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          SizedBox(width: 8),
          Text(
            '$label: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Color(0xFF333333),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 14, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
