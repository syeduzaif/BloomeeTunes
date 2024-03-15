import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Bloomee/model/songModel.dart';
import 'package:Bloomee/screens/screen/library_views/cubit/current_playlist_cubit.dart';
import 'package:Bloomee/screens/widgets/horizontalSongCard_widget.dart';
import 'package:Bloomee/screens/widgets/playPause_widget.dart';
import 'package:Bloomee/services/db/MediaDB.dart';
import 'package:Bloomee/services/db/cubit/mediadb_cubit.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/utils/load_Image.dart';

import '../../../blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'dart:ui';

class PlaylistView extends StatelessWidget {
  String playListName;

  PlaylistView({
    Key? key,
    required this.playListName,
  }) : super(key: key) {
    print("Showing playlist: $playListName");
  }
  Future<void> setUpPlaylist(BuildContext context) async {
    context.read<CurrentPlaylistCubit>().loadPlaylist(playListName);
  }

  @override
  Widget build(BuildContext context) {
    setUpPlaylist(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 0),
        elevation: 0,
        foregroundColor: Default_Theme.primaryColor1,
      ),
      body: BlocBuilder<CurrentPlaylistCubit, CurrentPlaylistState>(
        builder: (context, state) {
          if (state is! CurrentPlaylistInitial && state.mediaItems.isNotEmpty) {
            return Column(
              children: [
                SizedBox(
                  height: 380,
                  child: Stack(
                    children: [
                      Opacity(
                        opacity: 0.5,
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width,
                          height: 260,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.blueAccent.shade400,
                                boxShadow: [
                                  BoxShadow(
                                    color: context
                                            .read<CurrentPlaylistCubit>()
                                            .getCurrentPlaylistPallete()
                                            ?.lightVibrantColor
                                            ?.color ??
                                        Colors.blue,
                                    blurRadius: 50,
                                    spreadRadius: 2,
                                  ),
                                ]),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width,
                        height: 260,
                        child: Container(
                          color: Colors.blueAccent.shade400,
                          child: loadImageCached(context
                              .read<CurrentPlaylistCubit>()
                              .getPlaylistCoverArt()),
                        ),
                      ),
                      Positioned(
                          top: 225,
                          right: 20,
                          child: StreamBuilder<String>(
                              stream: context
                                  .watch<BloomeePlayerCubit>()
                                  .bloomeePlayer
                                  .currentQueueName,
                              builder: (context, snapshot) {
                                if (snapshot.hasData &&
                                    snapshot.data == playListName) {
                                  return StreamBuilder<PlayerState>(
                                      stream: context
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .audioPlayer
                                          .playerStateStream,
                                      builder: (context, snapshot2) {
                                        if (snapshot2.hasData &&
                                            (snapshot2.data?.playing ??
                                                false)) {
                                          return PlayPauseButton(
                                            onPause: () => context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .pause(),
                                            onPlay: () => context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .play(),
                                            isPlaying: true,
                                            size: 70,
                                          );
                                        } else {
                                          return PlayPauseButton(
                                            onPause: () => context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .pause(),
                                            onPlay: () => context
                                                .read<BloomeePlayerCubit>()
                                                .bloomeePlayer
                                                .play(),
                                            isPlaying: false,
                                            size: 70,
                                          );
                                        }
                                      });
                                } else {
                                  return PlayPauseButton(
                                    onPause: () => context
                                        .read<BloomeePlayerCubit>()
                                        .bloomeePlayer
                                        .pause(),
                                    onPlay: () {
                                      context
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .loadPlaylist(state);
                                      context
                                          .read<BloomeePlayerCubit>()
                                          .bloomeePlayer
                                          .play();
                                    },
                                    size: 70,
                                  );
                                }
                              })),
                      Positioned(
                        top: 280,
                        left: 20,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 300,
                              child: Text(
                                playListName,
                                maxLines: 2,
                                overflow: TextOverflow.fade,
                                style: Default_Theme.secondoryTextStyle.merge(
                                    const TextStyle(
                                        color: Default_Theme.primaryColor1,
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                            Text(
                              "Youtube-SPotify",
                              style: Default_Theme.secondoryTextStyle
                                  .merge(TextStyle(
                                color: Default_Theme.primaryColor1
                                    .withOpacity(0.8),
                                fontSize: 14,
                              )),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: Text(
                                "${state.mediaItem.length} Songs",
                                style: Default_Theme.secondoryTextStyle
                                    .merge(TextStyle(
                                  color: Default_Theme.primaryColor1
                                      .withOpacity(0.8),
                                  fontSize: 12,
                                )),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Playlist(
                    state: state,
                  ),
                ),
              ],
            );
          } else if (state is CurrentPlaylistLoading) {
            return const Center(
              child: SizedBox(
                width: 50,
                height: 50,
                child: CircularProgressIndicator(),
              ),
            );
          } else {
            return Center(
              child: Wrap(
                children: [
                  Text(
                    "Get started by adding items to library!!",
                    style: Default_Theme.secondoryTextStyle.merge(
                        const TextStyle(color: Default_Theme.primaryColor2)),
                  )
                ],
              ),
            );
          }
        },
      ),
    );
  }
}

class Playlist extends StatefulWidget {
  CurrentPlaylistState state;
  Playlist({super.key, required this.state});

  @override
  State<Playlist> createState() => _PlaylistState();
}

class _PlaylistState extends State<Playlist> {
  @override
  Widget build(BuildContext context) {
    final _state = widget.state;
    return ReorderableListView.builder(
      proxyDecorator: proxyDecorator,
      itemBuilder: (context, index) {
        return Dismissible(
          direction: DismissDirection.startToEnd,
          background: Container(
            color: Colors.red,
            child: const Row(
              children: [
                Padding(
                    padding: EdgeInsets.only(left: 20),
                    child: Icon(
                      MingCute.delete_3_line,
                      color: Colors.white,
                      size: 30,
                    )),
                Spacer()
              ],
            ),
          ),
          // secondaryBackground: Container(
          //   color: Colors.red,
          //   child: const Row(
          //     children: [
          //       Spacer(),
          //       Padding(
          //         padding: EdgeInsets.only(right: 20),
          //         child: Icon(
          //         MingCute.delete_3_line,
          //           color: Colors.white,
          //           size: 30,
          //         ),
          //       ),
          //     ],
          //   ),
          // ),
          onDismissed: (direction) {
            context.read<MediaDBCubit>().removeMediaFromPlaylist(
                _state.mediaItem[index],
                MediaPlaylistDB(playlistName: _state.albumName));
            setState(() {
              _state.mediaItems.removeAt(index);
            });
          },
          key: ValueKey(_state.mediaItems[index].id),
          child: Padding(
            padding: const EdgeInsets.only(bottom: 5, left: 12, right: 5),
            child: HorizontalSongCardWidget(
              mediaPlaylist: _state,
              index: index,
              boxWidth: MediaQuery.of(context).size.width * 0.9,
              showLiked: true,
            ),
          ),
        );
      },
      itemCount: _state.mediaItem.length,
      onReorder: (oldIndex, newIndex) {
        setState(() {
          if (oldIndex < newIndex) {
            newIndex -= 1;
          }
          final MediaItemModel item = _state.mediaItems.removeAt(oldIndex);
          _state.mediaItems.insert(newIndex, item);
          context
              .read<MediaDBCubit>()
              .reorderPositionOfItemInDB(_state.albumName, oldIndex, newIndex);
        });
        print(_state.mediaItem.toList().toString());
      },
    );
  }
}

Widget proxyDecorator(Widget child, int index, Animation<double> animation) {
  return AnimatedBuilder(
    animation: animation,
    builder: (BuildContext context, Widget? child) {
      final double animValue = Curves.easeInOut.transform(animation.value);
      final double elevation = lerpDouble(0, 6, animValue)!;
      return Material(
        elevation: elevation,
        color: Default_Theme.accentColor2.withOpacity(0.3),
        borderRadius: BorderRadius.circular(15),
        shadowColor: Colors.transparent,
        child: child,
      );
    },
    child: child,
  );
}
