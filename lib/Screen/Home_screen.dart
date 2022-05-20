import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:favorite_button/favorite_button.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gallery/Screen/FavoriteScreen.dart';
import 'package:gallery/Songs.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import '../Database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _audioQuery = new OnAudioQuery();
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<SongModel> songs = [];
  String currentSongTiltle = '';
  String currentSongartist = '';
  int currentIndex = 0;
  bool isPlayingViewVisible = false;
  bool _islike = false;
  late DB db;
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
    db = DB();
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
                            size: 40,
                            color: Colors.white70,
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: StreamBuilder<SequenceState?>(
                            stream: _audioPlayer.sequenceStateStream,
                            builder: (_, __) {
                              return _previousButton();
                            },
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
                        child: Container(
                          padding: const EdgeInsets.all(10.0),
                          decoration: getDecoration(
                              BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                          child: StreamBuilder<SequenceState?>(
                            stream: _audioPlayer.sequenceStateStream,
                            builder: (_, __) {
                              return _nextButton();
                            },
                          ),
                        ),
                      )),
                      Flexible(
                          child: InkWell(
                        child: Container(
                            padding: const EdgeInsets.all(10.0),
                            decoration: getDecoration(
                                BoxShape.circle, const Offset(2, 2), 2.0, 0.0),
                            child: StreamBuilder<bool>(
                              stream: _audioPlayer.shuffleModeEnabledStream,
                              builder: (context, snapshot) {
                                return _shuffleButton(
                                    context, snapshot.data ?? false);
                              },
                            )),
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
                                return _repeatButton(
                                    context, snapshot.data ?? LoopMode.off);
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
      body: Column(
        children: [
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
                    selected: true,
                    leading: QueryArtworkWidget(
                      id: item.data![index].id,
                      type: ArtworkType.AUDIO,
                    ),
                    title: Text(item.data![index].displayNameWOExt),
                    subtitle: Text("${item.data![index].artist}"),
                    trailing: FavoriteButton(
                      iconSize: 40.0,
                      isFavorite: false,
                      valueChanged: (_isFavorite) {},
                    ),
                    onTap: () async {
                      db.insertData(Songs(
                          img: 'ok',
                          artist: item.data![index].artist.toString(),
                          displayNameWOExt:
                              item.data![index].displayNameWOExt.toString()));
                      // _changePlayerViewVisibility();
                      // await _audioPlayer.setAudioSource(
                      //     createPlaylist(item.data!),
                      //     initialIndex: index);
                      // await _audioPlayer.play();
                    },
                  ),
                  itemCount: item.data!.length,
                );
              },
            ),
          ),
        ],
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

  Widget _shuffleButton(BuildContext context, bool isEnabled) {
    return IconButton(
      icon: isEnabled
          ? Icon(Icons.shuffle, color: Theme.of(context).accentColor)
          : Icon(Icons.shuffle),
      onPressed: () async {
        final enable = !isEnabled;
        if (enable) {
          await _audioPlayer.shuffle();
        }
        await _audioPlayer.setShuffleModeEnabled(enable);
      },
    );
  }

  Widget _repeatButton(BuildContext context, LoopMode loopMode) {
    final icons = [
      Icon(Icons.repeat),
      Icon(Icons.repeat, color: Theme.of(context).accentColor),
      Icon(Icons.repeat_one, color: Theme.of(context).accentColor),
    ];
    const cycleModes = [
      LoopMode.off,
      LoopMode.all,
      LoopMode.one,
    ];
    final index = cycleModes.indexOf(loopMode);
    return IconButton(
      icon: icons[index],
      onPressed: () {
        _audioPlayer.setLoopMode(
            cycleModes[(cycleModes.indexOf(loopMode) + 1) % cycleModes.length]);
      },
    );
  }

  Widget _previousButton() {
    return IconButton(
      icon: Icon(Icons.skip_previous),
      onPressed: _audioPlayer.hasPrevious ? _audioPlayer.seekToPrevious : null,
    );
  }

  Widget _nextButton() {
    return IconButton(
      icon: Icon(Icons.skip_next),
      onPressed: _audioPlayer.hasNext ? _audioPlayer.seekToNext : null,
    );
  }
}

class DurationState {
  DurationState({this.position = Duration.zero, this.total = Duration.zero});
  Duration position, total;
}
