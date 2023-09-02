import 'song.dart';
class Chart {
  final String chart;
  final String href;
  final String name;
  final List<Song> songs;

  Chart({
    required this.chart,
    required this.href,
    required this.name,
    required this.songs
  });

  factory Chart.fromJson(Map<String, dynamic> json) {
    final songJson = json['data'] as List;
    final songs = songJson.map((s) => Song.fromJson(s)).toList();
    print(songs);

    return Chart(
        chart: json['chart'],
        href: json['href'],
        name: json['name'],
        songs: songs);
  }
}