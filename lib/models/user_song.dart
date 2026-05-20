import 'song.dart';
import 'singing_history_item.dart';

class UserSong {
  final String id;
  final Song song;
  final String? key;
  final int? season;
  final List<String> tags;
  final DateTime createdAt;
  List<SingingHistoryItem> history;

  UserSong({
    required this.id,
    required this.song,
    this.key,
    this.season,
    required this.tags,
    required this.createdAt,
    required this.history,
  });

  factory UserSong.fromJson(Map<String, dynamic> json) {
    final songJson = json['song'] as Map<String, dynamic>;
    return UserSong(
      id: json['id'],
      song: Song(
        id: songJson['apple_music_id'] ?? songJson['id'],
        name: songJson['name'],
        previewUrl: songJson['preview_url'] ?? '',
        artworkImgUrl: songJson['artwork_url'] ?? '',
        artistName: songJson['artist_name'],
      ),
      key: json['key'],
      season: json['season'],
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      createdAt: DateTime.parse(json['created_at']),
      history: (json['history'] as List<dynamic>?)
              ?.map((h) => SingingHistoryItem.fromJson(h as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toCreateJson() => {
        'song': {
          'apple_music_id': song.id,
          'name': song.name,
          'artist_name': song.artistName,
          'artwork_url': song.artworkImgUrl,
          'preview_url': song.previewUrl,
        },
        if (key != null) 'key': key,
        if (season != null) 'season': season,
        if (tags.isNotEmpty) 'tags': tags,
      };
}
