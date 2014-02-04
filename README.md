#Hub
####Description:
	a simple library containing static helpers

####Helpers
	State: provides an object that has a set level of functions that run when activate
	StateManager: provides a higher level object that uses state objects as a means of manager state
	Switch: a basic object with a on or off state,allowing to do a truthy or falsy checker
	Distributor: a basic list that accepts functions and then propagates a value to all when its emit method is called
	Transformable: takes a function and passes all values to that function for mutation
	SymbolCache: a simple factory of symbols which caches them on creation for reuse
	MapDecorator: a decorates a map with get,update,destroy calls
	SingleLibraryManager: allows grabbing a library definition from the current MirrorSystem
	Counter: a simple class that provides a increment,decrement function calls
	SparceList: provides a means of adding items into an array at any position,underneath it uses a map,which turns into an array when calling its toList method
	Mutator: a simple object that takes a set of functions,
		 where each results from the previous mutates the value used to call the next one.
	Injector: provides a base class for activation of a routine depending on the truthy or falsy value of
		a condition function, eg 
		ListInjector: takes items into array and when the condition set is matched,ejects those values out
		PostionInjector: injects into specific position of an array and when it matches the required condition,ejects the array
		LengthInjector: takes values into an array and if length matches its specified value,ejects a new array with the values it received
		
####Static Helpers
	map, eachSync,eachAsync,eachSyncMap,eachAsyncMap,filterValues,filterKeys,compose
	
	createMessageMatcher: creates a function that checks the truthy state of a function with a value and returns true or a map with a predefined message of failure
	randomString: takes a number and generates an array containing random strings for each index of the array
	cycle: runs a function for a specified number of times
	merge: merges to maps into a new map,a basic union operation,allows values destructions 
	quickSort: provides a restrictive quicksort algorithm on a list
	findMiddle: finds the middle value's index in a list of numbers
	classMirrorInvokeNamedSupportTest: checks wether the current mirror system allows using named arguments
	findLibrary, findClass: finds a class/library with the mirrorsystem
	switchUnless: checks if a value is null and switches a default value for it else returns that value
	encryptNamedArguments: turns a Map<String,dynamic> into a Map<Symbol,dynamic>
	decryptNamedArguments: turns a Map<Symbol,dynamic> into a Map<String,dynamic>
	encryptSymbol: turns a string into a symbol
	decryptSymbol: turns a symbol into a string
	dualPartial: takes a function and returns a function that awaits 2 values which it then runs on the supplied function,a basic partial for 2 values
	dualCurry: takes a function and awaits supply of its arguments in a backward(right to left manner), a basic two value curry function
	matchMapConditions/matchListConditions: takes a set of functions and runs a value on them,returns a future that completes with an error if any condition function fails
	captureMapConditions/captureListConditions: takes a set of functions and runs a value on them,returning a map/list of the return values for those functions,
		allows doing a condition matchers that return errors or messages on why a value failed to pass a condition
	compose: takes two functions and binds the return a new function that binds the return value of one as the input of the other
	
####Example:

	
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
		 
		assert(Hub.merge({'a':1},{'a':4,'b':2},override: false)['a'] == 1);
		assert(Hub.merge({'a':1},{'a':4,'b':2})['a'] == 4);

		assert(Hub.filterValues(Hub.map([1,3,32],(e,i,o) => e*3),(e,i,o){ 
		    if(e%2 == 0) return true; 
		    return false; 
		})[0] == 96);

		var isString = Hub.createMessageMatcher('isString','is not a string!',(a){
		    if(a is String) return true;
		    return false;
		});
		  
		assert(isString('alex') == true);
		assert(isString(1) is Map);	
		
		var sum = Hub.dualPartial((a,b) => a+b);
		var diff = Hub.dualCurry((a,b) => a-b);
	  
		assert(sum(1)(2) == 3);
		assert(diff(2)(1) == 1);


		var play = State.create({ 'name':'alex','paused': false},{
		  'play': (target,controller){ print('${target['name']} playing song? isPaused: ${target['paused']}'); },
		  'pause': (target,controller){ target['paused'] = true; controller.run('play'); }
		},'player');
		
		var man = StateManager.create(play);
		man.add('play',{
		  'play':(target,control){ target.activate(); target.run('play'); },
		  'pause':(target,control){ }
		});
		man.add('pause',{
		  'play':(target,control){ },
		  'pause':(target,control){ target.run('pause'); target.deactivate(); }
		});
		
		play.run('play'); -> runs the current state play function
		//  man.switchState('play');
		//  no reaction since state is null
		man.run('play'); 
		man.run('pause');
		//switching to play state
		man.switchState('play'); -> if state was pause then calls pause.deactivate(),switches state to play & calls play.activate()
		//should get response with play but not pause
		man.run('play'); 
		man.run('pause');
		//switching to pause state
		man.switchState('pause');
		//pause should respond not play
		man.run('play'); man.run('pause');	

	