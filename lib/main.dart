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
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
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

  loadStories() async {

    var res = await http.get(Uri.parse("https://xtruyen.vn"));

    var document = parse(res.body);

    var items = document.querySelectorAll(".story-item");

    setState(() {

      stories = items.map((e){

        return {
          "title": e.querySelector("h3")?.text ?? "",
          "link": e.querySelector("a")?.attributes["href"] ?? ""
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

        itemBuilder: (c,i){

          return ListTile(
            title: Text(stories[i]["title"]),
          );

        },

      ),

    );

  }
}
