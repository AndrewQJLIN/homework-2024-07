import 'dart:io';

import 'constantion.dart';

void main() {
  Set<String> listOfLetters = {}; // список переменных в выражении
  bool checkOut;
  Map<String, String> argOfLetters =
  <String, String>{}; // словарь значений переменных в выражении

  var inputString =
  (stdin.readLineSync() ?? '').toString(); // запрашиваем сроку с консоли

  (checkOut, listOfLetters) = checkInputStrOnError(
      inputString); // проверяем строку на ошибки и выделяем переменные

  if (!checkOut) {
    print(listOfLetters.last); // если есть ошибка - печатаем ее и выходим
    return;
  }

  /// запрашиваем у пользователя значения переменных, если они есть в выражении
  if (listOfLetters.isNotEmpty) {
    var indexLetters = 0;
    String inputValueLetters;
    print('В выражении используются переменные: $listOfLetters \n');

    do {
      print(
          'Введите значение для переменной - ${listOfLetters.elementAt(
              indexLetters)} = ');
      inputValueLetters = (stdin.readLineSync() ?? '').toString();
      (inputValueLetters, _) = getNumberFromString(inputValueLetters, 0);
      if (inputValueLetters == '') {
        print('Неверное число, попробуйте снова');
      } else {
        argOfLetters[listOfLetters.elementAt(indexLetters++)] =
            inputValueLetters;
      }
    } while (indexLetters > listOfLetters.length - 1);
    print('Ваши переменные получили следующие значения: $argOfLetters');
  }

  inputString = getFinalString(inputString,
      argOfLetters); // формируем строку с учетом значений переменных и подставляя все знаки * (умножить) если их нет
  print('Постфиксная запись получила вид:');
  List<String> finalStrToCalc = getToPostFix(
      inputString); // преобразуем в постфиксеую запись
  print(finalStrToCalc);

  print('\nОтвет: ${calculatePostFix(finalStrToCalc)}'); // считаем ответ
}

double calculatePostFix(List<String> finalStrToCalc) {
  Stack<double> stack = Stack();
  String data;
  int counterOperation = 1;
  print('\nДействия:');
  for (data in finalStrToCalc) {
    if (double.tryParse(data) != null) {
      stack.push(double.parse(data)); // если это число кладем в стек
    } else {
      if (data ==
          '~') { // если это унарный минус - выполняем его как более высокий приоритет, иначе это другой оператор и тогла берем из стэка два последних числа и выполняем
        double last = stack.isNotEmpty ? stack.pop() : 0;

        stack.push(execute('-', 0, last));

        print('${counterOperation++}): $data $last = ${stack
            .peek}'); // выводим порядок операций
        continue;
      }
      double second = stack.isNotEmpty ? stack.pop() : 0;
      double first = stack.isNotEmpty ? stack.pop() : 0;

      stack.push(execute(data, first, second)); // результат кладем в стэк

      print('${counterOperation++}) $first $data $second = ${stack
          .peek}'); // выводим порядок операций
    }
  }
  return stack.peek; // то что осталос в стэке и есть ответ
}

String getFinalString(String inputString, Map<String, String> argOfLetters) {
  String finalStr = '';
  String outNumber;

  int currentPos = 0;

  while (currentPos < inputString.length) {
    var currentSymbol = inputString[currentPos];

    if (letters.contains(currentSymbol)) {
      if (currentPos == 0) {
        finalStr += argOfLetters[currentSymbol]!;
      } else {
        finalStr += (finalStr[finalStr.length - 1] == ')' ||
            validNumber.contains(finalStr[finalStr.length - 1]))
            ? '*'
            : '';
        finalStr += argOfLetters[currentSymbol]!;
      }
    } else if (validNumber.contains(currentSymbol)) {
      (outNumber, currentPos) = getNumberFromString(inputString, currentPos);
      finalStr += (finalStr.isNotEmpty && finalStr[finalStr.length - 1] == ')')
          ? '*'
          : '';
      finalStr += outNumber;
    } else if (currentSymbol == '(') {
      finalStr += (finalStr.isNotEmpty &&
          (validNumber.contains(finalStr[finalStr.length - 1]) ||
              finalStr[finalStr.length - 1] == ')'))
          ? '*'
          : '';
      finalStr += currentSymbol;
    } else {
      finalStr += currentSymbol;
    }
    currentPos++;
  }

  if (argOfLetters.isNotEmpty) {
    print('Ваше выражение с учетом значений переменных получило вид:');
  }
  print(finalStr);

  return finalStr;
}

List<String> getToPostFix(String inputString) {
  Stack stackOperation = Stack();

  List<String> postFixStr = [];
  var currentPosition = 0;
  String number;

  while (currentPosition < inputString.length) {
    var currentSymbol = inputString[currentPosition];

    if (validNumber.contains(currentSymbol)) {
      (number, currentPosition) =
      getNumberFromString(inputString, currentPosition);
      if (number != '') {
        postFixStr.add(number);
      }
    } else if (currentSymbol == '(') {
      stackOperation.push(currentSymbol);
    } else if (currentSymbol == ')') {
      while (stackOperation.isNotEmpty && stackOperation.peek != '(') {
        postFixStr.add(stackOperation.pop());
      }
      stackOperation.pop();
    } else {
      if (currentSymbol == '-' &&
          (currentPosition == 0 ||
              (currentPosition > 1 &&
                  validOperand.contains(inputString[currentPosition - 1]) ||
                  inputString[currentPosition - 1] == '('))) {
        currentSymbol = '~';
      }

      while (stackOperation.isNotEmpty &&
          (prioriOperation(currentSymbol) <
              prioriOperation(stackOperation.peek) ||
              prioriOperation(currentSymbol) ==
                  prioriOperation(stackOperation.peek))) {
        postFixStr.add(stackOperation.pop());
      }
      stackOperation.push(currentSymbol);
    }
    currentPosition++;
  }

  while (stackOperation.isNotEmpty) {
    postFixStr.add(stackOperation.pop());
  }

  return postFixStr;
}

int prioriOperation(String operator) =>
    switch (operator) {
      '~' => 3,
      '/' => 2,
      '*' => 2,
      '+' => 1,
      '-' => 1,
      _ => 0,
    };

/// передаем строку первоначального выражения *str* и позицию откуда начинать выбор *currentPosition*,
/// возвращаем число выбранное из строки ввода *numberByStr* как строку и позицию, откуда анализировать дальше *currentPosition*
/// если то, что получилось нельзя преобразовать в число в последствии - то возвращаемое значение будет пустым

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
(bool, Set<String>) checkInputStrOnError(String inputString) {
  bool checkOut = true;
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
      checkOut = false;
      arguments.add('Недопустимые символы в выражении');
    }
  }

  if (brackets != 0 && checkOut) {
    checkOut = false;
    arguments.add('Ошибка в выражении = Не парные скобки');
  }
  return (checkOut, arguments);
}

double execute(String operator, double first, double second) =>
    switch (operator) {
      '+' => first + second,
      '-' => first - second,
      '*' => first * second,
      '/' => first / second,
      _ => 0,
    };

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);

  E pop() => _list.removeLast();

  E get peek => _list.last;

  bool get isNotEmpty => _list.isNotEmpty;
}
