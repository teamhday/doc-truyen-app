import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Đọc truyện",
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  List stories = [];
  List filtered = [];
  TextEditingController search = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  loadStories() async {

    var res = await http.get(
      Uri.parse("https://xtruyen.vn"),
      headers: {"User-Agent": "Mozilla/5.0"}
    );

    var document = parse(res.body);

    var items = document.querySelectorAll("h3 a");

    stories = items.map((e){
      return {
        "title": e.text.trim(),
        "link": e.attributes["href"]
      };
    }).toList();

    setState(() {
      filtered = stories;
    });

  }

  searchStory(String text){

    setState(() {
      filtered = stories
          .where((s)=>s["title"]
          .toLowerCase()
          .contains(text.toLowerCase()))
          .toList();
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("Đọc truyện"),
      ),

      body: Column(
        children: [

          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              controller: search,
              onChanged: searchStory,
              decoration: const InputDecoration(
                hintText: "Tìm truyện...",
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (c,i){

                return ListTile(

                  title: Text(filtered[i]["title"]),

                  onTap: (){
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChapterPage(
                          url: filtered[i]["link"],
                          title: filtered[i]["title"],
                        ),
                      ),
                    );
                  },

                );

              },
            ),
          )

        ],
      ),

    );

  }
}

class ChapterPage extends StatefulWidget {

  final String url;
  final String title;

  const ChapterPage({
    super.key,
    required this.url,
    required this.title
  });

  @override
  State<ChapterPage> createState() => _ChapterPageState();
}

class _ChapterPageState extends State<ChapterPage> {

  List chapters = [];

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  loadChapters() async {

    var res = await http.get(
      Uri.parse(widget.url),
      headers: {"User-Agent": "Mozilla/5.0"}
    );

    var document = parse(res.body);

    var items = document.querySelectorAll(".chapter a");

    setState(() {

      chapters = items.map((e){

        return {
          "title": e.text,
          "link": e.attributes["href"]
        };

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: ListView.builder(

        itemCount: chapters.length,

        itemBuilder: (c,i){

          return ListTile(

            title: Text(chapters[i]["title"]),

            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReaderPage(
                    url: chapters[i]["link"],
                    title: chapters[i]["title"],
                  ),
                ),
              );
            },

          );

        },

      ),

    );

  }
}

class ReaderPage extends StatefulWidget {

  final String url;
  final String title;

  const ReaderPage({
    super.key,
    required this.url,
    required this.title
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {

  String content = "Đang tải...";

  @override
  void initState() {
    super.initState();
    loadChapter();
  }

  loadChapter() async {

    SharedPreferences prefs =
        await SharedPreferences.getInstance();

    String? cached = prefs.getString(widget.url);

    if(cached != null){
      setState(() {
        content = cached;
      });
      return;
    }

    var res = await http.get(
      Uri.parse(widget.url),
      headers: {"User-Agent": "Mozilla/5.0"}
    );

    var document = parse(res.body);

    var text =
        document.querySelector(".chapter-content")?.text ?? "";

    prefs.setString(widget.url, text);

    setState(() {
      content = text;
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: Text(widget.title),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: SingleChildScrollView(

          child: Text(
            content,
            style: const TextStyle(
              fontSize: 20,
              height: 1.8,
            ),
          ),

        ),

      ),

    );

  }
}