import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:words/utils/provider_models/language_model.dart';
import 'package:words/utils/provider_models/wallpaper_model.dart';
import 'package:words/view/widgets/main_menu/main_menu_view_model.dart';

import '../../../configuration/constants.dart';

class MainMenuWidget extends StatelessWidget {
  const MainMenuWidget({super.key});

  @override
  Widget build(BuildContext context) {

    final wallpaperModel = context.watch<WallpaperModel>();
    return Scaffold(
        body: Stack(
          children: [
            Image(
                image: AssetImage(Constants.assets + wallpaperModel.wallpaperId + '.jpg'),
                fit: BoxFit.fill, // Заполнить всю доступную область
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
            ),
            const Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Text(Constants.menuTitle, style: TextStyle(fontSize: 36, color: Colors.white,), textAlign: TextAlign.center,),

                ButtonsWidget()
              ],
            )
          ],
        ),
    );
  }
}

class ButtonsWidget extends StatefulWidget {
  const ButtonsWidget({super.key});

  @override
  State<ButtonsWidget> createState() => _ButtonsWidgetState();
}

class _ButtonsWidgetState extends State<ButtonsWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Future<void> initLocale(String locale) async{
    await FlutterI18n.refresh(context, Locale(locale)).then((value) => {
      setState(() {

      })
    });
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<MainMenuViewModel>();
    final languageModel = context.watch<LanguageModel>();

    initLocale(languageModel.languageString ?? 'en');
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        model.hasFinishedGames == true
            ? _Bouncing(
                onPress: ()async{model.onTapOnContinueGame(context);},
                child: _CustomButton(buttonTitle: FlutterI18n.translate(context, LocaleConstants.continueGame)))
            : const SizedBox.shrink(),

        const SizedBox(height: 5,),

        _Bouncing(onPress: () async { model.onTapOnNewGame(context); },
        child: _CustomButton(buttonTitle: FlutterI18n.translate(context, LocaleConstants.newGame))),
        const SizedBox(height: 5,),

        _Bouncing(onPress: () async { model.onTapOnSettings(context); },
        child: _CustomButton(buttonTitle: FlutterI18n.translate(context, LocaleConstants.settings))),
      ],
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



