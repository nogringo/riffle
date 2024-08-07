import 'package:audio_service/audio_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riffle/constant.dart';
import 'package:riffle/firebase_options.dart';
import 'package:riffle/home/home_page_view.dart';
import 'package:riffle/models/music.dart';
import 'package:riffle/models/playlist.dart';
import 'package:riffle/my_audio_handler.dart';
import 'package:riffle/path_provider_service.dart';
import 'package:riffle/player/player_controller.dart';
import 'package:riffle/repository.dart';
import 'package:riffle/theme_controller.dart';
import 'package:super_hot_key/super_hot_key.dart';
import 'package:system_theme/system_theme.dart';
import 'package:toastification/toastification.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; 

// ! App volume is not saved between app restart
// TODO indicate if the music exist or not on the ui
// TODO if Get.width < 500 show qr code in dialog
// TODO remove lag when seeking
// TODO manage app updates
// TODO rename music
// TODO when path is unopenable give the path to the user
// TODO add end to end encryption
// TODO inform user that sync use google servisies

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await PathProviderService().init();

  SystemTheme.fallbackColor = logoPrimaryColor;
  await SystemTheme.accentColor.load();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await GetStorage.init();

  Get.put(ThemeController());
  Get.put(Repository());

  addHotKeys();

  if (GetPlatform.isDesktop) {
    await windowManager.ensureInitialized();

    WindowOptions windowOptions = const WindowOptions(
      title: "Riffle",
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions);
  }

  if (GetPlatform.isMobile) {
    final audioHandler = await AudioService.init(
      builder: () => MyAudioHandler(),
      config: const AudioServiceConfig(
        androidNotificationChannelId: 'com.example.riffle.channel.audio',
        androidNotificationChannelName: 'Music playback',
      ),
    );
    Get.put(audioHandler);
  }

  final dir = await getApplicationDocumentsDirectory();
  Repository.to.isar = await Isar.open(
    [MusicSchema, PlaylistSchema],
    directory: dir.path,
  );

  Get.put(PlayerController());

  runApp(const MyApp());
}

Future<void> addHotKeys() async {
  await HotKey.create(
    definition: HotKeyDefinition(
      key: PhysicalKeyboardKey.mediaPlayPause,
    ),
    onPressed: Repository.to.playPause,
  );

  await HotKey.create(
    definition: HotKeyDefinition(
      key: PhysicalKeyboardKey.mediaTrackNext,
    ),
    onPressed: Repository.to.skipToNextTrack,
  );

  await HotKey.create(
    definition: HotKeyDefinition(
      key: PhysicalKeyboardKey.mediaTrackPrevious,
    ),
    onPressed: Repository.to.skipToPreviousTrack,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        systemNavigationBarColor: Colors.black.withOpacity(0.002),
        systemNavigationBarIconBrightness:
            MediaQuery.of(context).platformBrightness == Brightness.light
                ? Brightness.dark
                : Brightness.light,
      ),
    );

    return ToastificationWrapper(
      child: GetBuilder<ThemeController>(
        builder: (c) {
          return GetMaterialApp(
            title: 'Riffle',
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            debugShowCheckedModeBanner: kDebugMode,
            theme: c.lightTheme,
            darkTheme: c.darkTheme,
            themeMode: ThemeMode.dark,
            home: const HomePageView(),
          );
        },
      ),
    );
  }
}
