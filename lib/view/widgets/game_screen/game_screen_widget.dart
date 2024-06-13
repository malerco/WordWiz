import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';
import 'package:words/view/widgets/circle_keyboard/white_circle.dart';
import 'package:words/view/widgets/game_screen/game_screen_view_model.dart';
import 'package:words/view/widgets/main_menu/main_menu_view_model.dart';

import '../../../configuration/constants.dart';
import '../circle_keyboard/custom_circle.dart';
import '../circle_keyboard/line_painter.dart';

class GameScreenWidget extends StatefulWidget {
  const GameScreenWidget({super.key});

  @override
  State<GameScreenWidget> createState() => _GameScreenWidgetState();
}

class _GameScreenWidgetState extends State<GameScreenWidget> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  Future<void> initLocale() async{
    await FlutterI18n.refresh(context, Locale(context.read<GameScreenViewModel>().currentLocale)).then((value) => {
      setState(() {

      })
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  void onBackPressed(BuildContext context){
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    initLocale();
    final model = context.watch<GameScreenViewModel>();
    return Scaffold(
      body: Stack(
        children: [
          Image(
            image: AssetImage(Constants.assets + model.wallpaperId + '.jpg'),
            fit: BoxFit.fill, // Заполнить всю доступную область
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),

          model.isCrosswordReady ? const _PlayingField() : const Center(child: CircularProgressIndicator()),

          Padding(
            padding: const EdgeInsets.only(top: 28.0, left: 8.0),
            child: IconButton(onPressed: () => onBackPressed(context), icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white,)),
          ),

          model.isCrosswordFinished ?
            const _GameFinishedWidget() : const SizedBox.shrink()
        ],
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
    _controller.dispose();
    super.dispose();
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

class _GameFinishedWidget extends StatelessWidget {
  const _GameFinishedWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final model = context.read<GameScreenViewModel>();
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(FlutterI18n.translate(context, LocaleConstants.gameFinished), style: const TextStyle(color: Colors.white, fontSize: 30), textAlign: TextAlign.center,),
        const SizedBox(height: 10,),
        Center(child: _Bouncing(
              onPress: () => model.recreateCrossword(),
              child: _CustomButton(buttonTitle: FlutterI18n.translate(context, LocaleConstants.createNew),)))
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
            borderRadius: BorderRadius.all(Radius.circular(5)),
            boxShadow: [BoxShadow(color: Color.fromRGBO(0, 0, 0, 0.5), offset: Offset(3, 5), blurRadius: 15)],
        ),
        clipBehavior: Clip.hardEdge,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Text(buttonTitle, style: const TextStyle(fontSize: 24, color: Colors.white), textAlign: TextAlign.center,),
          ),
        ),
      ),
    );
  }
}

class _PlayingField extends StatelessWidget {
  const _PlayingField({super.key});

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameScreenViewModel>();
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                child: model.screenCrossword.length > 0 ? const _GridViewCrossword() : const SizedBox.shrink(),
              ),

              SizedBox(
                height: 90,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const _ShowOtherWordsButton(),

                    model.userWordState == 'shaking' ? _ShakingText(text: model.animationWord) : (model.userWordState == 'swiping' ? _SwipingText(width: MediaQuery.of(context).size.width/4,) : const _DisappearingText()),

                    _Bouncing(onPress: model.showRandomLetter,
                    child: const _ShowRandomLetterButton())
                  ],
                ),
              )
            ],
          ),
        ),
        Expanded(
          flex: 1,
          child: GestureDetector(
            onTapDown: model.onTapDownCircleKeyboard,

            onPanUpdate: model.onPanUpdateCircleKeyboard,

            onPanEnd: model.onPanEndCircleKeyboard,

            onTapUp: model.onTapUpCircleKeyboard,

            child: Stack(
                children: [
                  const Padding(
                    padding: EdgeInsets.only(bottom: 8.0),
                    child: WhiteCircle(),
                  ),

                  if (model.isDrawing)
                    const LinePainterWidget(),

                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: CustomCircle(letters: model.letters, pressedLettersIndex: model.pressedLettersIndex, lettersPoint: model.lettersPoint),
                  ),

                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: InkWell(
                        onTap: model.shuffleLetters,
                        child: const Image(
                          image: AssetImage(Constants.shuffle),
                          width: 30,
                          height: 30,
                        ),
                      ),
                    ),
                  ),


                ]
            ),
          ),
        ),
      ],
    );
  }
}

class _ShakingText extends StatefulWidget {
  final String text;

  const _ShakingText({Key? key, required this.text}) : super(key: key);

  @override
  _ShakingTextState createState() => _ShakingTextState();
}

class _ShakingTextState extends State<_ShakingText> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _controller.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        double offsetX = 0.0;

        if (_controller.value < 0.25) {
          offsetX = -2.0;
        } else if (_controller.value < 0.5) {
          offsetX = 2.0;
        } else if (_controller.value < 0.75) {
          offsetX = -2.0;
        } else {
          offsetX = 2.0;
        }

        return Transform.translate(
          offset: Offset(offsetX, 0),
          child: child,
        );
      },
      child: Text(
        widget.text,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

class _GridViewCrossword extends StatefulWidget {
  const _GridViewCrossword({super.key});

  @override
  State<_GridViewCrossword> createState() => _GridViewCrosswordState();
}

class _GridViewCrosswordState extends State<_GridViewCrossword> with SingleTickerProviderStateMixin{


  @override
  void initState() {
    // TODO: implement initState
    super.initState();

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameScreenViewModel>();
    return GridView.builder(
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: model.screenCrossword[0].length,
        childAspectRatio: 1,
        crossAxisSpacing: 1,
        mainAxisSpacing: 1,

      ),
      itemCount: model.screenCrossword[0].length* model.screenCrossword.length,
      itemBuilder: (context, index) {

          final screenHeight = MediaQuery
              .of(context)
              .size
              .height / 4; // Получаем высоту экрана
          final rowCount = model.screenCrossword
              .length; // Количество строк

          final cellHeight = screenHeight /
              rowCount; // Рассчитываем высоту каждой ячейки


          int rowIndex = index ~/
              model.screenCrossword[0].length;
          int colIndex = index %
              model.screenCrossword[0].length;
          if (model.screenCrossword[rowIndex][colIndex]
              .value == '0' ||
              model.screenCrossword[rowIndex][colIndex]
                  .value == '.' ||
              model.screenCrossword[rowIndex][colIndex]
                  .value == ':' ||
              model.screenCrossword[rowIndex][colIndex]
                  .value == '-') {
            return const Material(
              color: Colors.transparent,
            );
          } else {
            return _CrosswordCell( cellHeight: cellHeight, model: model, rowIndex: rowIndex, colIndex: colIndex);
        }
      },);
  }
}

class _CrosswordCell extends StatelessWidget {
  const _CrosswordCell({
    super.key,
    required this.cellHeight,
    required this.model,
    required this.rowIndex,
    required this.colIndex,
  });

  final double cellHeight;
  final GameScreenViewModel model;
  final int rowIndex;
  final int colIndex;

  @override
  Widget build(BuildContext context) {
    bool _isVisible = model
        .screenCrossword[rowIndex][colIndex]
        .visible;

    return Padding(
      padding: const EdgeInsets.all(1.0),
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        height: cellHeight,
        decoration: BoxDecoration(
          border: Border.all(),
          borderRadius: BorderRadius.circular(5),
          color: model.screenCrossword[rowIndex][colIndex].color
        ),
        clipBehavior: Clip.hardEdge,

        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 1000),
          opacity: _isVisible ? 1 : 0,
          child: Text(
            // '${model.crossword[rowIndex][colIndex]}',
            _isVisible ? '${model
                .screenCrossword[rowIndex][colIndex]
                .value}' : '',
            style: const TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

class _ShowRandomLetterButton extends StatelessWidget {
  const _ShowRandomLetterButton({super.key});
  @override
  Widget build(BuildContext context) {
    return const Image(
      image: AssetImage(Constants.hammer),
      fit: BoxFit.fill, // Заполнить всю доступную область
      width: Constants.gameButtonsWidth,
      height: Constants.gameButtonsHeight,
    );
  }
}


class _ShowOtherWordsButton extends StatefulWidget {
  const _ShowOtherWordsButton({super.key});

  @override
  State<_ShowOtherWordsButton> createState() => _ShowOtherWordsButtonState();
}

class _ShowOtherWordsButtonState extends State<_ShowOtherWordsButton> with SingleTickerProviderStateMixin{
  late Animation<Size> _animation;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
        duration: const Duration(milliseconds: 500),
        vsync: this,
        lowerBound: 0.0,
        upperBound: 0.2);

    _animation = Tween<Size>(
        begin: const Size(50, 50),
        end:  const Size(90, 90)
    ).animate(
        CurvedAnimation(parent: _controller, curve: Curves.bounceIn)
    );

    _controller.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.completed) {
        _controller.repeat();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startAnimation() {
    // Сбросить и начать анимацию
    _controller.reset();
    _controller.forward();
  }

  void _stopAnimation() {
    _controller.reset();
    _controller.stop();
  }

  void onPressOnButton(BuildContext context) {
    final model = context.read<GameScreenViewModel>();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(child: Text(FlutterI18n.translate(context, LocaleConstants.extraWords))),
          content: SizedBox(
            width: MediaQuery.of(context).size.width/2,
            height: MediaQuery.of(context).size.height/4,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: model.extraWords.length,
              itemBuilder: (context, index) {
                return Center(
                  child: Text(
                      model.extraWords[index]
                  ),
                );
              },),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],

          elevation: 3,
          backgroundColor: Colors.white.withOpacity(0.8),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {


    final model = context.watch<GameScreenViewModel>();
    if (model.increaseButtonSize){
      _startAnimation();
    }else{
      _stopAnimation();
    }

    return _Bouncing(
      onPress: () => onPressOnButton(context),
      child: AnimatedBuilder(animation: _animation,
          builder: (ctx, ch) =>  Container(
            width: _animation.value.width,
            height: _animation.value.height,
      
            decoration: const BoxDecoration(
                image: DecorationImage(
                    image: AssetImage(Constants.otherWords)
                )
            ),
          )
      ),
    );

  }
}

class _SwipingText extends StatefulWidget {
  final double width;


  _SwipingText({required this.width});

  @override
  _SwipingTextState createState() => _SwipingTextState();
}

class _SwipingTextState extends State<_SwipingText> with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Продолжительность анимации
    );


    // Начать анимацию
    _controller.forward();

    _animation = Tween<Offset>(
      begin: Offset.zero,
      end: Offset(-widget.width, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        context.read<GameScreenViewModel>().startIncreaseButtonSize();
      }
    });
  }

  @override
  void didChangeDependencies() {
    // TODO: implement didChangeDependencies
    super.didChangeDependencies();

  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final model = context.read<GameScreenViewModel>();


    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.translate(
          offset: _animation.value,
          child: Text(
            model.animationWord,
            style: const TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
        );
      },
    );
  }
}


class _DisappearingText extends StatelessWidget {

  const _DisappearingText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final model = context.watch<GameScreenViewModel>();
    //:Text(model.word, style: TextStyle(fontSize: 30, color: Colors.white),)
    return AnimatedOpacity(
      opacity: model.userWordState == 'guessed' ? 0.0 : 1.0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      child: Text(
        model.userWordState == 'gone' ? model.word : model.animationWord,
        style: const TextStyle(
          fontSize: 30,
          color: Colors.white,
        ),
      ),
    );
  }
}

