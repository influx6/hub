library hub;

import 'dart:math' as math;
import 'dart:async';
import 'dart:convert';

part 'validators.dart';
part 'enums.dart';
part 'functionals.dart';
part 'matchers.dart';
part 'extensions.dart';


class Hub{

    static String escapeHtml(String m){
     return m.replaceAll(r'\n','\\n').
      replaceAll(r'\r','\\r').
      replaceAll(r"'","\\").
      replaceAll(r"/&","&amp").
      replaceAll(r'<','&lt;').
      replaceAll(r'>','&gt;').
      replaceAll(r'>','&gt;').
      replaceAll(r'\"','%quot;');
    }

    static num getHash(dynam n) => n.hashCode;

    static num calHash(Map m,[String j]){
        j = Funcs.switchUnless(j,'');
        var hash = [];
        if(m is Map) m.forEach((v,k){ hash.add(Hub.getHash(k)); });
        if(m is List) m.forEach((f){ hash.add(Hub.getHash(f)); });
        return hash.join(j);
    }

    static Map merge(Map a,Map b,{bool override: true}){
        return Enums.merge(a, b, override: override);
    }

    static void cycle(int times,Function fn){
        return Funcs.cycle(times, fn);
    }

    static String randomStringsets(int len,[String separator]){
        var set = new List();
        var buffer = new StringBuffer();
        var rand = new math.Random();
        var max = _smallA.length;

        Hub.cycle(len, (n){
          var ind = rand.nextInt(max - 1);
          var shake = ind + rand.nextInt((max ~/ 2).toInt());
          
          if(ind >= max) ind = ((ind ~/((n + 1) * 2))).toInt();
          if(shake >= max) shake = ((shake ~/((n+1) * 4))).toInt();
                
          buffer.write(shake);
          buffer.write(_smallA.elementAt(ind));
          buffer.write(ind);
          buffer.write(_bigA.elementAt(shake));
          
          set.add(buffer.toString());
          buffer.clear();
        });

        return set.join((separator != null ? separator : '-'));
    }

    static dynamic randomString(int len,[int max]){
      var set = Hub.randomStringsets(len);
      return set.substring(0,(max != null ? (max >= set.length ? set.length : max) : set.length));
    }

    static Counter createCounter(h){
      return new Counter(h);
    }

    static Condition createCondition(n){
      return Condition.create(n);
    }

    static ListInjector createListInjector(max,[f,g]){
      return ListInjector.create(max,f,g);  
    }

    static LengthInjector createLengthInjector(max,[f,g]){
      return LengthInjector.create(max,f,g);  
    }

    static PositionInjector createPositionalInjector(max,[f,g]){
      return PositionInjector.create(max, f, g);
    }

    static SparceList createSparceList([max]){
      return SparceList.create(max);
    }

    static Mutator createMutator(String id){
      return new Mutator(id);
    }

    static Distributor createDistributor(String id){
      return new Distributor(id);
    }

    static MapDecorator createMapDecorator(){
      return new MapDecorator();
    }

    static int findMiddle(List a,int start,int length,bool compare(n,m)){
       int last = (start + (length - 1)).toInt();
       int mid =  ((start + (length / 2))).toInt();
            
       if(!!compare(a.elementAt(start),a.elementAt(last)) && !!compare(a.elementAt(start),a.elementAt(mid))){
          if(!!compare(a.elementAt(mid),a.elementAt(last))) return mid;
          return start;
       }
       
       if(!!compare(a.elementAt(mid),a.elementAt(start)) && !!compare(a.elementAt(mid),a.elementAt(last))){
         if(!!compare(a.elementAt(start),a.elementAt(last))) return start;
         return mid;
       }
       
       if(!!compare(a.elementAt(last),a.elementAt(mid)) && !!compare(a.elementAt(last),a.elementAt(start))){
         if(!!compare(a.elementAt(mid),a.elementAt(start))) return mid;
         return last;
       }
    }

    @deprecated 
    static List quickSort(List a,int first,int size,bool compare(n,m)){
      return Enums.heapSort(a,compare,first,size);
    }

    static dynamic findClass(libraryName,className){
      var lib = Hub.singleLibrary(libraryName);
      return lib.getClass(className);
    }
                
    static void eachAsync(List a,Function iterator,[Function complete]){
        return Enums.eachAsync(a, iterator,complete);
    }

   static void eachAsyncMap(Map a,Function iterator,[Function complete]){
      return Enums.eachAsyncMap(a, iterator,complete);
    }
         
    static void eachSyncMap(Map a,Function iterator, [Function complete]){
      return Enums.eachSyncMap(a, iterator,complete);
    }

    static void eachSync(List a,Function iterator, [Function complete]){
      return Enums.eachSync(a, iterator,complete);
    }
        
    static dynamic switchUnless(m,n){
      return Funcs.switchUnless(m, n);
    }

    static dynamic when(bool f,Function n,[Function m]){
      return Funcs.when(f, n,m);
    }

    static dynamic throwNoSuchMethodError(Invocation n,Object c){
      throw new NoSuchMethodError(
              c,
              n.memberName,
              n.positionalArguments,
              n.namedArguments);
    }
        
    static SymbolCache createSymbolCache(){
        return new SymbolCache();
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
      var sm = Hub.symbolRegExp.firstMatch(n.toString());
      if(sm == null) return null;
      return sm.group(1).replaceAll('"','');
    }

    static RegExp symbolRegExp = new RegExp(r'Symbol\((\W+\w+\W+)\)');

    static String getClassName(Object m){
        return Hub.decryptSymbol(reflectClass(m).simpleName);
    }

    static List map(dynamic m,Object mod(i,j,k)){
      return Enums.map(m, mod);
    }

    static List filterValues(dynamic m,bool mod(i,j,k)){
      return Enums.filterValues(m, mod);
    }

    static List filterKeys(dynamic m,bool mod(i,j,k)){
      return Enums.filterKeys(m, mod);
    }
      
}
