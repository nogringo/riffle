import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.settings),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(AppLocalizations.of(context)!.sync),
            // onTap: SettingsController().onTapSync,
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.scanQRCode),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.exportYourData),
          ),
          ListTile(
            title: Text(AppLocalizations.of(context)!.importYourData),
          ),
          const ListTile(
            title: Text("About Riffle"),
          ),
        ],
      ),
    );
  }
}
