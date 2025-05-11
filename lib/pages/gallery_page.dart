// pages/gallery_page.dart
import 'package:flutter/material.dart';

class GalleryPage extends StatelessWidget {
  // Example: Assume you have a list of image paths for an event
  // In a real app, you might load this from a JSON file or define it more dynamically
  final List<String> eventImages = [
    'assets/images/gallery/sports_day/image1.jpg',
    'assets/images/gallery/sports_day/image2.jpg',
    'assets/images/gallery/sports_day/image3.jpg',
    'assets/images/gallery/annual_function/image1.jpg',
    'assets/images/gallery/annual_function/image2.jpg',
    // Add more images
  ];

  // You could also structure this with event names and lists of images
  final Map<String, List<String>> events = {
    "Sports Day 2024": [
      'assets/images/gallery/sports_day/image1.jpg',
      'assets/images/gallery/sports_day/image2.jpg',
      'assets/images/gallery/sports_day/image3.jpg',
    ],
    "Annual Function 2023": [
      'assets/images/gallery/annual_function/image1.jpg',
      'assets/images/gallery/annual_function/image2.jpg',
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('School Gallery')),
      body: ListView.builder(
        itemCount: events.keys.length,
        itemBuilder: (context, index) {
          String eventName = events.keys.elementAt(index);
          List<String> images = events[eventName]!;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(eventName, style: Theme.of(context).textTheme.headlineSmall),
              ),
              GridView.builder(
                shrinkWrap: true, // Important for GridView inside ListView
                physics: NeverScrollableScrollPhysics(), // Disable GridView's scrolling
                padding: EdgeInsets.all(8.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: MediaQuery.of(context).size.width > 800 ? 4 : (MediaQuery.of(context).size.width > 500 ? 3 : 2), // Responsive columns
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemCount: images.length,
                itemBuilder: (context, imageIndex) {
                  return GestureDetector(
                    onTap: () {
                      // Show full image view
                      showDialog(
                        context: context,
                        builder: (_) => Dialog(
                          child: Stack(
                            alignment: Alignment.topRight,
                            children: [
                              Image.asset(images[imageIndex], fit: BoxFit.contain),
                              IconButton(
                                icon: Icon(Icons.close, color: Colors.white, size: 30),
                                onPressed: () => Navigator.of(context).pop(),
                                color: Colors.black.withOpacity(0.5),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                    child: Card(
                      elevation: 2.0,
                      child: Image.asset(
                        images[imageIndex],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
              Divider(),
            ],
          );
        },
      ),
    );
  }
}