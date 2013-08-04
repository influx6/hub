library hub;

import 'dart:collection';
import 'dart:mirrors';
import 'dart:async';
// import 'dart:crypto';

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

class Hub{
		
	static Future forEachFuture(dynamic a,Function validator){
		var future;
		if(a is List){
			a.forEach((n){
				if(future != null) future.then(new Future.value(validator(n)));
				else future = new Future.value(validator(n));
			});
		}
		if(a is Map){
			a.forEach((n,v){
				if(future != null) future.then(new Future.value(validator(v)));
				else future = new Future.value(validator(v));
			});
		}
		return future;
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
}