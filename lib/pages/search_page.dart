import 'package:flutter/material.dart';
import 'package:untitled/services/fetch_function.dart';
import '../models/song.dart';
import 'register_page.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);
  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  String onChangedText = '';
  String onFieldSubmittedText = '';
  final textController = TextEditingController();
  var _isLoading = false;
  var hasError = false;
  var _isEmpty = false;
  var _pageNumbers = 0;
  ScrollController? _scrollController;
  final List<Song> fetchedSearches = [];
  List<Song> newSearches = [];
  final apple = AppleMusicStore.instance;


  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // fetchFunction();
    _scrollController!.addListener(_scrollListener);
  }



  void _scrollListener() async {
    if (_scrollController != null) {
      double positionRate = _scrollController!.offset /
          _scrollController!.position.maxScrollExtent;
      const threshold = 0.9;
      if (positionRate > threshold && !_isLoading && _pageNumbers < 5) {
        fetchFunction(0);
      }
    }
  }

  Future<void> fetchFunction(int n) async {
    if (!_isLoading) {
      setState(() {
        _isEmpty = false;
        _isLoading = true;
        _pageNumbers++;
      });
      try {
        if(n==1){
          setState(() {
            _pageNumbers = 1;
          });
        }
        newSearches = await apple.search(onFieldSubmittedText, _pageNumbers);
      } catch (e) {
        // print("Error: $e");
        setState(() {
          hasError = true;
        });
      } finally {
        setState(() {
          fetchedSearches.addAll(newSearches);
          _isLoading = false;
        });
      }
    }
  }

  Widget _listView(List<Song> items) {
    return RefreshIndicator(
      color: Colors.grey,
      backgroundColor: const Color(0xFFFFFFFF),
      onRefresh: () async{
        // setState(() {
        //   _pageNumbers = 1;
        // });
        await fetchFunction(1);
      },
      child: ListView.builder(
        controller: _scrollController,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        itemCount: _isLoading ? items.length + 1 : items.length,
        itemBuilder: (context, index) {
          if (index == items.length) {
            return _loadingView();
          }
          // if (index > items.length) {
          //
          //   return SizedBox(); // 何も表示しない場合は空のSizedBoxを返す
          // }

            return ElevatedButton(
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
              elevation: MaterialStateProperty.all(0),
            ),
            onPressed: (){
              showModalBottomSheet<void>(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  isScrollControlled: true,
                  context: context,
                  builder: (BuildContext context) {



                    return Container(
                        decoration: const BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            )),
                        height: MediaQuery.of(context).size.height * 0.9,
                      child: RegisterPage(
                        preUrl: items[index].previewUrl,
                        name: items[index].name,
                        id: items[index].id,
                        imgUrl: items[index].artworkImgUrl,
                        artistName: items[index].artistName,
                      ),
                    );
                  });
            },
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                   SizedBox(
                     child: Image.network(
                Song(id: items[index].id, name: items[index].name, previewUrl: items[index].previewUrl, artworkImgUrl: items[index].artworkImgUrl, artistName: items[index].artistName).artworkUrl(40))),
                    const SizedBox(
                      width: 8,
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(items[index].artistName,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF828282)),
                          ),
                          Text(
                            items[index].name,
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 9,),
                        ],
                      ),
                    ),
                  ],
                ),
                const Divider(height: 10,thickness: 2,),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _textField() {
    return TextFormField(
      autocorrect: true,
      controller: textController,
      decoration: InputDecoration(
        hintText: 'Search',
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          onPressed: () => textController.clear(), //リセット処理
          icon: const Icon(Icons.clear),
        ),
        isDense: true,
        contentPadding: const EdgeInsets.fromLTRB(10, 12, 12, 10),
        hintStyle: const TextStyle(
          color: Color(0x993C3C43),
          fontSize: 17,
        ),
        filled: true,
        fillColor: const Color(0x1F767680),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0x1F767680), width: 0),
        ),
      ),
      // フィールドのテキストが変更される度に呼び出される
      onChanged: (value) {
        setState(() {
          onChangedText = value;
        });
      },
      // ユーザーがフィールドのテキストの編集が完了したことを示したときに呼び出される
      onFieldSubmitted: (value) async {
        setState(() {
          onFieldSubmittedText = value;
          fetchedSearches.clear();
          _pageNumbers = 0;
          _isEmpty = false;
        });
        await fetchFunction(0);
        if (fetchedSearches.isEmpty) {
          setState(() {
            _isEmpty = true;
          });
        }
      },
    );
  }

  Widget _emptyView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 3,
      child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '検索にマッチする曲はありませんでした。',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            SizedBox(height: 17),
            Text(
              '検索条件を変え、再度検索します。',
              style: TextStyle(
                fontSize: 12,
                color: Color(0xFF828282),
              ),
            )
          ]),
    );
  }

  Widget _loadingView() {
    return const Center(
      child: CircularProgressIndicator(
        color: Colors.grey,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Search",
          style: TextStyle(
              color: Color(0xffC57E14)
          ),
        ),
        backgroundColor: Colors.white,
      ),
      body: hasError
          ? const Center(child: Text("Error"))
          :GestureDetector(
        onTap: () => WidgetsBinding.instance.focusManager.primaryFocus?.unfocus(),
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  child: _textField()),
            ),
            // Padding(
            //   padding: const EdgeInsets.fromLTRB(13,0,13,0),
            //   child: const Divider(height: 0.5,thickness: 2,),
            // ),
            const Divider(height: 0.5,thickness: 1,),
            SizedBox(
              height: 8,
              child: Container(
                color: Colors.white,
              ),
            ),
            Expanded(
              child: onFieldSubmittedText == ''
                  ?  const SizedBox(
                child:  Padding(
                  padding: EdgeInsets.fromLTRB(0,50,0,0),
                  child: Text('検索ワードを入力します。',
                  style: TextStyle(
                      // color: Color(0xff333333),
                    fontFamily: 'Noto_Sans_JP',
                  ),
                  ),
                ),)
                  : _isEmpty
                  ? _emptyView()
                  : _isLoading && _pageNumbers == 1
                  ? _loadingView()
                  : _listView(fetchedSearches),
            )
          ],
        ),
      )
    );
  }
}
