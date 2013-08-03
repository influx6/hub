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
		
	static final symbolMatch = new RegExp(r'\(|Symbol|\)');
	
	static bool isNamed(List<ParameterMirror> a){
		print(a);
		for(var i in a){
			if(!i.isNamed) continue;
			return true;
			break;
		}
		return false;
	}
	
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
      if(params.isEmpty) return params;
      Map<Symbol,dynamic> p = new Map<Symbol,dynamic>();
      params.forEach((k,v){
        if(k is! Symbol) p[Hub.encryptSymbol(k)] = v;
        else p[k] = v;
      });
      return p;
    }
	
    static Map decryptNamedArguments(Map params){
      if(params.isEmpty) return {};
      Map<String,dynamic> o = new Map<String,dynamic>();
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