import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pageMul/map.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
// import 'package:fluttertoast/fluttertoast.dart';

// GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// void main() => runApp(
//       MaterialApp(
//         builder: FToastBuilder(),
//         home: MyApp(),
//         navigatorKey: navigatorKey,
//       ),
//     );
void main() {
  runApp(MyApp());
}

class Prediction {
  final List<double> class_probabilities;
  final double max_probability;
  final String predicted_class;

  const Prediction(
      {required this.class_probabilities,
      required this.max_probability,
      required this.predicted_class});

  factory Prediction.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'class_probabilities': List<double> class_probabilities,
        'maximum_probability': double max_probability,
        'predicted_class': String predicted_class,
      } =>
        Prediction(
            class_probabilities: class_probabilities,
            max_probability: max_probability,
            predicted_class: predicted_class),
      _ => throw const FormatException('Failed to load TrashNet.'),
    };
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;
  final List<Widget> _children = [
    GridView.count(
      crossAxisCount: 2,
      children: List.generate(4, (index) {
        return Center(
          child: Card(
            child: InkWell(
              onTap: () {
                print('Card $index tapped');
              },
              child: Container(
                width: 150,
                height: 150,
                child: Center(child: Text('Tile $index')),
              ),
            ),
          ),
        );
      }),
    ),
    MapPage(),
    PlaceholderWidget(Colors.green),
    PlaceholderWidget(Colors.red)
  ];
  Future<void> _openCamera() async {
    final picker = ImagePicker();

    try {
      final pickedFile = await picker.pickImage(source: ImageSource.camera);

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        List<int> imageBytes = await imageFile.readAsBytes();
        String base64Image = base64Encode(imageBytes);

        print("Sending image to API");
        print(base64Image);

        try {
          final response = await http.post(
            Uri.parse('http://10.10.8.83:3000/predict'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({'image': base64Image}),
          );

          if (response.statusCode == 200) {
            // print('Image uploaded successfully');
            var data = jsonDecode(response.body);
            // print(jsonDecode(response.body));
            showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: Text('Model Prediction'),
                  content: Text(
                      'Your Trash is classified as : ${data['predicted_class']}'),
                  actions: <Widget>[
                    TextButton(
                      child: Text('Close'),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ],
                );
              },
            );
          } else {
            print('Error uploading image. Status code: ${response.statusCode}');
          }
        } catch (e) {
          print('Error sending HTTP request: $e');
        }
      } else {
        print('No image selected.');
      }
    } catch (e) {
      print('Error picking image: $e');
    }
  }

  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'TrashCent',
        ),
        backgroundColor: Colors.grey,
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text('Reward Points'),
                        content: Text(
                            'Your random reward points: ${Random().nextInt(100)}'),
                        actions: <Widget>[
                          TextButton(
                            child: Text('Close'),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      );
                    },
                  );
                },
                child: Icon(
                  Icons.star, // You can choose any icon you like
                  size: 26.0,
                ),
              )),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red,
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.map_outlined),
            label: 'Bin Locator',
            backgroundColor: Colors.red,
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                _openCamera();
              },
              child: Icon(Icons.camera),
            ),
            label: 'Camera',
            backgroundColor: Colors.red,
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.person),
          //   label: 'abc',
          //   backgroundColor: Colors.red,
          // ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.red,
          )
        ],
      ),
    );
  }
}

class PlaceholderWidget extends StatelessWidget {
  final Color color;

  PlaceholderWidget(this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: color,
    );
  }
}
