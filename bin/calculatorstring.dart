import 'dart:io';
import 'constantion.dart';

class CalculatorString {
  final String _inputString;
  final Map<String, String> _argOfLetters;

  String finalString = '';
  List<String> postFixList = [];

  double _result = 0;

  CalculatorString(this._inputString, this._argOfLetters) {
    finalString = getFinalString();
    postFixList = getToPostFix(finalString);
    }

  double result() {
    _result = calculatePostFix(postFixList);
    return _result;
  }

  void finalStringPrint() {
    if (_argOfLetters.isNotEmpty) {
      print('Ваше выражение с учетом значений переменных получило вид:');
    }
    print(finalString);
  }

  void finalPostFixPrint() {
    print('Постфиксная запись получила вид:');
    print(postFixList);
  }

// формируем окончательную строку подставляя вместо переменных значения и знак * между переменными
  String getFinalString() {
    String finalStr = '';
    String outNumber;

    int currentPos = 0;

    while (currentPos < _inputString.length) {
      var currentSymbol = _inputString[currentPos];

      if (letters.contains(currentSymbol)) {
        if (currentPos == 0) {
          finalStr += _argOfLetters[currentSymbol]!;
        } else {
          finalStr += (finalStr[finalStr.length - 1] == ')' ||
                  validNumber.contains(finalStr[finalStr.length - 1]))
              ? '*'
              : '';
          finalStr += _argOfLetters[currentSymbol]!;
        }
      } else if (validNumber.contains(currentSymbol)) {
        (outNumber, currentPos) = getNumberFromString(_inputString, currentPos);
        finalStr +=
            (finalStr.isNotEmpty && finalStr[finalStr.length - 1] == ')')
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
    return finalStr;
  }

  // формируем список в постфиксной записи
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
                        validOperand
                            .contains(inputString[currentPosition - 1]) ||
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

  // считаем постфиксную запись
  double calculatePostFix(List<String> finalStrToCalc) {
    Stack<double> stack = Stack();
    String data;
    int counterOperation = 1;
    print('\nДействия:');
    for (data in finalStrToCalc) {
      if (double.tryParse(data) != null) {
        stack.push(double.parse(data)); // если это число кладем в стек
      } else {
        if (data == '~') {
          // если это унарный минус - выполняем его как более высокий приоритет, иначе это другой оператор и тогда берем из стэка два последних числа и выполняем
          double last = stack.isNotEmpty ? stack.pop() : 0;

          stack.push(execute('-', 0, last));

          print(
              '${counterOperation++}): $data $last = ${stack.peek}'); // выводим порядок операций
          continue;
        }
        double second = stack.isNotEmpty ? stack.pop() : 0;
        double first = stack.isNotEmpty ? stack.pop() : 0;

        stack.push(execute(data, first, second)); // результат кладем в стэк

        print(
            '${counterOperation++}) $first $data $second = ${stack.peek}'); // выводим порядок операций
      }
    }
    return stack.peek; // то что осталось в стэке и есть ответ
  }

  double execute(String operation, double first, double second) =>
      switch (operation) {
        '+' => first + second,
        '-' => first - second,
        '*' => first * second,
        '/' => first / second,
        _ => 0,
      };

  int prioriOperation(String operation) => switch (operation) {
        '~' => 3,
        '/' => 2,
        '*' => 2,
        '+' => 1,
        '-' => 1,
        _ => 0,
      };

// 3 статические функции - получить из строки число, проверить все ли символы в выражении допустимы, запросить у пользователя значения переменных
  static (String, int) getNumberFromString(String str, int currentPosition) {
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

  static Set<String> checkInputStrOnError(String inputString) {
    Set<String> arguments = {};
    var brackets = 0;

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
        arguments.add('! Недопустимые символы в выражении: - $currentSymbol');
      }
    }

    if (brackets != 0) {
      arguments.add('! Ошибка в выражении = Не парные скобки');
    }
    return arguments;
  }

  static Map<String, String> getValueOfVariables(Set<String> listOfLetters) {
    var indexLetters = 0;
    String inputValueLetters;
    Map<String, String> argOfLetters = {};
    print('В выражении используются переменные: $listOfLetters \n');

    do {
      print(
          'Введите значение для переменной - ${listOfLetters.elementAt(indexLetters)} = ');
      inputValueLetters = (stdin.readLineSync() ?? '').toString();
      (inputValueLetters, _) = CalculatorString.getNumberFromString(inputValueLetters, 0);
      if (inputValueLetters == '') {
        print('Неверное число, попробуйте снова');
      } else {
        argOfLetters[listOfLetters.elementAt(indexLetters++)] = inputValueLetters;
      }
    } while (indexLetters < listOfLetters.length);
    print('Ваши переменные получили следующие значения: $argOfLetters');
    return argOfLetters;
  }
}

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);
  E pop() => _list.removeLast();
  E get peek => _list.last;
  bool get isNotEmpty => _list.isNotEmpty;
}
