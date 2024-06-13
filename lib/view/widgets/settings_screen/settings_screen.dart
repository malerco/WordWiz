import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:words/utils/provider_models/language_model.dart';
import 'package:words/utils/provider_models/wallpaper_model.dart';
import 'package:words/view/widgets/game_screen/game_screen_view_model.dart';
import 'package:words/view/widgets/settings_screen/settings_view_model.dart';

import '../../../configuration/constants.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void onBackPressed(BuildContext context){
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {

    final model = context.watch<WallpaperModel>();
    return Scaffold(
      body: Stack(
        children: [
          Image(
            image: AssetImage(Constants.assets + model.wallpaperId + '.jpg'),
            fit: BoxFit.fill, // Заполнить всю доступную область
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
          Padding(
            padding: const EdgeInsets.only(top: 28.0, left: 8.0),
            child: IconButton(onPressed: () => onBackPressed(context), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white,)),
          ),

          SettingsBodyWidget()
        ],
      ),
    );
  }
}


class SettingsBodyWidget extends StatefulWidget {
  @override
  _SettingsBodyWidgetState createState() => _SettingsBodyWidgetState();
}

class _SettingsBodyWidgetState extends State<SettingsBodyWidget> {
  late String _selectedPicId;
  late String _selectedLanguage;
  late String _selectedLanguageCode;

  Map<String, String> _languageCodes = {
    'be' : 'Беларуская',
    'de' : 'Deutsch',
    'es' : 'Español',
    'fr' : 'Français',
    'hi' : 'हिंदी',
    'uk' : 'Українська',
    'ru' : 'Русский',
    'en' : 'English'
  };

  final List<String> _languages = [
    'Беларуская',
    'Deutsch',
    'Español',
    'Français',
    'हिंदी',
    'Українська',
    'Русский',
    'English'
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // context.read<SettingsScreenViewModel>().init();
    _selectedPicId = context.read<WallpaperModel>().wallpaperId;
    context.read<SettingsScreenViewModel>().selectedPicId = _selectedPicId;

    _selectedLanguage = _languageCodes[context.read<LanguageModel>().languageString] ?? 'English';
    _languageCodes.forEach((key, value) {
      if (value == _selectedLanguage){
        _selectedLanguageCode = key;
        // model.selectedLanguage = key;
      }
    });

  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<SettingsScreenViewModel>();
    final languageModel = context.read<LanguageModel>();
    final wallpaperModel = context.read<WallpaperModel>();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 60),
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              FlutterI18n.translate(context, LocaleConstants.languageSelection),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            DropdownButton<String>(
              dropdownColor: Colors.grey,
              value: _selectedLanguage,
              onChanged: (String? newValue) {
                _languageCodes.forEach((key, value) {
                  if (value == newValue){
                    model.updateSelectedLanguage(key);
                    _selectedLanguageCode = key;
                    _selectedLanguage = value;
                  }
                });
              },

              items: _languageCodes.values.map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 20, color: Colors.white),),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text(
              FlutterI18n.translate(context, LocaleConstants.backgroundSelection),
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            const SizedBox(height: 8),
            Container(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 9,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      _selectedPicId = index.toString();
                      model.updateSelectedPicId(index.toString());
                    },
                    child: Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          child: Image.asset(
                            Constants.assets + '${index}.jpg',
                            width: 100,
                            height: 200,
                            fit: BoxFit.cover,
                          ),
                        ),

                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            width: 24,
                            height: 24,
                            decoration: BoxDecoration(
                              color: model.selectedPicId == index.toString()
                                ? Colors.green : null,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.black),
                            ),
                            child:
                            model.selectedPicId == index.toString() ? const Icon(
                                    Icons.check,
                                    color: Colors.white,
                                    size: 16,
                              ) : null,

                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20,),

            _Bouncing(onPress: () async {
                languageModel.updateLocale(_selectedLanguageCode);
                wallpaperModel.wallpaperId = _selectedPicId;
                // await model.saveSettings();
                Navigator.of(context).pop();
              },
                child: _CustomButton(buttonTitle: FlutterI18n.translate(context, LocaleConstants.apply))),
            const SizedBox(height: 5,),
          ],
        ),
      ),
    );
  }
}

class _CustomButton extends StatelessWidget {
  final String buttonTitle;
  const _CustomButton({required this.buttonTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      // padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Container(
        decoration: const BoxDecoration(
            color: ColorConstants.menuButtonColor,
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.8), offset: Offset(3, 5), blurRadius: 15)],
            borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        clipBehavior: Clip.hardEdge,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Text(buttonTitle, style: const TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
          ),
        ),
      ),
    );
  }
}

class _Bouncing extends StatefulWidget {
  final Widget child;
  final VoidCallback onPress;

  _Bouncing({required this.child, required this.onPress})
      : assert(child != null){}

  @override
  _BouncingState createState() => _BouncingState();
}

class _BouncingState extends State<_Bouncing>
    with SingleTickerProviderStateMixin {
  double _scale = 0.0;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.0,
      upperBound: 0.1,
    );
    _controller.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _scale = 1 - _controller.value;
    return Listener(
      onPointerDown: (PointerDownEvent event) {
        if (widget.onPress != null) {
          _controller.forward();
        }
      },
      onPointerUp: (PointerUpEvent event) {
        if (widget.onPress != null) {
          _controller.reverse();
          widget.onPress();
        }
      },
      child: Transform.scale(
        scale: _scale,
        child: widget.child,
      ),
    );
  }
}