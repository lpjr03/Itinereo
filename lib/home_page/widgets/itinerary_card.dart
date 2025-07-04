import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

/// A card widget that displays a static preview of a location on a map,
/// along with a title and a "Map" button to trigger a full map view.
///
/// This widget uses the Google Maps Static API to render a
/// map image based on the first marker in the list.
///
/// Requires an `API_KEY` to be defined in the `.env` file.
class ItineraryCard extends StatelessWidget {
  /// List of [Marker]s used to determine the static map preview location.
  /// Only the first marker is used for rendering the image.
  final List<Marker> markers;

  /// Callback function executed when the "Map" button is pressed.
  final VoidCallback onTap;

  /// Title shown at the bottom of the card.
  final String title;

  /// Creates an [ItineraryCard] that shows a preview of a destination on the map
  const ItineraryCard({
    super.key,
    required this.markers,
    required this.onTap,
    required this.title,
  });

  /// Builds a Google Static Maps URL for the given latitude and longitude.
  ///
  /// The image includes a red marker and is rendered with zoom 13,
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
    final imageUrl =
        (markers.isNotEmpty)
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
      shadowColor: Colors.black12,
      child: SizedBox(
        width: 200,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Static map preview
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: 5 / 2,
                  child:
                      imageUrl != null
                          ? Image.network(
                            imageUrl,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (_, __, ___) => Container(
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                          )
                          : Container(
                            color: Colors.grey[200],
                            child: const Icon(Icons.map_outlined),
                          ),
                ),
              ),
              const SizedBox(height: 8),

              // Title + Map button row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      title,
                      style: GoogleFonts.libreBaskerville(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF385A55),
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onTap,
                    icon: const Icon(
                      Icons.map,
                      size: 16,
                      color: Color(0xFF73370F),
                    ),
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
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
