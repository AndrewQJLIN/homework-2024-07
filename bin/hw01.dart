import 'dart:io';
import 'calculatorstring.dart';


void main() {


  Map<String, String> argOfLetters =
      <String, String>{}; // мапа [имя переменной]:[числовое значение]

  var inputString =
      (stdin.readLineSync() ?? '').toString(); // запрашиваем сроку с консоли

  Set<String> listOfLetters = CalculatorString.checkInputStrOnError(
      inputString); // проверяем строку на ошибки и выделяем переменные

  if (listOfLetters.isNotEmpty && listOfLetters.last[0] == '!') {
    print(listOfLetters.last); // если есть ошибка - печатаем ее и выходим
    return;
  }
// если в выражении есть переменные - запрашиваем их у пользователя
  if (listOfLetters.isNotEmpty) {
    argOfLetters = CalculatorString.getValueOfVariables(listOfLetters);
  }

  // создаем класс калькулятор и туда передаем исходное выражение и список из переменнных и их значений
  final CalculatorString calc = CalculatorString(inputString, argOfLetters);

  calc.finalStringPrint(); // покажем финальное выражение после подстановки всех элементов
  // calc.finalPostFixPrint();        // покажем постфиксную запись

  print('\nОтвет: ${calc.result()}'); // считаем и показываем ответ
}
