import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:rxdart/rxdart.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({Key? key}) : super(key: key);

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _audioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> songs = [];
  String currentSongTiltle = '';
  String currentSongartist = '';
  int currentIndex = 0;
  bool isPlayingViewVisible = false;
  bool _islike = false;
   String _query="";
  void _changePlayerViewVisibility() {
    setState(() {
      isPlayingViewVisible = !isPlayingViewVisible;
    });
  }

  Stream<DurationState> get _durationStateStream =>
      Rx.combineLatest2<Duration, Duration?, DurationState>(
          _audioPlayer.positionStream,
          _audioPlayer.durationStream,
          (position, duration) => DurationState(
              position: position, total: duration ?? Duration.zero));
  @override
  void initState() {
    super.initState();
    Permission.storage.request();
    _audioPlayer.currentIndexStream.listen((index) {
      if (index != null) {
        _updateCurrentPlayingSongDetails(index);
      }

    });
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isPlayingViewVisible) {
      return Scaffold(
        backgroundColor: Colors.lightBlueAccent,
        body: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(top: 50.0, right: 20.0, left: 10.0),
            decoration: BoxDecoration(color: Colors.lightBlueAccent),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Flexible(
                        child: InkWell(
                      onTap: _changePlayerViewVisibility,
                      child: Container(
                        padding: const EdgeInsets.all(10.0),
                        decoration: getDecoration(
                            BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                        child: const Icon(
                          Icons.arrow_back_ios_new,
                          color: Colors.white70,
                        ),
                      ),
                    )),
                    SizedBox(
                      width: 10.0,
                    ),
                    Flexible(
                      child: Text(
                        currentSongTiltle,
                        style: const TextStyle(
                            color: Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 18),
                      ),
                      flex: 5,
                    )
                  ],
                ),
                Container(
                  width: 300,
                  height: 300,
                  decoration: getDecoration(
                      BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                  child: QueryArtworkWidget(
                    id: songs[currentIndex].id,
                    type: ArtworkType.AUDIO,
                    artworkBorder: BorderRadius.circular(200.0),
                  ),
                ),
                Column(
                  children: [
                    Container(
                      padding: EdgeInsets.zero,
                      margin: const EdgeInsets.only(bottom: 4.0, top: 4.0),
                      decoration: getRectDecoration(
                          BorderRadius.circular(20.0), Offset(2, 2), 2.0, 0.0),
                      child: StreamBuilder<DurationState>(
                        stream: _durationStateStream,
                        builder: (context, snapshot) {
                          final durationState = snapshot.data;
                          final progress =
                              durationState?.position ?? Duration.zero;
                          final total = durationState?.total ?? Duration.zero;
                          return ProgressBar(
                            progress: progress,
                            total: total,
                            barHeight: 10.0,
                            baseBarColor: Colors.white,
                            progressBarColor: const Color(0xEE19FA13),
                            thumbColor: Colors.white60.withBlue(99),
                            timeLabelTextStyle: const TextStyle(fontSize: 0),
                            onSeek: (duration) {
                              _audioPlayer.seek(duration);
                            },
                          );
                        },
                      ),
                    ),
                    StreamBuilder<DurationState>(
                      stream: _durationStateStream,
                      builder: (context, snapshot) {
                        final durationState = snapshot.data;
                        final progress =
                            durationState?.position ?? Duration.zero;
                        final total = durationState?.total ?? Duration.zero;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Flexible(
                                child: Text(
                              progress.toString().split(".")[0],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            )),
                            Flexible(
                                child: Text(
                              total.toString().split(".")[0],
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 15,
                              ),
                            )),
                          ],
                        );
                      },
                    )
                  ],
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20, bottom: 20),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          _changePlayerViewVisibility();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.list_alt,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          if (_audioPlayer.hasPrevious) {
                            _audioPlayer.seekToPrevious();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.skip_previous,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          if (_audioPlayer.playing) {
                            _audioPlayer.pause();
                          } else {
                            if (_audioPlayer.currentIndex != null) {
                              _audioPlayer.play();
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: StreamBuilder<bool>(
                            stream: _audioPlayer.playingStream,
                            builder: (context, snapshot) {
                              bool? playingstate = snapshot.data;
                              if (playingstate != null && playingstate) {
                                return const Icon(
                                  Icons.pause,
                                  size: 40,
                                  color: Colors.white70,
                                );
                              }
                              return const Icon(
                                Icons.play_arrow,
                                size: 40,
                                color: Colors.white70,
                              );
                            },
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          if (_audioPlayer.hasNext) {
                            _audioPlayer.seekToNext();
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.skip_next,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          _audioPlayer.setShuffleModeEnabled(true);
                          Fluttertoast.showToast(
                              msg: "Shuffling enabled",
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              timeInSecForIosWeb: 1,
                              backgroundColor: Colors.blue,
                              textColor: Colors.white,
                              fontSize: 16.0);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: const Icon(
                            Icons.shuffle,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        onTap: () {
                          _audioPlayer.loopMode == LoopMode.one
                              ? _audioPlayer.setLoopMode(LoopMode.all)
                              : _audioPlayer.setLoopMode(LoopMode.one);
                        },
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: getDecoration(
                                BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: StreamBuilder<LoopMode>(
                              stream: _audioPlayer.loopModeStream,
                              builder: (context, snapshot) {
                                final loopMode = snapshot.data;
                                if (LoopMode.one == loopMode) {
                                  return const Icon(
                                    Icons.repeat_one,
                                    color: Colors.white70,
                                  );
                                }
                                return const Icon(
                                  Icons.repeat,
                                  color: Colors.white70,
                                );
                              },
                            )),
                      )),
                    ],
                  ),
                )
              ],
            ),
          ),
        ),
      );
    }
    ;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.only(top: 40, left: 10, right: 10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Search for a music",
              style: TextStyle(
                color: Colors.blue,
                fontSize: 22.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 20.0,
            ),
            TextField(
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.lightBlueAccent,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(50.0),
                  borderSide: BorderSide.none,
                ),
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
              ),
            ),
            Expanded(
                  child: FutureBuilder<List<SongModel>>(
                      future: _audioQuery.querySongs(
                          sortType: null,
                          orderType: OrderType.ASC_OR_SMALLER,
                          uriType: UriType.EXTERNAL,
                          ignoreCase: true),
                      builder: (context, item) {
                        if (item.data == null) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (item.data!.isEmpty) {
                          return Center(child: Text("No Songs Found"));
                        }
                        songs.clear();
                        songs = item.data!;
                        return ListView.builder(
                          itemBuilder: (context, index) => ListTile(
                            leading: QueryArtworkWidget(
                              id: item.data![index].id,
                              type: ArtworkType.AUDIO,
                            ),
                            title: Text(item.data![index].displayNameWOExt),
                            subtitle: Text("${item.data![index].artist}"),
                            onTap: () async {
                              _changePlayerViewVisibility();
                              await _audioPlayer.setAudioSource(
                                  createPlaylist(item.data!),
                                  initialIndex: index);
                              await _audioPlayer.play();
                            },
                          ),
                          itemCount: item.data!.length,
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  ConcatenatingAudioSource createPlaylist(List<SongModel> songs) {
    List<AudioSource> sources = [];
    for (var song in songs) {
      sources.add(AudioSource.uri(Uri.parse(song.uri!)));
    }
    return ConcatenatingAudioSource(children: sources);
  }

  void _updateCurrentPlayingSongDetails(int index) {
    setState(() {
      if (songs.isNotEmpty) {
        currentSongTiltle = songs[index].title;
        currentSongartist = songs[index].artist!;
        currentIndex = index;
      }
    });
  }

  getDecoration(BoxShape shape, Offset offset, double d, double e) {
    return BoxDecoration(
        color: Colors.lightBlueAccent,
        shape: shape,
        boxShadow: [
          BoxShadow(
            offset: -offset,
            color: Colors.white24,
            blurRadius: d,
            spreadRadius: e,
          ),
          BoxShadow(
            offset: offset,
            color: Colors.black,
            blurRadius: d,
            spreadRadius: e,
          )
        ]);
  }

  BoxDecoration getRectDecoration(
      BorderRadius borderRadius, Offset offset, double i, double j) {
    return BoxDecoration(
        borderRadius: borderRadius,
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            offset: -offset,
            color: Colors.white24,
            blurRadius: i,
            spreadRadius: j,
          ),
          BoxShadow(
            offset: offset,
            color: Colors.black,
            blurRadius: i,
            spreadRadius: j,
          )
        ]);
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
