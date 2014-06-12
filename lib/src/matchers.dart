part of hub;

class Matchers{

	static Function asserts = Funcs.createMessageMatcher('asserts','bool values dont match!',(bool a,bool b){
	    if(Valids.match(a,b)) return true;
	    return false;
   },2);

    static Function isString = Funcs.createMessageMatcher('isString','is not a string!',(a){
	    if(a is String) return true;
	    return false;
	});

	static Function isNull = Funcs.createMessageMatcher('isNull','value is not null!',(a){
		if(Valids.exist(a)) return false;
		return true;
	});

}



class Expects{

	static Function asserts(a,b){
		var res = Matchers.asserts(a,b);
		if(Valids.isMap(res)) throw res;
	}

	
}