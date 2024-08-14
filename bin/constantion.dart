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
final validPervSymbol = validNumber + [')']; // не используется
final validNextSymbol = validNumber + ['('];