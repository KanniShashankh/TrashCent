import 'dart:math';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'pageMul/map.dart';

void main() {
  runApp(MyApp());
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
    PlaceholderWidget(Colors.green)
  ];

  Future<void> _openCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);

    if (pickedFile != null) {
      // Do something with the image file
    } else {
      print('No image selected.');
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
        title: Text('My Flutter App'),
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
                      content: Text('Your random reward points: ${Random().nextInt(100)}'),
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
                Icons.star,  // You can choose any icon you like
                size: 26.0,
              ),
            )
          ),
        ],
      ),
      body: _children[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        onTap: onTabTapped,
        currentIndex: _currentIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Colors.red[100],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'GPS',
            backgroundColor: Colors.red[100],
          ),
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () {
                _openCamera();
              },
              child: Icon(Icons.camera),
            ),
            label: 'Camera',
            backgroundColor: Colors.red[100],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'abc',
            backgroundColor: Colors.red[100],
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
            backgroundColor: Colors.red[100],
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
