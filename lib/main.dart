import 'package:flare_flutter/flare_actor.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NirvanaTestApp',
      home: CalculatorPage(),
    );
  }
}
enum BoxType{
  Exp,
  Appear,
}

class CalculatorPage extends StatefulWidget {
  @override
  _CalculatorPageState createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> {

  //Контроллеры текстовых полей
  final expBoxController = new TextEditingController();
  final appearBoxController = new TextEditingController();

  //Поля для хранения ошибки
  String expError;
  String appearError;

  //Валидировано ли поле
  bool expValidated = false;
  bool appearValidated = false;

  //Конвертированные значения полей
  double expValue = 0;
  double appearValue = 0;

  //Величина остатка. В нём может выводиться ошибка
  String resultValue = "введите данные";

  @override
  void initState() {
    super.initState();

    //Следим за изменением текста, проводим валидацию
    appearBoxController.addListener(() {_validator(BoxType.Appear);});
    expBoxController.addListener(() {_validator(BoxType.Exp);});
  }

  //Метод для валидации входных данных. На вход получает тип текстовой формы
  void _validator(BoxType boxType){

    //Получаем введённый текст
    String inputText = boxType == BoxType.Appear ? appearBoxController.text : expBoxController.text;

    if(inputText.isEmpty) { _setError(boxType, "Поле пустое. Введите число"); return; }

    //Сколько разделителей ввёл пользователь? | пусть будет здесь, а не
    //после проверки на дробь
    if(_commasCount(inputText) > 1) {_setError(boxType, "Много плавающих точек"); return;}

    //Пользователь ввёл дробное число?
    if(RegExp('\\d*[.,]\\d+\$').hasMatch(inputText)){

      //Остаток не более чем из 6 знаков?
      if(!RegExp('\\d*[.,]\\d{0,6}\$').hasMatch(inputText)) {_setError(boxType, "Дробная часть может иметь не более 6 символов"); return;}
    }
    //Пользователь ввёл целое число?
    else if(!RegExp('^\\d+\$').hasMatch(inputText)) {_setError(boxType, "Введите целое или дробное число"); return;}

    //Преобразуем к допустимому виду при необходимости
    if(inputText.contains(',')) inputText = inputText.replaceAll(',', '.');

    final result = double.tryParse(inputText);

    //Ошибка обработки
    if(result == null) {_setError(boxType, "Ошибка обработки введённого числа"); return;}

    //Проверяем допустимый интервал
    if(result < 0 || result > 100000) {_setError(boxType, "Число должно находиться в интервале от 0 до 100000"); return;}
    _setValidated(boxType, result);
  }

  //Метод для получения количества разделителей в строке
  int _commasCount(String inputText){
    return ','.allMatches(inputText.replaceAll('.', ',')).length;
  }
  //Метод для вывода ошибки в текстовую форму
  void _setError(BoxType boxType, String error){
    if(boxType == BoxType.Appear){
      appearValidated = false;
      setState(() {
        appearError = error;
      });
    }
    else{
      expValidated = false;
      setState(() {
        expError = error;
      });
    }
    setState(() {
      resultValue = "ошибка";
    });
  }

  //Метод подтверждает валидацию формы, а также запускает калькулятор, если валидация для
  //обоих форм успешна
  void _setValidated(BoxType boxType, double validatedValue){
    if(boxType == BoxType.Appear){
      appearValidated = true;
      appearValue = validatedValue;
      setState(() {
        appearError = null;
      });
    }
    else{
      expValidated = true;
      expValue = validatedValue;
      setState(() {
        expError = null;
      });
    }
    if(appearValidated && expValidated) _calculate();
  }

  //Калькулятор, считает величину остатка и формирует ответ
  void _calculate(){
    double calculate = double.parse((appearValue - expValue).toStringAsFixed(6));
    String result = calculate.toString();
    if(result.indexOf(".0") == result.length - 2) result = result.substring(0, result.indexOf(".0"));
    setState(() {
      resultValue = result.toString().replaceAll('.', ',');
    });
  }

  //Виджет для ввода значений
  Widget TextBox(String name, String error, TextEditingController controller){
    return TextFormField(
      controller: controller,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white70,
        labelText: name,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Color(0xFF3B46C3)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.pink),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide(color: Colors.pink),
        ),
        errorText: error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white70,
      body: Stack(
        children: [
          FlareActor("assets/animation.flr", animation: "Flow", fit: BoxFit.fitWidth,),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10.0),
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(bottom: 50.0),
                      child: Text("Тестовое задание на ANDROID", textAlign: TextAlign.center,style: TextStyle(fontSize: 40, color: Colors.white),),
                    ),
                    TextBox("Приход дизельного топлива за сутки, л", appearError, appearBoxController),
                    SizedBox(height: 5,),
                    TextBox("Расход дизельного топлива за сутки, л", expError, expBoxController),
                    SizedBox(height: 10,),
                    Text("Остаток: " + resultValue, style: TextStyle(fontSize: 20),),
                  ],
                ),
              ),
            ),
          ),
        ],
      )
    );
  }
}
