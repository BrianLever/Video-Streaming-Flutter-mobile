import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:americonictv_mobile/data/auth/user_data.dart';
import 'package:americonictv_mobile/logic/api/models/favorites.dart';
import 'package:americonictv_mobile/logic/api/models/watch_later.dart';
import 'models/category_model.dart';
import 'models/series_model.dart';
import 'models/thumb_model.dart';
import 'models/videos_response.dart';

abstract class VideosAPI {
  static Future<VideosResponse> getLatest([int page]) async =>
      videosResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=video&sort[created]=desc&rowCount=' +
                  (page == null ? '8' : '60&current=$page')))
          .body);

  static Future<VideosResponse> getTrending() async =>
      videosResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=video&sort[likes]=desc&rowCount=30'))
          .body);

  static Future<CategoryResponse> getCategories() async =>
      categoryResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=categories'))
          .body);

  static Future<VideosResponse> getVideosByCategory(
          String categoryName, int page, [int series]) async =>
      videosResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=video&APISecret=b50659819eb61ceae567ecd5dd51ea31&catName=$categoryName&rowCount=60&current=$page' +
                  (series == null ? '' : '&is_serie=$series')))
          .body);

  static Future<SeriesResponse> getVideosByPlaylist(int seriePlaylistId) async {

    return SeriesResponseFromJson((await http.get(Uri.parse('https://video.americonictv.com/plugin/API/get.json.php?APIName=video_from_program'
        '&playlists_id=$seriePlaylistId&APISecret=b50659819eb61ceae567ecd5dd51ea31'))).body);
  }

  static Future<ThumbResponse> getThumb(int videosID) async {

    return thumbResponseFromJson((await http.get(Uri.parse('https://video.americonictv.com/plugin/API/get.json.php?APIName=video_file'
        '&videos_id=$videosID&APISecret=b50659819eb61ceae567ecd5dd51ea31'))).body);
  }


  static Future getLivestreams() async => jsonDecode((await http.get(
          'https://video.americonictv.com/plugin/API/get.json.php?APIName=livestreams'))
      .body);

  static Future<VideosResponse> getChannelVideos(
          String channel, int page) async =>
      videosResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=video&rowCount=60&channelName=$channel&current=$page'))
          .body);

  static Future<VideosResponse> searchVideos(String searchTerm, int page,
          [int series]) async =>
      videosResponseFromJson((await http.get(
              'https://video.americonictv.com/plugin/API/get.json.php?APIName=video&rowCount=60&current=$page&searchPhrase=$searchTerm' +
                  (series == null ? '' : '&is_serie=$series')))
          .body);

  static Future<WatchLater> getWatchLater([int page = 1]) async {
    final decoded = jsonDecode((await http.get(
            'https://video.americonictv.com/plugin/API/get.json.php?APIName=watch_later&user='
            '${User.instance.user}&pass=${User.instance.pass}&encodedPass=true&rowCount=60&page=$page'))
        .body);
    print(decoded);
    try {
      return WatchLater.fromMap(decoded[0]);
    } catch (e) {
      print(e);
      throw 'No videos found.';
    }
  }

  static Future<Favorites> getFavorites([int page = 1]) async {
    final decoded = jsonDecode((await http.get(
            'https://video.americonictv.com/plugin/API/get.json.php?APIName=favorite&user='
            '${User.instance.user}&pass=${User.instance.pass}&encodedPass=true&rowCount=60&page=$page'))
        .body);
    print(decoded);
    return Favorites.fromMap(decoded[0]);
  }
}
