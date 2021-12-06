import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  final String title;

  const Logo({
    Key key, 
    @required this.title}
    ) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          
          SizedBox(height: 20,),
          Container(
            width: 120,
            child: 
              Image(image: AssetImage('assets/images/icon.png')),
          ),
          SizedBox(height: 15,),
          Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor ),),
        ],
      ),
    );
  }
}