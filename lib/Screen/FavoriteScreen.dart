import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:gallery/App.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:provider/provider.dart';

import '../Database.dart';
import '../Songs.dart';

class FavoriteScreen extends StatefulWidget {
  const FavoriteScreen({Key? key}) : super(key: key);

  @override
  State<FavoriteScreen> createState() => _FavoriteScreenState();
}

class _FavoriteScreenState extends State<FavoriteScreen> {
  late DB db;
  List<Songs> datas=[];
  @override
  void initState() {
    super.initState();
    db=DB();
    getData2();
    }

  void getData2() async{
    datas=await db.getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favorite"),
      ),
      body: ListView.builder(
        itemBuilder: (context,index)=>ListTile(
          leading: CircleAvatar(),
          title: Text(datas[index].displayNameWOExt),
          subtitle: Text(datas[index].artist),
          trailing: FavoriteButton(
            iconSize: 40.0,
            isFavorite: false,
            valueChanged: (_isFavorite){
            },
          ),

        ),
        itemCount: datas.length,
      )
    );
  }
}
