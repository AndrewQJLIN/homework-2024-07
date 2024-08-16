import 'dart:io';

import 'calculatorstring.dart';
import 'constantion.dart';

void main() {
  // список переменных в выражении
  Set<String> listOfLetters = {};

  // мапа [имя переменной]:[числовое значение]
  Map<String, String> argOfLetters = <String, String>{};

  // запрашиваем сроку с консоли
  var inputString = (stdin.readLineSync() ?? '').toString();

  // проверяем строку на ошибки и выделяем переменные
  listOfLetters = checkInputStrOnError(inputString);

// если есть ошибка - печатаем ее и выходим
  if (listOfLetters.isNotEmpty && listOfLetters.last[0] == '!') {
    print(listOfLetters.last);
    return;
  }

// если в выражении есть переменные - запрашиваем их у пользователя
  if (listOfLetters.isNotEmpty) {
    argOfLetters = getValueOfVariables(listOfLetters);
  }

  // создаем класс калькулятор и туда передаем исходное выражение и список из переменнных и их значений
  final CalculatorString calc = CalculatorString(inputString, argOfLetters);

  calc.finalStringPrint(); // покажем финальное выражение после подстановки всех элементов

  print('\nОтвет: ${calc.result()}'); // считаем и показываем ответ
}
