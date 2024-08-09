import 'package:Bloomee/blocs/library/cubit/library_items_cubit.dart';
import 'package:Bloomee/blocs/mediaPlayer/bloomee_player_cubit.dart';
import 'package:Bloomee/model/MediaPlaylistModel.dart';
import 'package:Bloomee/screens/widgets/snackbar.dart';
import 'package:Bloomee/services/db/GlobalDB.dart';
import 'package:Bloomee/theme_data/default.dart';
import 'package:Bloomee/services/file_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';

void showPlaylistOptsSheet(BuildContext context, String playlistName) {
  showFloatingModalBottomSheet(
    context: context,
    builder: (context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 7, 17, 50),
                    Color.fromARGB(255, 5, 0, 24),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.5]),
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20), topRight: Radius.circular(20)),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  PltOptBtn(
                    icon: MingCute.play_circle_fill,
                    title: "Play",
                    onPressed: () async {
                      Navigator.pop(context);
                      final _list = await context
                          .read<LibraryItemsCubit>()
                          .getPlaylist(playlistName);
                      if (_list != null && _list.isNotEmpty) {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .loadPlaylist(
                                MediaPlaylist(
                                    mediaItems: _list,
                                    playlistName: playlistName),
                                doPlay: true);
                        SnackbarService.showMessage("Playing $playlistName");
                      }
                    },
                  ),
                  PltOptBtn(
                    title: 'Add Playlist to Queue',
                    icon: MingCute.playlist_2_line,
                    onPressed: () async {
                      Navigator.pop(context);
                      final _list = await context
                          .read<LibraryItemsCubit>()
                          .getPlaylist(playlistName);
                      if (_list != null && _list.isNotEmpty) {
                        context
                            .read<BloomeePlayerCubit>()
                            .bloomeePlayer
                            .addQueueItems(_list);
                        SnackbarService.showMessage(
                            "Added $playlistName to Queue");
                      }
                    },
                  ),
                  PltOptBtn(
                    icon: MingCute.share_2_fill,
                    title: "Share Playlist",
                    onPressed: () async {
                      Navigator.pop(context);
                      SnackbarService.showMessage(
                          "Preparing $playlistName for share");
                      final _tmpPath =
                          await BloomeeFileManager.exportPlaylist(playlistName);
                      _tmpPath != null
                          ? Share.shareXFiles([XFile(_tmpPath)])
                          : null;
                    },
                  ),
                  PltOptBtn(
                    title: 'Delete Playlist',
                    icon: MingCute.delete_2_fill,
                    onPressed: () {
                      Navigator.pop(context);
                      context.read<LibraryItemsCubit>().removePlaylist(
                          MediaPlaylistDB(playlistName: playlistName));
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PltOptBtn extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onPressed;
  const PltOptBtn({
    super.key,
    required this.icon,
    required this.title,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Row(
        children: [
          Icon(
            icon,
            color: Default_Theme.primaryColor1,
            size: 28,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 8, right: 8),
              child: Text(
                title,
                style: const TextStyle(
                    color: Default_Theme.primaryColor1,
                    fontFamily: "Unageo",
                    fontSize: 17,
                    fontWeight: FontWeight.w400),
              ),
            ),
          ),
        ],
      ),
      onPressed: onPressed,
      hoverColor: Default_Theme.primaryColor1.withOpacity(0.04),
    );
  }
}

Future<T> showFloatingModalBottomSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  Color? backgroundColor,
}) async {
  final result = await showCustomModalBottomSheet(
      context: context,
      builder: builder,
      containerWidget: (_, animation, child) => FloatingModal(
            child: child,
          ),
      expand: false);

  return result;
}

class FloatingModal extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;

  const FloatingModal({super.key, required this.child, this.backgroundColor});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Material(
          color: backgroundColor,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(12),
          child: child,
        ),
      ),
    );
  }
}
