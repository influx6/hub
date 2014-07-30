part of hub;

class Valids{

  @deprecated
  static bool iS(n,m) => match(n,m);
  
  static bool notCollection = Funcs.compose(Valids.not,Valids.isCollection);

  static bool match(n,m){ return !!(n == m); }  
  static bool not(bool m){ return !m; }
  static bool isNot(n,m){ return Valids.not(Valids.match(n,m)); }

  static bool isNumber(a) => Valids.isNum(a) || Valids.isInt(a);
  static bool isCollection(a) => Valids.isList(a) || Valids.isMap(a);

  static bool isString(a) => a is String;
  static bool isNum(a) => a is num;
  static bool isInt(a) => a is int;
  static bool isRegExp(a) => a is RegExp;
  static bool isBool(a) => a is bool;
  static bool isDate(a) => a is DateTime;
  static bool isObject(a) => a is Object;
  static bool isOnlyObject(a) => !Valids.isString(a) && !Valids.isNumber(a) && !Valids.isCollection(a) && Valids.isObject(a);
  static bool isFunction(a) => a is Function;
  static bool isMap(a) => a is Map;
  static bool isList(a) => a is List;
  static bool exist(a) => Valids.not(Valids.match(a,null));
  static bool notExist(a){ return Valids.not(Valids.exist(a)); }
  static bool isTrue(a){ return (Valids.isBool(a) && a == true); }
  static bool isFalse(a){ return (Valids.isBool(a) && a == false); }
  static bool isOdd(int n) => n % 2 != 0;
  static bool isEven(int n) => n % 2 == 0;

  static Function lessThan(x,m) => x < m;
  static Function lessThanEqual(x,m) => x <= m;

  static Function greaterThan(x,m) => x > m;
  static Function greaterThanEqual(x,m) => x >= m;

}
