import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:latlong2/latlong.dart';
import 'services/overpass_service.dart';
import 'models/osm_place.dart';
import 'widgets/map_view_widget.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://cbnoxxhfhmcmanmqiodn.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImNibm94eGhmaG1jbWFubXFpb2RuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjExNjU0MjUsImV4cCI6MjA3Njc0MTQyNX0.gi8m8iwmr13G5fomF_tk3LNByp1ZrGwEvugnEpt7Z1o',
  );

  runApp(RoommateFinderApp());
}

final supabase = Supabase.instance.client;

class RoommateFinderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomMate Finder',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.purple,
        scaffoldBackgroundColor: Color(0xFFF8F9FA),
        appBarTheme: AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          foregroundColor: Color(0xFF1A1A1A),
          centerTitle: true,
        ),
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final OverpassService _overpassService = OverpassService();
  List<OsmPlace> _nearbyPlaces = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadNearbyPlaces();
  }

  Future<void> _loadNearbyPlaces() async {
    setState(() => _isLoading = true);

    try {
      final results = await _overpassService.searchMultipleTypes(
        lat: 1.2136,
        lon: -77.2811,
        radius: 5000,
        tags: {
          'amenity': ['university', 'school', 'hospital', 'supermarket'],
          'shop': ['mall', 'convenience'],
        },
      );

      setState(() {
        _nearbyPlaces = results.map((json) => OsmPlace.fromJson(json)).toList();
        _isLoading = false;
      });

      print('Lugares cercanos encontrados: ${_nearbyPlaces.length}');
    } catch (e) {
      print('Error cargando lugares: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF8F9FA),
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: Color(0xFF6C5CE7),
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'RoomMate Finder',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF6C5CE7), Color(0xFF5F4FDB)],
                  ),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Row(
                children: [
                  Icon(Icons.map, color: Color(0xFF6C5CE7), size: 28),
                  SizedBox(width: 12),
                  Text(
                    'Explorar en el mapa',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A1A1A),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Color(0xFF6C5CE7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.place, color: Color(0xFF6C5CE7)),
                    SizedBox(width: 8),
                    Text(
                      '${_nearbyPlaces.length} lugares encontrados en Pasto',
                      style: TextStyle(
                        color: Color(0xFF6C5CE7),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(height: 20).toSliver(),
          if (_isLoading)
            SliverToBoxAdapter(
              child: Container(
                height: 400,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Color(0xFF6C5CE7)),
                      SizedBox(height: 20),
                      Text(
                        'Cargando lugares cercanos...',
                        style: TextStyle(
                          color: Color(0xFF666666),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverToBoxAdapter(
              child: MapViewWidget(
                places: _nearbyPlaces,
                listings: const [],
                center: LatLng(1.2136, -77.2811),
              ),
            ),
          SizedBox(height: 20).toSliver(),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '📍 Lugares de interés',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A1A1A),
                ),
              ),
            ),
          ),
          SizedBox(height: 16).toSliver(),
          SliverList(
            delegate: SliverChildBuilderDelegate((context, index) {
              if (_nearbyPlaces.isEmpty) {
                return Container(
                  padding: EdgeInsets.all(40),
                  child: Center(
                    child: Text(
                      'No hay lugares disponibles',
                      style: TextStyle(color: Color(0xFF999999)),
                    ),
                  ),
                );
              }

              final place = _nearbyPlaces[index];
              return _buildPlaceCard(place);
            }, childCount: _nearbyPlaces.isEmpty ? 1 : _nearbyPlaces.length),
          ),
          SizedBox(height: 40).toSliver(),
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
    } else if (place.amenity == 'supermarket') {
      icon = Icons.shopping_cart;
      iconColor = Color(0xFF4CAF50);
    }

    return GestureDetector(
      onTap: () {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.95,
            builder: (context, scrollController) =>
                SinglePlaceMapView(place: place),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: iconColor.withOpacity(0.2), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: Offset(0, 2),
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
                children: [
                  Text(
                    place.name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF1A1A1A),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4),
                  Text(
                    place.amenity ?? place.shop ?? 'Lugar de interés',
                    style: TextStyle(fontSize: 12, color: Color(0xFF999999)),
                  ),
                  SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.my_location,
                        size: 12,
                        color: Color(0xFF999999),
                      ),
                      SizedBox(width: 4),
                      Text(
                        '${place.lat.toStringAsFixed(4)}, ${place.lon.toStringAsFixed(4)}',
                        style: TextStyle(
                          fontSize: 11,
                          color: Color(0xFF999999),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.near_me, color: Color(0xFF6C5CE7)),
          ],
        ),
      ),
    );
  }
}

extension SizedBoxSliver on SizedBox {
  Widget toSliver() {
    return SliverToBoxAdapter(child: this);
  }
}
