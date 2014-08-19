part of hub;

class Funcs{

  static Function emptyFunction(){}
  static Function emptySingleFunction([a]){}
  static Function emptyDualFunction([a,b]){}

  static String quote(dynamic m){
    return "'"+ m.toString() + "'";
  }

  static String doubleQuote(dynamic m){
    return '"'+ m.toString() + '"';
  }

  static String combineStrings(String f,String s,[String t]){
    t = Funcs.switchUnless(t,'');
    return f.toString() + s.toString() + t.toString();
  }

  static String prettyPrint(dynamic m,[int indent,int gaplevel,String joind]){
    indent = Funcs.switchUnless(indent,1);
    gaplevel = Funcs.switchUnless(gaplevel,1);
    joind = Funcs.switchUnless(joind,'');

    if(indent >= 3) indent = 2;

    var res = [],
        gp = Funcs.rangeFill(gaplevel,' ').join(''),
        ig = Funcs.rangeFill(indent,Funcs.combineStrings(gp,'\n')).join('');

    Funcs.when(Valids.isNumber(m),(){
        res.add(m.toString());
    });

    Funcs.when(Valids.isString(m),(){
        res.add(Funcs.doubleQuote(m));
    });

    Funcs.when(Valids.isList(m),(){
      var gap = gaplevel,bg = gp, r = [];

      if(gap > 2){ gap = 1; bg = Funcs.rangeFill(gap,' ').join('');}

      m.forEach((f){
        r.add(Funcs.prettyPrint(f,indent,gaplevel,joind));
      });
      res = [Funcs.combineStrings('[',bg),
        r.join(Funcs.combineStrings(bg,',',bg)),
        Funcs.combineStrings(bg,']')];
    });

    Funcs.when(Valids.isMap(m),(){
      var f,key,val,r = [];
      m.forEach((k,v){
          key = Funcs.combineStrings(gp,Funcs.combineStrings(Funcs.doubleQuote(k),':',' '));
          val = Funcs.prettyPrint(v,indent+1,gaplevel+3,joind);
          r.add(Funcs.combineStrings('\n',Funcs.combineStrings(ig,key,val),','));
      });

      f = Funcs.combineStrings('',r.join(''));
      res = [Funcs.combineStrings('{',''),f,Funcs.combineStrings(ig,gp,'}')];
    });

    Funcs.when(Valids.isOnlyObject(m),(){

      Funcs.when(Valids.isDate(m),(){
          res.add(Funcs.doubleQuote(m.toUtc().toString()));
      },(){
          try{
            res.add(JSON.encode(m));
          }catch(e){
            res.add(m.toString());
          }
      });


    });

    Funcs.when(Valids.isFunction(m),(){
        res.add(m.toString());
    });

    return res.join(joind);
  }

  static Function single(List<Function> ops,[int x,Function gh]){  
    if(Valids.isOdd(ops.length)){
        ops = [Funcs.identity];
        ops.addAll(ops);
      }

      if(ops.length <= 0) return gh;

      var fs = Enums.yankFirst(ops), se = Enums.yankFirst(ops);
      var nx = (ops.length <= 2 ? x : 1 );

      if(Valids.notExist(fs) || Valids.notExist(se)) return null;

      gh = Funcs.compose(fs,se,nx);

      return Funcs.single(ops,x,gh);
  }

  static Function futureBind(){
    var ftrue = Funcs.alwaysTrue();
    var ffalse = Funcs.alwaysFalse();
    bool val = false;
    return ([bool n]){
      if(Valids.exist(n)) val = n;
      return !!val ? ftrue() : ffalse();
    };
  }

  static Function defferedReply(Function before,Function after){
    return ([n]){
      if(!Valids.exist(n)) return before(n);
      return after(n);
    };
  }

  static Function alwaysTrue(){
    return (){ return true; };
  }

  static Function alwaysFalse(){
    return (){ return false; };
  }
  
  static Function singleDiscard(Function n){
    return (m){
      return n();
    };
  }

  static Function debugLog(Function check){
    return (tag,n){
      if(!check()) return null;
      return Funcs.debugOn(tag,n);
    };
  }

  static Function tagDeferable(Function check,[Function p,Function cs]){
    return (tag,m,[String f]){
      if(check()) return Funcs.tagPrint(tag,Funcs.identity,1,f,p,cs)(m);
      return m;
    };
  }

  static Function defferedDebugLog(Function check){
    return (tag,Function op,[num sx,String format,Function n,Function p]){
      p = Funcs.switchUnless(p,Funcs.identity);
      var initr = (message){
        return Funcs.tagPrint(tag,op,sx,format,n,Funcs.compose(p,(s){
          return s.replaceAll('{message}',message);
        }));
      };

      var fallback = Funcs.compose(Funcs.identity,op,sx);

      return ([String message]){
        if(!check()) return fallback;
        message = Funcs.switchUnless(message,"");
        initr = initr(message);
        return initr;
      };
    };
  }

  static dynamic tagLog(String t,dynamic n) => Funcs.debugOn(t,n);

  static Function tag(String t,[String fmt]){
    return Funcs.tagDefer(Funcs.identity,1,fmt)(t);
  }

  static Function tagDefer(dynamic n,[int m,String fmt]){
    return (String tag){
      return Funcs.tagPrint(tag,n,m,fmt);
    };
  }

  static Function debugOn(String tag,dynamic n){
    return Funcs.tagPrint(tag,Funcs.identity)(n);
  }

  static Function debugFor(String tag){
    return Funcs.dualPartial(Funcs.tagPrint)(tag);
  }

  static dynamic debug = Funcs.tagPrint('#debug',Funcs.identity);

  static dynamic tagPrint(String tag,Function n,[num sx,String format,Function nprinter,Function prettier]){
    format = Funcs.switchUnless(format,"{tag} -> {res}");
    prettier = Funcs.switchUnless(prettier,Funcs.identity);
    var fp = Funcs.switchUnless(nprinter,print);
    return Funcs.compose((n){
      fp(prettier(format).toString().replaceAll('{tag}',tag).replaceAll('{res}',n.toString()));
      return n;
    },n,sx);
  }

  static dynamic identity(n){
      return n;
  }

  static Function matchFunctionalCondition(dynamic n){
    if(n is List) return Funcs.matchListFunctionalCondition(n);
    if(n is Map) return Funcs.matchMapFunctionalCondition(n);
  }

  static Function matchListFunctionalCondition(List<Function> n){
    bool state;
    return (k){
      Enums.eachSync(n,(e,i,o,fn){ 
        state = e(k);
        if(state != false) return fn(null);
        fn(true);
      });
      return state;
    };
  }

  static Function matchMapFunctionalCondition(Map<String,Function> n){
    bool state;
    return (k){
      Enums.eachSyncMap(n,(e,i,o,fn){ 
        state = e(k);
        if(state != false) return fn(null);
        fn(true);
      });
      return state;
    };
  }

  static Function matchMapConditions([Map<String,Function> sets]){
    return (r){
      var future  = new Completer();
      Enums.eachSyncMap(sets,(e,i,o,fn){
        var state = e(r);
        if(!!state) return fn(false);
        future.completeError(new Exception("Function check at $i failed!"));
      },(o,err){
        future.complete(r);
      });
      
      return future.future;
    };
  }

  static Function matchAnyValue(List a,[bool matcher(m,n)]){
      matcher = Funcs.switchUnless(matcher,Valids.match);
      return (f,Function suc,[Function fail]){
      if(a.isEmpty) return;
      else{
        Enums.eachAsync(a,(e,i,o,fn){
          if(matcher(f,e)) return fn(e);
          return fn(null);
        },(_,err){
          if(Valids.exist(err)) return suc(f,err,a);
          return Valids.exist(fail) && fail(f,err,a);
        });
      };
     };
  }

  static Function matchAny(Function suc,Function fail,[Function match]){
    var ma = Funcs.matchAnyBy(suc,fail,match);
    return (a,val){
      return ma(a)(val);
    };
  }

  static Function matchAnyWith(List a,Function suc,Function fail,[Function match]){
    var ma = Funcs.matchAnyBy(suc,fail,match)(a);
    return (val){
      return ma(val);
    };
  }

  static Function matchAnyBy(Function suc,Function fail,[Function match]){
    return (a){
      var partial = Funcs.matchAnyValue(a,match);
      return (val){
        return partial(val,suc,fail);
      };
    };
  }

  static Function matchListConditions(List<Function> sets){
    return (r){
      var future  = new Completer();
      if(sets.isEmpty) future.completeError("List is empty!");
      else{
        Enums.eachSync(sets,(e,i,o,fn){
          var state = e(o);
          if(!!state) return fn(false);
          future.completeError(new Exception("Function check at index $i failed!"));
        },(o,err){
          future.complete(r);
        });
      }
      
      return future.future;
    };
  }
  
  static Function matchConditions(dynamic n){
    if( n is List) return Funcs.matchListConditions(n);
    return Funcs.matchMapConditions(n);
  }
  
  
  static Function createMessageMatcher(String name,String failmessage,dynamic n,[int i]){
    return Funcs.compose((bool m){ 
      if(!!m) return true;
      return {
        "name": name,
        "state": "Failed!",
        "message": failmessage
      };   
    },n,i);
  }
  
  //returns a future with a map of error messages if any
  static Function captureMapConditions([Map<String,Function> sets]){
    return (r){
      var errors = {}, future  = new Completer<Map>();
      Enums.eachSyncMap(sets,(e,i,o,fn){
        var state = e(r);
        if(state != true) errors[i] = state; 
      },(o,err){
        future.complete(errors);
      });
      return future.future;
    };
  }

  static Function captureListConditions([List<Function> sets]){
    return (r){
      var errors = [], future  = new Completer<List>();
      Enums.eachSync(sets,(e,i,o,fn){
        var state = e(o);
        if(state != true) errors.add(state);
      },(o,err){
        future.complete(errors);
      });
      return future.future;
    };
  }
  
  static Function captureConditions(dynamic n){
     if(n is List) return Funcs.captureListConditions(n);
     return Funcs.captureMapConditions(n);
  }
  
  //produces a function that accepts 1 mandatory and an (m-1) option parameters
  static Function base10Functionator(Function g,int m){
    if(m == 1) return (v){ return g(v); };
    if(m == 2) return (a,[b]){ return g(a,b); };
    if(m == 3) return (a,[b,c]){ return g(a,b,c); };
    if(m == 4) return (a,[b,c,d]){ return g(a,b,c,d); };
    if(m == 5) return (a,[b,c,d,e]){ return g(a,b,c,d,e); };
    if(m == 6) return (a,[b,c,d,e,f]){ return g(a,b,c,d,e,f); };
    if(m == 7) return (a,[b,c,d,e,f,h]){ return g(a,b,c,d,e,f,h); };
    if(m == 8) return (a,[b,c,d,e,f,h,i]){ return g(a,b,c,d,e,f,h,i); };
    if(m == 9) return (a,[b,c,d,e,f,h,i,j]){ return g(a,b,c,d,e,f,h,i,j); };
    if(m == 10) return (a,[b,c,d,e,f,h,i,j,k]){ return g(a,b,c,d,e,f,h,i,j,k); };
    return null;
  }
  
  static Function base10ListFunctionator(Function g,int m){
    if(m == 1) return (v){ return g([v]); };
    if(m == 2) return (a,[b]){ return g([a,b]); };
    if(m == 3) return (a,[b,c]){ return g([a,b,c]); };
    if(m == 4) return (a,[b,c,d]){ return g([a,b,c,d]); };
    if(m == 5) return (a,[b,c,d,e]){ return g([a,b,c,d,e]); };
    if(m == 6) return (a,[b,c,d,e,f]){ return g([a,b,c,d,e,f]); };
    if(m == 7) return (a,[b,c,d,e,f,h]){ return g([a,b,c,d,e,f,h]); };
    if(m == 8) return (a,[b,c,d,e,f,h,i]){ return g([a,b,c,d,e,f,h,i]); };
    if(m == 9) return (a,[b,c,d,e,f,h,i,j]){ return g([a,b,c,d,e,f,h,i,j]); };
    if(m == 10) return (a,[b,c,d,e,f,h,i,j,k]){ return g([a,b,c,d,e,f,h,i,j,k]); };
    return null;
  }
  
  static Function composeList(Function n,Function m,[int args]){
    args = (args == null ? 1 : args);
    return Funcs.composableList(n, m, args,(j,k){
      return (b){
        return j(k(b));
      };
    });
  }

  static Function compose(Function n,Function m,[int args]){
    args = (args == null ? 1 : args);
    
    if(args == 1) return (v){ return n(m(v)); };
    
    if(args == 2) return Funcs.composable(n, m, 2,(j,k){
      return (a,[b]){
        return j(k(a,b));
      };
    });
    
    if(args == 3) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c]){
        return j(k(a,b,c));
      };
    });
    
    if(args == 4) return Funcs.composable(n, m, 4,(j,k){
      return (a,[b,c,d]){
        return j(k(a,b,c,d));
      };
    });
    
    if(args == 5) return Funcs.composable(n, m, 5,(j,k){
      return (a,[b,c,d,e]){
        return j(k(a,b,c,d,e));
      };
    });
    
    if(args == 6) return Funcs.composable(n, m, 6,(j,k){
      return (a,[b,c,d,e,f]){
        return j(k(a,b,c,d,e,f));
      };
    });
    
    if(args == 7) return Funcs.composable(n, m, 6,(j,k){
      return (a,[b,c,d,e,f,h]){
        return j(k(a,b,c,d,e,f,h));
      };
    });
    
    if(args == 8) return Funcs.composable(n, m, 7,(j,k){
      return (a,[b,c,d,e,f,h,i]){
        return j(k(a,b,c,d,e,f,h,i));
      };
    });
    
    if(args == 9) return Funcs.composable(n, m, 8,(j,k){
      return (a,[b,c,d,e,f,h,i,j]){
        return j(k(a,b,c,d,e,f,h,i,j));
      };
    });
    
    if(args == 10) return Funcs.composable(n, m, 9,(j,k){
      return (a,[b,c,d,e,f,h,i,j,k]){
        return j(k(a,[b,c,d,e,f,h,i,j,k]));
      };
    });
            
  }
  
  static Function applyComposable(Function n,Function m){
    return (List ops,[Map named]){
      if(named != null) return n(Function.apply(m,ops,Hub.encryptNamedArguments(named)));
      return n(Function.apply(m,ops));
    };
  }

  static Function composableList(Function n,Function m,int i,Function reg){
   return Funcs.base10ListFunctionator(reg(n,m), i);
  }

  static Function composable(Function n,Function m,int i,Function reg){
   return Funcs.base10Functionator(reg(n,m), i);
  }


  static Function dualPartial(Function m){
      return (e){
        return (k){
          return m(e,k);
        };
      };
  }
  
  static Function dualCurry(Function m){
    return (k){
      return (e){
        return m(k,e);
      };
    };
  }

  static Function applyPartial(Function m,int size,[List a]){
    var list = Funcs.switchUnless(a,new List());
    return (e){
      list.add(e);
      if(list.length <= size) return Funcs.applyPartial(m,size - 1,list);
      return Function.apply(m,list);
    };
  }
  
  static Function applyCurry(Function m,int size,[List a]){
    var list = Funcs.switchUnless(a,new List());
    return (e){
      list.add(e);
      if(list.length <= size) return Funcs.applyCurry(m,size - 1,list);
      return Function.apply(m,list.reversed.toList());
    };
  }

  static List range(int n,[bool fill]){
    fill = Funcs.switchUnless(fill,false);
    var rg = [];
    Funcs.cycle(n,(t){
      rg.add(fill ? ((n-t)+1) : null);
    });
    return rg;
  }

  static List rangeFill(int n,[dynamic j]){
    var rg = [];
    Funcs.cycle(n,(t){
      rg.add( Valids.exist(j) ? j : null);
    });
    return rg;
  }

  static void cycle(int times,Function fn){
    if(times <= 0) return null;
    fn(times);
    return Funcs.cycle((times - 1), fn); 
  }
  
  static dynamic switchUnless(m,n){
    if(m == null) return n;
    return m;
  }

  static dynamic when(bool f,Function n,[Function m]){
    if(!!f) return n();
    return (m != null && m());
  }

  static dynamic then(Function m,Function n,[Function f,int s]){
    return Funcs.compose((state){
      if(Valids.isTrue(state)) return n(state);
      if(Valids.exist(f) && Valids.isFalse(state)) return f(state);
      return null; 
    },m,s);
  }  
  
  
  static Function effect(Function m,[int i]){
    return Funcs.compose((n){ return n;},m,i);
  }
  
  static Function alwaysEffect(Function m,[int i]){
    var core = Funcs.effect(m,i);
    return (n){
      return ([j]){
        return core(n);
      };
    };
  }

  static Function always(n){
    return (){
      return n;
    };
  }
  
  static Function applyUnless(Function m){
   return (g){
       return (m(g) || g);
   };
  }
  
  static Function defaultUnlessApply(Function m){
     return (d){
        return (g){
           return (m(g) || d);
        };
     };
  }

  static Function negate(Function m,[num sx]){
    return Funcs.compose((n){ return !n; },m,sx);
  }

  static dynamic dartApply(Function n,[List a,Map m]){
    a = Funcs.switchUnless(a,[]);
    m = Hub.encryptNamedArguments(Funcs.switchUnless(m,{}));
    return Function.apply(n,a,m);
  }
}
