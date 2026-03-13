import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Đọc truyện",
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

  @override
  void initState() {
    super.initState();
    loadStories();
  }

  Future loadStories() async {

    var res = await http.get(Uri.parse("https://xtruyen.vn"));

    var document = parse(res.body);

    var items = document.querySelectorAll(".story-item");

    setState(() {
      stories = items.map((e) {
        return {
          "title": e.querySelector("h3")?.text ?? "",
          "link": e.querySelector("a")?.attributes["href"] ?? "",
          "cover": e.querySelector("img")?.attributes["src"] ?? ""
        };
      }).toList();
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: const Text("Đọc truyện")),
      body: ListView.builder(
        itemCount: stories.length,
        itemBuilder: (context,index){

          var s = stories[index];

          return ListTile(

            leading: Image.network(
              s["cover"],
              width: 50,
              fit: BoxFit.cover,
            ),

            title: Text(s["title"]),

            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=>StoryPage(
                    title: s["title"],
                    url: s["link"],
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

class StoryPage extends StatefulWidget {

  final String title;
  final String url;

  const StoryPage({
    super.key,
    required this.title,
    required this.url
  });

  @override
  State<StoryPage> createState() => _StoryPageState();
}

class _StoryPageState extends State<StoryPage> {

  List chapters = [];

  @override
  void initState() {
    super.initState();
    loadChapters();
  }

  Future loadChapters() async {

    var res = await http.get(Uri.parse(widget.url));

    var document = parse(res.body);

    var items = document.querySelectorAll(".chapter a");

    setState(() {

      chapters = items.map((c){

        return {
          "title": c.text,
          "link": c.attributes["href"]
        };

      }).toList();

    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context,index){

          var c = chapters[index];

          return ListTile(

            title: Text(c["title"]),

            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context)=>ReaderPage(
                    title: c["title"],
                    url: c["link"],
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

  final String title;
  final String url;

  const ReaderPage({
    super.key,
    required this.title,
    required this.url
  });

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {

  String content = "";

  @override
  void initState() {
    super.initState();
    loadChapter();
  }

  Future loadChapter() async {

    var res = await http.get(Uri.parse(widget.url));

    var document = parse(res.body);

    var chapter = document.querySelector(".chapter-content");

    setState(() {
      content = chapter?.text ?? "Không tải được chương";
    });

  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Text(
          content,
          style: const TextStyle(
            fontSize: 18,
            height: 1.6,
          ),
        ),
      ),
    );

  }

}