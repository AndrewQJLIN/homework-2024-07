import 'dart:io';

final validOperand = ['+', '-', '*', '/'];
final baskets = ['(', ')'];
final validNumber = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9', '.'];

var aCodeCup = 'A'.codeUnitAt(0);
var zCodeCup = 'Z'.codeUnitAt(0);
List<String> alphabetsCup = List<String>.generate(
  zCodeCup - aCodeCup + 1,
  (index) => String.fromCharCode(aCodeCup + index),
);

var aCode = 'a'.codeUnitAt(0);
var zCode = 'z'.codeUnitAt(0);
List<String> alphabets = List<String>.generate(
  zCode - aCode + 1,
  (index) => String.fromCharCode(aCode + index),
);

final letters = alphabets + alphabetsCup;

(String, int) getNumberFromString(String str, int currentPosition) {
  String numberByStr = '';

  for (; currentPosition < str.length; currentPosition++) {
    String num = str[currentPosition];
    if (validNumber.contains(num) ||
        ((num == '-' || num == '+') && numberByStr.isEmpty)) {
      numberByStr += num;
    } else {
      currentPosition--;
      break;
    }
  }
  try {
    double.parse(numberByStr);
  } on FormatException {
    print(
        'Обнаружен неверный формат записи числа ($numberByStr)! Число будет пропущено!');
    numberByStr = '';
  }
  return (numberByStr, currentPosition);
}

// проверяем строку на правильность написания и ищем переменные, их будем возвращать списком, если ошибка - вернем 0
Set<String> checkInputStrOnError(String inputString) {
  Set<String> arguments = {};
  var brackets = 0;

  //RegExp(r'^[A-Za-z]');

  for (int i = 0; i < inputString.length; i++) {
    var currentSymbol = inputString[i];
    if (validNumber.contains(currentSymbol) ||
        validOperand.contains(currentSymbol) ||
        baskets.contains(currentSymbol) ||
        letters.contains(currentSymbol)) {
      if (currentSymbol == '(') brackets++;
      if (currentSymbol == ')') brackets--;
      if (letters.contains(currentSymbol)) {
        arguments.add(currentSymbol);
      }
    } else {
      arguments.add('! Недопустимые символы в выражении');
    }
  }

  if (brackets != 0) {
    arguments.add('! Ошибка в выражении = Не парные скобки');
  }
  return arguments;
}

Map<String, String> getValueOfVariables(Set<String> listOfLetters) {
  var indexLetters = 0;
  String inputValueLetters;
  Map<String, String> argOfLetters = {};
  print('В выражении используются переменные: $listOfLetters \n');

  do {
    print(
        'Введите значение для переменной - ${listOfLetters.elementAt(indexLetters)} = ');
    inputValueLetters = (stdin.readLineSync() ?? '').toString();
    (inputValueLetters, _) = getNumberFromString(inputValueLetters, 0);
    if (inputValueLetters == '') {
      print('Неверное число, попробуйте снова');
    } else {
      argOfLetters[listOfLetters.elementAt(indexLetters++)] = inputValueLetters;
    }
  } while (indexLetters < listOfLetters.length);
  print('Ваши переменные получили следующие значения: $argOfLetters');
  return argOfLetters;
}
