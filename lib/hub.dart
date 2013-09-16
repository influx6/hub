library hub;

import 'dart:collection';
import 'dart:mirrors';
import 'dart:async';

class _SymbolCache{
	var _cache = {};
	
	_SymbolCache();
		
	Symbol create(String id){
		if(this._cache.containsKey(id)) return this._cache[id];
		return (this._cache[id] = Hub.encryptSymbol(id));
	}
	
	void destroy(String id){
		this._cache.remove(id);
	}
	
	void flush() => this._cache.clear();
	
	String toString() => "SymbolCacheObject";
}

class MapDecorator{
	final storage;
	
	static create(){
		return new MapDecorator();
	}
		
	MapDecorator(): storage = new Map();

	MapDecorator.from(Map a): storage = new Map.from(a);
	
		
	dynamic get(String key){
		if(this.has(key)) return this.storage[key];
		return null;
	}
			
	bool add(String key,dynamic val){
		if(!this.has(key)){ this.storage[key] = val; return true; }
		return false;
	}

	bool update(String key,dynamic val){
		if(this.has(key)){ this.storage[key] = val; return true; }
		return false;
	}

	dynamic destroy(String key){
		if(!this.has(key)) return null; 
		return this.storage.remove(key);		
	}
		
	bool has(String key){
		if(!this.storage.containsKey(key)) return false;
		return true;
	}
	
	void onAll(Function n) => this.storage.forEach(n);
	
	void flush(){
		this.storage.clear();
	}
	
	String toString(){
		return this.storage.toString();
	}

}

class _SingleLibraryManager{
	Symbol tag;
	final ms = currentMirrorSystem();
	LibraryMirror library;
	
	static create(String n,[LibraryMirror lib]){
		if(lib != null) return new _SingleLibrary.use(n,lib);
		return new _SingleLibraryManager(n);
	}
	
	_SingleLibraryManager(name){
		this.tag = Hub.encryptSymbol(name); 
		this._initLibrary();
	}
	
	_SingleLibraryManager.use(name,LibraryMirror lib){
		this.tag = Hub.encryptSymbol(name);
		this.library = lib;
	}
	
	void _initLibrary(){
		try{
			var lib = this.ms.findLibrary(this.tag);
			if(lib == null) throw "Unable to find Library: ${Hub.decryptSymbol(this.tag)}";
			this.library = lib.single;
		}catch(e){
		 	throw "Library Not Found ${this.tag}";
		}
	}
	
	bool matchClassWithInterface(String className,String interfaceName){
		var simpleIName = Hub.encryptSymbol(interfaceName);
		var cl = this.getClass(className);
		if(cl == null) return false;
		var  ci = cl.superinterfaces;
		for(var n in ci){
			if(n.simpleName != simpleIName) continue;
			return true;
			break;
		}
		return false;
	}
		
	dynamic getClass(String name){
		return this.library.classes[Hub.encryptSymbol(name)];
	}
	
	dynamic getSetter(String name){
		return this.library.setters[Hub.encryptSymbol(name)];
	}
		
	dynamic getGetter(String name){
		return this.library.getters[Hub.encryptSymbol(name)];	
	}
	
	dynamic getFunction(String name){
		return this.library.functions[Hub.encryptSymbol(name)];
	}
		
	dynamic getVariable(String name){
		return this.library.variables[Hub.encryptSymbol(name)];
	}
	
	Map getAllMembers(String name){
		return this.library.members;
	}
			
	dynamic createClassInstance(String name,{String constructor: null,List pos:null,Map<Symbol,dynamic> named:null}){
		var cm = this.getClass(name);
		return cm.newInstance((constructor == null ? name : constructor), pos,named);
	}
	
	
}

class Hub{
	
	static MapDecorator createMapDecorator(){
		return new MapDecorator();
	}
		
	static bool classMirrorInvokeNamedSupportTest(){
		try{
			var simpleclass = reflectClass(Map);
			Map<Symbol,dynamic> named = new Map<Symbol,dynamic>();
			simpleclass.invoke(new Symbol('toString'),[],named);
		}on UnimplementedError{
			return false;
		}on Exception catch(e){
			return true;
		}
		return true;
	}
	
	static dynamic findClass(libraryName,className){
		var lib = Hub.singleLibrary(libraryName);
		return lib.classes[Hub.encryptSymbol(className)];
	}
		
	static _SingleLibraryManager singleLibrary(library){
		return _SingleLibraryManager.create(library);
	}
	
	static dynamic findLibrary(library){
		var ms = currentMirrorSystem();
		var lib = ms.findLibrary(Hub.encryptSymbol(library));
		if(lib == null) throw "Unable to find Library: $libraryName";
		return lib;
	}
		
	static Future eachFuture(dynamic a,Function validator){
		var future;
		if(a.isEmpty) return new Future.value(true);
		if(a is List){
			a.forEach((n){
				if(future != null) future.then((_){ return new Future.value(validator(n)); });
				else future = new Future.value(validator(n));
			});
		}
		if(a is Map){
			a.forEach((n,v){
				if(future != null) future.then((_){ return new Future.value(validator(n,v)); });
				else future = new Future.value(validator(n,v));
			});
		}
		return future;
	}
	
	static Future captureEachFuture(dynamic a,Function validator){
		var res = [];
		
		if(a.isEmpty) return future;
		
		if(a is List){
			a.forEach((n){
				res.add(new Future.value(validator(n)));
			});
		}
		if(a is Map){
			a.forEach((n,v){
				res.add(new Future.value(validator(n,v)));
			});
		}
		
		return Future.wait(res);
	}
		
	static final symbolMatch = new RegExp(r'\(|Symbol|\)');
	
	static dynamic throwNoSuchMethodError(Invocation n,Object c){
		throw new NoSuchMethodError(
			c,
			Hub.decryptSymbol(n.memberName),
			n.positionalArguments,
			Hub.decryptNamedArguments(n.namedArguments));
	}
	
	static _SymbolCache createSymbolCache(){
		return new _SymbolCache();
	}
		
  static Map encryptNamedArguments(Map params){
    Map<Symbol,dynamic> p = new Map<Symbol,dynamic>();
    if(params.isEmpty) return p;
    params.forEach((k,v){
      if(k is! Symbol) p[Hub.encryptSymbol(k)] = v;
      else p[k] = v;
    });
    return p;
  }

  static Map decryptNamedArguments(Map params){
    Map<String,dynamic> o = new Map<String,dynamic>();
    if(params.isEmpty) return o;
    params.forEach((k,v){
      if(k is String) o[k] = v;
  else o[Hub.decryptSymbol(k)] = v;
    });
    return o;
  }
	
	static Symbol encryptSymbol(String n){
		return new Symbol(n);
	}
	
	static String decryptSymbol(Symbol n){
		return MirrorSystem.getName(n);
	}
	
  static String getClassName(Object m){
		return Hub.decryptSymbol(reflectClass(m).simpleName);
  }
}
