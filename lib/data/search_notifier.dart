//
// import 'package:flutter_riverpod/flutter_riverpod.dart';
//
// class TodoList extends StateNotifier<List<dynamic>> {
//   TodoList(): super(const []);
// }
//
// final todoListProvider = StateNotifierProvider((ref) => TodoList());
// final searchProvider = StateProvider((ref) => '');
//
// /// ホスト名等の検索設定
// final configProvider = StreamProvider<Configuration>(...);
//
// final charactersProvider = FutureProvider<List<Character>>((ref) async {
//   final search = ref.watch(searchProvider);
//   final configs = await ref.watch(configProvider.future);
//   final response = await dio.get('${configs.host}/characters?search=$search');
//
//   return response.data.map((json) => Character.fromJson(json)).toList();
// });