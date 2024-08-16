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

  double execute(String operator, double first, double second) =>
      switch (operator) {
        '+' => first + second,
        '-' => first - second,
        '*' => first * second,
        '/' => first / second,
        _ => 0,
      };

  int prioriOperation(String operator) => switch (operator) {
        '~' => 3,
        '/' => 2,
        '*' => 2,
        '+' => 1,
        '-' => 1,
        _ => 0,
      };
}

class Stack<E> {
  final _list = <E>[];

  void push(E value) => _list.add(value);
  E pop() => _list.removeLast();
  E get peek => _list.last;
  bool get isNotEmpty => _list.isNotEmpty;
}
