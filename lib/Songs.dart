class Songs{
 final int? id;
  final String img,displayNameWOExt,artist;
  Songs({this.id,required this.img,required this.artist,required this.displayNameWOExt});
  factory Songs.fromMap(Map<String,dynamic> json)=>
      Songs(id: json['id'],img:json["img"], artist: json["artist"], displayNameWOExt: json["displayNameWOExt"]);
  Map<String,dynamic>toMap()=>{
   "id":id,
   "img":img,
   "displayNameWOExt":displayNameWOExt,
   "artist":artist,
};
}