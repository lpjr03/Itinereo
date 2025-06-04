import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ItineraryCard extends StatelessWidget {
  final List<Marker> markers;
  final VoidCallback onTap;

  const ItineraryCard({
    super.key,
    required this.markers,
    required this.onTap,
  });

  String buildStaticMapUrl(double lat, double lng) {
    final apiKey = dotenv.env['API_KEY'];
    return 'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng'
        '&zoom=13'
        '&size=300x120'
        '&scale=2'
        '&maptype=roadmap'
        '&markers=color:red%7Clabel:I%7C$lat,$lng'
        '&key=$apiKey';
  }

  @override
  Widget build(BuildContext context) {

    final imageUrl = (markers.isNotEmpty)
        ? buildStaticMapUrl(
            markers.first.position.latitude,
            markers.first.position.longitude,
          )
        : null;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      color: const Color.fromARGB(255, 255, 244, 217),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.2),
      child: SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: imageUrl != null
                    ? Image.network(
                        imageUrl,
                        height: 98,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 80,
                          color: Colors.grey[300],
                          child: const Icon(Icons.broken_image),
                        ),
                      )
                    : Container(
                        height: 80,
                        width: double.infinity,
                        color: Colors.grey[200],
                        child: const Icon(Icons.map_outlined),
                      ),
              ),
              const SizedBox(height: 8),

              Align(
                alignment: Alignment.bottomRight,
                child: TextButton.icon(
                  onPressed: onTap,
                  icon: const Icon(Icons.map, size: 16, color: Color(0xFF73370F)),
                  label: Text(
                    'Map',
                    style: GoogleFonts.libreBaskerville(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF73370F),
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(60, 30),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
