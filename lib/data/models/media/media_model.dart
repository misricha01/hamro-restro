/// A file uploaded via `POST /api/media`. `url` is relative (e.g.
/// `/uploads/xyz.jpg`) — resolve against `ApiClient.mediaBaseUrl` to get a
/// loadable image URL, mirroring how `RestaurantProfile.logoUrl` and other
/// nested media objects already work elsewhere in this app.
class UploadedMedia {
  final String id;
  final String? url;

  const UploadedMedia({required this.id, this.url});

  factory UploadedMedia.fromJson(Map<String, dynamic> json) {
    return UploadedMedia(
      id: json['id'].toString(),
      url: json['url'] as String?,
    );
  }
}
