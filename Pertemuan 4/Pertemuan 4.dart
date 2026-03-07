import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(
    MyApp(),
    );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: const Color.fromARGB(255, 8, 33, 90),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 50,
                backgroundImage: AssetImage(
                  'images/profil.jpg'
                ),
              ),
              Text("Septiana Daw", 
                  style: GoogleFonts.pacifico(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
              ),),
              Text("MAHASISWA TIF", 
                  style: GoogleFonts.sourceSans3(
                    fontSize: 20,
                    color: const Color.fromARGB(255, 195, 210, 249),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.5,
              ),),
              SizedBox(
                height: 20,
                width: 200,
                child: Divider(
                  color: const Color.fromARGB(255, 195, 210, 249),
                ),
              ),
              // Container nomor phone
              Container(
                padding:EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
              ),
                margin: EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 25
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.phone,
                      color: const Color.fromARGB(255, 8, 33, 90),
                    ),
                    SizedBox(width: 10),
                  Text(
                    "081234567890",
                    style: GoogleFonts.sourceSans3(fontSize: 20,
                    color: const Color.fromARGB(255, 8, 33, 90)
                     ),
                    ),
                  ],
                ),
              ),

              // Container Email
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(5),
              ),
                margin: EdgeInsets.symmetric(
                  vertical: 10, 
                  horizontal: 25
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: const Color.fromARGB(255, 8, 33, 90),
                    ),
                    SizedBox(width: 10),
                    Text(
                      "septi13@gmail.com",
                      style: GoogleFonts.sourceSans3(fontSize: 20,
                      color: const Color.fromARGB(255, 8, 33, 90)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


