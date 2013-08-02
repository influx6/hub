library hub.spec;

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
}