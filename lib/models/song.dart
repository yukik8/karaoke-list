class Song {
  final String id;
  final String name;
  final String previewUrl;
  final String artworkImgUrl;
  final String artistName;
  // final String releaseDate;
  // final String albumName;

  Song({
    required this.id,
    required this.name,
    required this.previewUrl,
    required this.artworkImgUrl,
    required this.artistName,
    // required this.releaseDate,
    // required this.albumName
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
        id: json['id'],
        name: json['attributes']['name'],
        previewUrl: json['attributes']['previews'][0]['url'],
        artworkImgUrl: json['attributes']['artwork']['url'],
        artistName: json['attributes']['artistName'],
    );
  }

  factory Song.fromBackendJson(Map<String, dynamic> json) {
    return Song(
      id: json['apple_music_id'],
      name: json['name'],
      artistName: json['artist_name'],
      artworkImgUrl: json['artwork_url'] ?? '',
      previewUrl: json['preview_url'] ?? '',
    );
  }

  String artworkUrl(int size) {
    return artworkImgUrl.replaceAll('{w}x{h}', "${size}x$size");
  }
}
