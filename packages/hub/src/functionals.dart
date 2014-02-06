part of hub;

class Funcs{
    
  static Function matchMapConditions([Map<String,Function> sets]){
    return (r){
      var future  = new Completer();
      Enums.eachSyncMap(sets,(e,i,o,fn){
        var state = e(r);
        if(!!state) return fn(false);
        future.completeError(new Exception("Function check at $i failed!"));
      },(o){
        future.complete(r);
      });
      
      return future.future;
    };
  }

  static Function matchListConditions([List<Function> sets]){
    return (r){
      var future  = new Completer();
      Enums.eachSync(sets,(e,i,o,fn){
        var state = e(o);
        if(!!state) return fn(false);
        future.completeError(new Exception("Function check at index $i failed!"));
      },(o){
        future.complete(r);
      });
      
      return future.future;
    };
  }
  
  static Function createMessageMatcher(String name,String failmessage,bool n(i)){
    return (e){
      if(!!n(e)) return true;
      return {
        "name": name,
        "state": "Failed!",
        "message": failmessage
      };   
    };
  }
  
  //returns a future with a map 
  static Function captureMapConditions([Map<String,Function> sets]){
    return (r){
      var errors = {}, future  = new Completer<Map>();
      Enums.eachSyncMap(sets,(e,i,o,fn){
        var state = e(r);
        if(state != true) errors[i] = state; 
      },(o){
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
      },(o){
        future.complete(errors);
      });
      return future.future;
    };
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
    
    if(args == 4) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d]){
        return j(k(a,b,c,d));
      };
    });
    
    if(args == 5) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e]){
        return j(k(a,b,c,d,e));
      };
    });
    
    if(args == 6) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e,f]){
        return j(k(a,b,c,d,e,f));
      };
    });
    
    if(args == 7) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e,f,h]){
        return j(k(a,b,c,d,e,f,h));
      };
    });
    
    if(args == 8) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e,f,h,i]){
        return j(k(a,b,c,d,e,f,h,i));
      };
    });
    
    if(args == 9) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e,f,h,i,j]){
        return j(k(a,b,c,d,e,f,h,i,j));
      };
    });
    
    if(args == 10) return Funcs.composable(n, m, 3,(j,k){
      return (a,[b,c,d,e,f,h,i,j,k]){
        return j(k(a,[b,c,d,e,f,h,i,j,k]));
      };
    });
            
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

  static void cycle(int times,Function fn){
    fn(times);
    if(times > 0) return Funcs.cycle((times - 1), fn); 
    return null;
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
      if(Valids.exists(f) && Valids.isFalse(state)) return f(state);
      return null; 
    },m,s);
  }  
  
  
  static Function effect(Function m,[int i]){
    return Funcs.compose((n){ return n;},m,i);
  }
  
  static always(n){
    return (){
      return n;
    };
  }
  
}