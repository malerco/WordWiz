import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:words/utils/provider_models/wallpaper_model.dart';
import 'package:words/view/widgets/loader/loader_view_model.dart';

import '../../../configuration/constants.dart';

class LoaderWidget extends StatelessWidget {
  const LoaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.read<WallpaperModel>();

    return Scaffold(
      body: Stack(
        children: [
          Image(
              image: AssetImage(Constants.assets + model.wallpaperId + '.jpg'),
              fit: BoxFit.fill, // Заполнить всю доступную область
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
          ),
          const Center(
            child: CircularProgressIndicator(),
          ),
        ],
      ),
    );
  }
}
