part of hubutils;


class Matchers{

  static Function asserts = Funcs.createMessageMatcher('asserts','values dont match!',(a,b){
    if(Valids.match(a,b)) return true;
    return false;
   },2);

  static Function isString = Funcs.createMessageMatcher('isString','is not a string!',(a){
    if(a is String) return true;
    return false;
  });

  static Function isNull = Funcs.createMessageMatcher('isNull','is not null!',(a){
    if(Valids.exist(a)) return false;
    return true;
  });

  static Function isNumber = Funcs.createMessageMatcher('isNumber','is not a number',(a){
    if(Valids.isNumber(a)) return true;
    return false;
  });

  static Function isInt = Funcs.createMessageMatcher('isInt','is not a integer',(a){
    if(Valids.isInt(a)) return true;
    return false;
  });

  static Function isDouble = Funcs.createMessageMatcher('isDouble','is not a integer',(a){
    if(Valids.isDouble(a)) return true;
    return false;
  });

  static Function isRegExp = Funcs.createMessageMatcher('isRegExp','is not regexp object',(a){
    if(Valids.isRegExp(a)) return true;
    return false;
  });

  static Function isList = Funcs.createMessageMatcher('isList','is not a list',(a){
    if(Valids.isList(a)) return true;
    return false;
  });

  static Function isMap = Funcs.createMessageMatcher('isMap','is not map',(a){
    if(Valids.isMap(a)) return true;
    return false;
  });

  static Function isCollection = Funcs.createMessageMatcher('isCollection','is not a collection',(a){
    if(Valids.isCollection(a)) return true;
    return false;
  });

  static Function isDate = Funcs.createMessageMatcher('isDateTime','is not a datetime object',(a){
    if(Valids.isDate(a)) return true;
    return false;
  });

  static Function isBool = Funcs.createMessageMatcher('isBool','is not a boolean',(a){
    if(Valids.isBool(a)) return true;
    return false;
  });

  static Function exists = Funcs.createMessageMatcher('exists','is a null value',(a){
    if(Valids.exist(a)) return true;
    return false;
  });

  static Function existNot = Funcs.createMessageMatcher('existNot','is not a null value',(a){
    if(Valids.notExist(a)) return true;
    return false;
  });

  static Function isTrue = Funcs.createMessageMatcher('isTrue','is not a truth value',(a){
    if(Valids.isTrue(a)) return true;
    return false;
  });

  static Function isFalse = Funcs.createMessageMatcher('isFalse','is not a false value',(a){
    if(Valids.isFalse(a)) return true;
    return false;
  });

  static Function isTruthy = Funcs.createMessageMatcher('isTruthy','is not a truth value',(a){
    if(Valids.truthy(a)) return true;
    return false;
  });

  static Function isFalsy = Funcs.createMessageMatcher('isFalsy','is not a false value',(a){
    if(Valids.falsy(a)) return true;
    return false;
  });

  static Function isOdd = Funcs.createMessageMatcher('isOdd','is not a odd value',(a){
    if(Valids.isOdd(a)) return true;
    return false;
  });

  static Function isEven = Funcs.createMessageMatcher('isEven','is not a odd value',(a){
    if(Valids.isEven(a)) return true;
    return false;
  });

  static Function bigger = Funcs.createMessageMatcher('bigger','first value is not greater than the other',(a,b){
    if(Valids.greaterThan(a,b)) return true;
    return false;
  },2);

  static Function lesser = Funcs.createMessageMatcher('lesser','first value is not less than the other',(a,b){
    if(Valids.lessThan(a,b)) return true;
    return false;
  },2);

  static Function bigSame = Funcs.createMessageMatcher('bigSame','first value is not greater than or equal the other',(a,b){
    if(Valids.greaterThanEqual(a,b)) return true;
    return false;
  },2);

  static Function lessSame = Funcs.createMessageMatcher('lessSame','first value is not less than the other',(a,b){
    if(Valids.lessThanEqual(a,b)) return true;
    return false;
  },2);

  static Function isFunction = Funcs.createMessageMatcher('isFunction','is not a Function',(a){
    if(Valids.isFunction(a)) return true;
    return false;
  });

}



class Expects{

  static Function throwHandle(dynamic k){ if(Valids.isMap(k)) throw k; }
  static Function asserts = Funcs.compose(Expects.throwHandle,Matchers.asserts,2);
  static Function lesser = Funcs.compose(Expects.throwHandle,Matchers.lesser,2);
  static Function bigger = Funcs.compose(Expects.throwHandle,Matchers.bigger,2);
  static Function lessSame = Funcs.compose(Expects.throwHandle,Matchers.lessSame,2);
  static Function bigSame = Funcs.compose(Expects.throwHandle,Matchers.bigSame,2);
  static Function isFunction = Funcs.compose(Expects.throwHandle,Matchers.isFunction);
  static Function isEven = Funcs.compose(Expects.throwHandle,Matchers.isEven);
  static Function isOdd = Funcs.compose(Expects.throwHandle,Matchers.isOdd);
  static Function isString = Funcs.compose(Expects.throwHandle,Matchers.isString);
  static Function isNull = Funcs.compose(Expects.throwHandle,Matchers.isNull);
  static Function isNumber = Funcs.compose(Expects.throwHandle,Matchers.isNumber);
  static Function isInt = Funcs.compose(Expects.throwHandle,Matchers.isInt);
  static Function isDouble = Funcs.compose(Expects.throwHandle,Matchers.isDouble);
  static Function isRegExp = Funcs.compose(Expects.throwHandle,Matchers.isRegExp);
  static Function isList = Funcs.compose(Expects.throwHandle,Matchers.isList);
  static Function isMap = Funcs.compose(Expects.throwHandle,Matchers.isMap);
  static Function isCollection = Funcs.compose(Expects.throwHandle,Matchers.isCollection);
  static Function isDate = Funcs.compose(Expects.throwHandle,Matchers.isDate);
  static Function isBool = Funcs.compose(Expects.throwHandle,Matchers.isBool);
  static Function exists = Funcs.compose(Expects.throwHandle,Matchers.exists);
  static Function existNot = Funcs.compose(Expects.throwHandle,Matchers.existNot);
  static Function truthy = Funcs.compose(Expects.throwHandle,Matchers.isTruthy);
  static Function falsy = Funcs.compose(Expects.throwHandle,Matchers.isFalsy);
  static Function isTrue = Funcs.compose(Expects.throwHandle,Matchers.isTrue);
  static Function isFalse = Funcs.compose(Expects.throwHandle,Matchers.isFalse);

}
