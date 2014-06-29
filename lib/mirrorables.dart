library mirrorables;

import 'package:hub/hub.dart';
@MirrorsUsed(targets: const["mirrorables"])
import 'dart:mirrors';

export 'package:hub/hub.dart';

class SingleLibraryManager{
  Symbol tag;
  final ms = currentMirrorSystem();
  LibraryMirror library;

  static SingleLibraryManager singleLibrary(library){
		return SingleLibraryManager.create(library);
  }
	
  static dynamic findLibrary(library){
		var ms = currentMirrorSystem();
		var lib = ms.findLibrary(Hub.encryptSymbol(library));
		if(lib == null) throw "Unable to find Library: $library";
		return lib;
   }
  
  static create(String n,[LibraryMirror lib]){
    if(lib != null) return new SingleLibraryManager.use(n,lib);
    return new SingleLibraryManager(n);
  }
  
  SingleLibraryManager(name){
    this.tag = Hub.encryptSymbol(name); 
    this._initLibrary();
  }
  
  SingleLibraryManager.use(name,LibraryMirror lib){
    this.tag = Hub.encryptSymbol(name);
    this.library = lib;
  }
  
  void _initLibrary(){
    try{
      var lib = this.ms.findLibrary(this.tag);
      if(lib == null) throw "Unable to find Library: ${Hub.decryptSymbol(this.tag)}";
      //this.library = lib.single;
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
    }
    return false;
  }
    
  dynamic getClass(String name){
    return this.library.declarations[Hub.encryptSymbol(name)];
  }
  
  dynamic getSetter(String name){
    return this.library.declarations[Hub.encryptSymbol(name)];
  }
    
  dynamic getGetter(String name){
    return this.library.declarations[Hub.encryptSymbol(name)];  
  }
  
  dynamic getFunction(String name){
    return this.library.declarations[Hub.encryptSymbol(name)];
  }
    
  dynamic getVariable(String name){
    return this.library.declarations[Hub.encryptSymbol(name)];
  }
  
  Map getAllMembers(String name){
    return this.library.topLevelMembers;
  }
      
  dynamic createClassInstance(String name,{String constructor: null,List pos:null,Map<Symbol,dynamic> named:null}){
    var cm = this.getClass(name);
    return cm.newInstance((constructor == null ? name : constructor), pos,named);
  }
  	
}
