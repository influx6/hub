library hub.spec;

import 'dart:async';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){
	
	Map<Symbol,dynamic> a = new Map<Symbol,dynamic>();
	Map<String,dynamic> b = new Map<String,dynamic>();
	var cache = Hub.createSymbolCache();
	
	var c = cache.create('c');
	a[new Symbol('a')]='aa';
	b['b']='ba';
		
	assert(cache.create('c') == c);
	assert(Hub.decryptNamedArguments(a) is Map<String,dynamic>);
	assert(Hub.encryptNamedArguments(b) is Map<Symbol,dynamic>);
	
	Hub.captureEachFuture([1,2,3,4,5,6],(n){ if(n != null) return n * 4; }).then((_){
		assert(_.first == 4);
		assert(_.last == 24);
		assert(_.length == 6);
	});
	
	var dist = Hub.createDistributor('example');
  
	dist.on((n){ assert(n is num); });
  
	dist.whenDone((n){  assert(n is num); }); 
	
	dist.emit(4);
  dist.emit(6);
	
	var mutate = Hub.createMutator('mutator');
	mutate.on((n){ return n*4; });
  mutate.on((n){ return n+2; });
  mutate.on((n){ return n/2; });
  
  mutate.whenDone((n){
    assert(n is num);
  });
  
  mutate.emit(2);
  mutate.emit(100);
  mutate.emit(1);
  mutate.emit(50);
  
  var jector = LengthInjector.create(4);
  jector.on((n){
    assert(n.length == 4);
  });
  
  jector..push(1)..push(2)..push(3)..push(4);

  var poster = PositionInjector.create(4,(t,c){
    if(t.length > 3) return true; return false; 
  });
  poster.on((n){
    assert(n.first == 'sucker');
    assert(n.length == 4);
  });
  
  poster..push(0,'sucker')..push(4,'logger')..push(3,'ruber')..push(2,'caller');
  
  //i noted that its preferable to set the 0 index element at the first of the call or as a separate call,
  //if push(0,item) is put on the last of the .. chain,it will default into an index error,not my fault,its
  //the Map add function system.
  poster.push(0,'crocker');
  poster..push(10,'soccer');
  
  
  var sparce = SparceList.create();
  sparce.add(0,'john');
  sparce..add(2,'alex')..add(1,'john')..add(5,'mary');
  
  assert(sparce.sorted().first == 'john');
  
  var rand = new math.Random();
  var f = null;
  
  assert(Hub.merge({'a':1},{'a':4,'b':2},override: false).length == 2);

  assert(Enums.filterValues(Enums.map([1,3,32],(e,i,o) => e*3),(e,i,o){ 
    if(e%2 == 0) return true; 
    return false; 
  })[0] == 96);

  var isString = Funcs.createMessageMatcher('isString','is not a string!',(a){
    if(a is String) return true;
    return false;
  });
  
  assert(isString('alex') == true);
  assert(isString(1) is Map);
  
  var sum = Funcs.dualPartial((a,b) => a+b);
  var diff = Funcs.dualCurry((a,b) => a-b);
  
  assert(sum(1)(2) == 3);
  assert(diff(2)(1) == 1);
  
  var addDouble = Funcs.compose((a){ return a*2; },(a,b){ return a + b; },2);
  assert(addDouble(1,2) == 6);
  
  var indexfor = Enums.indexFor({'a':1, 'b':1,'c':2});
  assert(indexfor(1).length == 2);
  
  assert(Valids.isNot(1,1) == false);
  
  var mustbe1 = Funcs.then((n){
    return n == 1;
  },(state){
    assert(!!state);
  },(state){
    assert(!state);
  });
    
  mustbe1(2); mustbe1(1);
  
  var sum3 = Funcs.applyPartial((a,b,c){ return a+b+c; },3);
  var sum3r = Funcs.applyCurry((a,b,c){ return a+b+c; },3);
  assert(sum3(1)(2)(3) == 6);
  assert(sum3r(3)(2)(1) == 6);
  
  var addDoubler = Funcs.applyComposable((a){ return a*2; },(a,{b:null}){ return a + b; });
  assert(addDoubler([2],{'b':3}) == 10);
  
  assert(Enums.reduce([2,7,13],(memo,e,i,o){
    return memo - e;
  }) == -18);

  assert(Enums.reduceRight([2,3,32],(memo,e,i,o){
    return memo - e;
  }) == 27);

  var condition = Hub.createCondition('test');

  condition.on(Valids.exist);
  condition.on((n){ return Valids.match(n,'1'); });
  condition.on(Valids.isString);
  condition.whenDone((n){ assert(n == '1'); });
  condition.onOnce((n){ assert(n == '1'); });
  condition.emit('1');
  condition.emit(1);

}
