import 'package:flutter/material.dart';

class TermsAndServicesScreen extends StatelessWidget {
  const TermsAndServicesScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
     Size screenSize=MediaQuery.of(context).size;
    return SizedBox(
      height: screenSize.height,
      child: Column(
        children:const [
          Text("VIGEZO NA MASHARTI")
        ],
      ),
    );
  }
}