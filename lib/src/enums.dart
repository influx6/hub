part of hubutils;

class Enums{

  static dynamic flatten(dynamic n,[dynamic m]){
    if(n is List) return Enums.flattenList(n,m);
    if(n is Map) return Enums.flattenMap(n,m);
  }
  
  static dynamic flattenMap(Map m,[Map ms]){
    ms = Funcs.switchUnless(ms,{});
    Enums.eachAsync(m,(e,i,o,fn){
      if(e is Map){
        Enums.flatten(e,ms);
        return fn(null);
      }
      ms[i] = e;
      return fn(null);
    });
    return ms;
  }
  
  static dynamic flattenList(List m,[List ns]){
     ns = Funcs.switchUnless(ns,[]);
    Enums.eachAsync(m,(e,i,o,fn){
      if(e is List){
        Enums.flatten(e,ns);
        return fn(null);
      }
      ms.add(e);
      return fn(null);
    });

     return ns;
  }
  
  static dynamic locateWith(MapDecorator m,String s,[Function g]){
    return Enums.locate(m.core,s,g);
  }

  static dynamic locate(Map m,String s,[Function g]){
    return Enums.locateKey(m,s.split(_space),g);
  }

  static dynamic locateKey(Map m,List a,[Function r]){
    var local, cur,clone = new List.from(a), first = Enums.yankFirst(clone);
    if(!m.containsKey(first)) return local;
    local = m[first];
    while(!clone.isEmpty){
      cur = Enums.yankFirst(clone);
      if(!local.containsKey(cur)) break;
      local = local[cur];
    };
    return local;
  }

  static Map list2Map(List m,[Function n,RegExp sep]){
      sep = Funcs.switchUnless(sep,new RegExp(r'\s'));
      var tree = {}; 
      Enums.eachAsync(m,(e,i,o,fn){
          var keys = e.split(sep), cur,root = Enums.yankFirst(keys), local;
          if(!tree.containsKey(root)) tree[root] = {};
          while(!keys.isEmpty){
            cur = Enums.yankFirst(keys);
            if(Valids.notExist(local)) local = tree[root];
              if(local.containsKey(cur)) local = local[cur];
              else{
                local[cur] = {};
                local = local[cur];
              }
          }
          local = null;
          return fn(null);
      },(_,err){
          return Valids.exist(n) && n(tree);
      });

    return tree;
  }

  static dynamic deepClone(dynamic m){
    if(Valids.isList(m)) return Enums.listDeepClone(m);
    if(Valids.isMap(m)) return Enums.mapDeepClone(m);
    return m;
  }

  static List listDeepClone(List a){
    var clone  = [];
    a.forEach((f){
      if(f is List) return clone.add(Enums.listDeepClone(f));
      if(f is Map) return clone.add(Enums.mapDeepClone(f));
      clone.add(f);
    });
    return clone;
  }

  static List mapDeepClone(Map a){
    var clone = {};
    a.forEach((k,f){
      if(f is List) return clone[k] = (Enums.listDeepClone(f));
      if(f is Map) return clone[k] = (Enums.mapDeepClone(f));
      clone[k] = f;
    });
    return clone;
  }

  static max(a,b) => Enums.comparator(a,b,(a,b) => a > b);
  static min(a,b) => Enums.comparator(a,b,(a,b) => a < b);
  static dynamic maxFor(List a,[num s,num e]) => Enums.compareBy(a,(c,a) => c > a,s,e);
  static dynamic minFor(List a,[num s,num e]) => Enums.compareBy(a,(c,a) => c < a,s,e);

  static dynamic compareEngineProcessor(List a,bool compare(g,b),[num start,num end,dynamic c,bool started]){
    start = Funcs.switchUnless(start,0);
    end = Funcs.switchUnless(end,a.length - 1);
    started = Funcs.switchUnless(started,false);
    
    var cur = Funcs.switchUnless(c,a[start]);

    if(!started && end <= start) end = start + end;
    if(end >= a.length) end = a.length - 1;
    if(start <= -1) start = (start + a.length);

    if(start > end) return cur;

    var sd = a[start], ed = a[end];

    //if(!compare(cur,a[start])) cur = a[start];
    if(compare(sd,ed)){
      if(compare(sd,cur)) cur = sd;
    }else{
      if(compare(ed,cur)) cur = ed;
    }

    return Enums.compareEngineProcessor(a,compare,start += 1,end -= 1,cur,true);
  }

  static dynamic compareEngine(List a,bool c(g,b),[num s,num e]){
    return Enums.compareEngineProcessor(a,c,s,e);
  }

  static dynamic comparator(a,b,Function comparator){
    return (comparator(a,b) ? a : b);
  }

  static dynamic compareBy(a, bool m(a,b),[num start,num end]){
    return Enums.compareEngine(a,m,start,end);
  }

  static List heapEngine(List a,num start,num length,Function maxCompare,Function minCompare,[List sorted,num lt,num st,bool isUp]){
    
    sorted = Funcs.switchUnless(sorted,Funcs.range(a.length));
    lt = Funcs.switchUnless(lt,0);
    st = Funcs.switchUnless(st,a.length - 1);
    isUp = Funcs.switchUnless(isUp,false);

    if(a.isEmpty) return sorted;

    var q = isUp ? a : new List.from(a),max,min;

    if(q.length == 1){
      sorted[st] = q.removeAt(0);
      return sorted;
    }else{

      min = sorted[st] = Enums.compareBy(q,minCompare,start,length);
      max = sorted[lt] = Enums.compareBy(q,maxCompare,start,length);

      q.remove(max);
      q.remove(min);

    }

    lt += 1;
    st -= 1;

    return Enums.heapEngine(q,start,length,maxCompare,minCompare,sorted,lt,st,true);
  }

  static List heapSort(List a,Function compare,[num start,num end]){
    return Enums.heapEngine(a,start,end,compare,Funcs.negate(compare,2));
  }

  static dynamic nth(List a,int ind){
    if(ind >= a.length) return null;
    return a[ind];  
  }
  
  static dynamic first(List a){
    return Enums.nth(a,0);  
  }
  
  static dynamic second(List a){
    return Enums.nth(a,1);  
  }
  
  static dynamic third(List a){
    return Enums.nth(a,2);
  }

  static dynamic last(List a){
    return Enums.nth(a,a.length - 1);
  }
  
  static dynamic valueDiff(dynamic m,dynamic v){
    if(Valids.isString(m) && Valids.isString(v)) return Enums.valueDiff(m.split(''),v.split(''));
    if(Valids.isMap(m) && Valids.isMap(v)) return Enums.valueMapDiff(m,v);
    if(Valids.isList(m) && Valids.isList(v)) return Enums.valueListDiff(m,v);
    return null;
  }

  static dynamic keyDiff(m,v){
    if(Valids.isString(m) && Valids.isString(v)) return Enums.keyDiff(m.split(''),v.split(''));
    if(Valids.isMap(m) && Valids.isMap(v)) return Enums.keyMapDiff(m,v);
    if(Valids.isList(m) && Valids.isList(v)) return Enums.keyListDiff(m,v);
  }

  static Map keyMapDiff(Map m,Map n){
    var diff = {};
    n.forEach((k,v){
      if(m.containsKey(k)){
         if(m[k] == v) return null;
         return diff[k] = v;
      }
      // return diff[k] = v;
    });
    return diff;
  }

  static List keyListDiff(List m,List n){
    var diff = [],count = 0;
    n.forEach((f){
      ((f == m[count]) ? null : diff.add(count));
      count += 1;
    });
    return diff;
  }

  static Map valueMapDiff(Map m,Map n){
    var diff = {};

    m.forEach((k,v){
      if(n.containsKey(k) && n[k] == v) return null;
      diff[k] = v;
    });
    n.forEach((k,v){
      if(m.containsKey(k) && m[k] == v) return null;
      diff[k] = v;
    });
    return diff;
  }

  static List valueListDiff(List a,List m){
    var diff = [];
    a.forEach((f){
      if(m.contains(f)) return null;
      diff.add(f);
    });

    m.forEach((f){
      if(a.contains(f)) return null;
      diff.add(f);
    });
    return diff;
  }

  static dynamic uniqueDiff(m,v){
    if(Valids.isString(m) && Valids.isString(v)) return Enums.uniqueDiff(m.split(''),v.split(''));
    if(Valids.isMap(m) && Valids.isMap(v)) return Enums.uniqueMapDiff(m,v);
    if(Valids.isList(m) && Valids.isList(v)) return Enums.uniqueListDiff(m,v);
    return null;
  }

  static Map uniqueMapDiff(Map m,Map n){
    var diff = {};
    n.forEach((k,v){
      if(m.containsKey(k)){
         if(v is Map || v is List){
            if(Enums.uniqueDiff(m[k],v).length > 0) diff[k] = v;
            return null;
         }
         if(m[k] == v) return null;
         return diff[k] = v;
      }
      return diff[k] = v;
    });
    return diff;
  }

  static List uniqueListDiff(List m,List n){
    var diff = [],count = 0;
    n.forEach((f){
      if(count >= m.length) return diff.add(count);
      if(Valids.isMap(f) || Valids.isList(f)){
        if(Enums.uniqueDiff(n[count],f).length > 0) diff.add(count);
      }else if(f != m[count]) diff.add(count);
      count += 1;
    });
    return diff;
  }

  static Function nthFor(dynamic a){
    if(a is List) return (int ind){
      if(ind >= a.length) return null;
      return a[ind];
    };
    
    if(a is Map) return (dynamic m){
      if(!a.containsKey(m)) return null;
      return a[m];
    };
    
    return null;
  }
  
  static Function indexFor(dynamic a){
    if(a is List) return (dynamic v,[int s]){
      return a.indexOf(v,s);
    };
    
    if(a is Map) return (dynamic v){
      if(!a.containsValue(v)) return null;
      var set = [];
      a.forEach((k,c){
         if(c == v) set.add(k);
      });
      
      return set;
    };
    
    return null;       
  }

  static void eachSync(dynamic n,Function it,[Function c]){
    if(n is Map) return Enums.eachSyncMap(n,it,c);
    if(n is List) return Enums.eachSyncList(n,it,c);
  }

  static void eachAsync(dynamic n,Function it,[Function c]){
    if(n is Map) return Enums.eachAsyncMap(n,it,c);
    if(n is List) return Enums.eachAsyncList(n,it,c);
  }

  static void eachAsyncList(List a,Function iterator,[Function complete]){
    if(a.length <= 0){
      if(complete != null) complete(a,null);
      return null;    
    }
    
    var kill = false,total = a.length,i = 0;
    
    for(i = 0; i < total; i++){
        if(kill) break;
        iterator(a[i],i,a,(err){
            if(err != null){
              if(complete != null) complete(a,err);
              kill = true;
              return null;
            }
            if(i >= total - 1){
              if(complete != null) complete(a,null);
              return null;
            }
        }); 
    }
    
  }

   static void eachAsyncMap(Map a,Function iterator,[Function complete]){
      if(a.length <= 0){
        if(complete != null) complete(a,null);
        return null;    
      }
      
      var kill = false,total = a.length,
          keys = a.keys.toList();
      
      for(var f in keys){
        if(kill) break;
        iterator(a[f],f,a,(err){
          if(err != null){
            if(complete != null) complete(a,err);
            kill = true;
            return null;
          }
          total -= 1;
          if(total <= 0){
            if(complete != null) complete(a,null);
            return null;
          }
      });  

      };
    
  }
   
  static void eachSyncMap(Map a,Function iterator, [Function complete]){
    if(a.length <= 0){
      if(complete != null) complete(a,null);
      return null;    
    }
    
    var keys = a.keys.toList();
    var total = a.length,step = 0,tapper;
        
    var fuse = (){
      var key = keys[step];
      iterator(a[key],key,a,(err){
        if(err != null){
          if(complete != null) complete(a,err);
          return null;
        }
        step += 1;
        if(step == total){
          if(complete != null) complete(a,null);
           return null;
        }else return tapper();
      });
    };
     
    tapper = (){ return fuse(); };

    return fuse();
  }
  
  static void eachSyncList(List a,Function iterator, [Function complete]){
    if(a.length <= 0){
      if(complete != null) complete(a,null);
      return null;    
    }
    
    var total = a.length,step = 0,tapper;
        
    var fuse = (){
      iterator(a[step],step,a,(err){
        if(err != null){
          if(complete != null) complete(a,err);
          return null;
        }
        step += 1;
        if(step == total){
          if(complete != null) complete(a,null);
           return null;
        }else return tapper();
      });
    };
     
    tapper = (){ return fuse(); };

    return fuse();
  }
  
  static Future captureEachFuture(dynamic a,Function validator){
    var res = [];
    
    if(a.isEmpty) return new Future.value(true);
    
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
  
  static Map merge(Map a,Map b,{bool override: true}){
    var merged = new Map.from(a);
    b.forEach((n,k){
      if(!override && !!merged.containsKey(n)) return;
      merged[n] = k;
    });

    return merged;
  }
  
  static List map(dynamic m,dynamic mod(i,j,k),[Function complete]){
    var mapped = [];
    if(m is List){
      Enums.eachAsync(m,(e,i,o,fn){
         mapped.add(mod(e,i,o));
         return fn(null);
      },complete);
    }

    if(m is Map){
      Enums.eachAsyncMap(m,(e,i,o,fn){
         mapped.add(mod(e,i,o));
         return fn(null);
      },complete);
    }
    return mapped;
  }
  
  static dynamic reduce(List m,dynamic mod(m,i,j,k),[dynamic memo,Function complete,bool right]){
    var set = Valids.isTrue(right) ? m.reversed.toList() : m;
    Enums.eachAsync(set,(e,i,o,fn){
      if(memo == null) memo = e;
      else memo = mod(memo,e,i,o);
      fn(null);
    },(o,err){
      if(complete != null) complete(memo);
    });
    
    return memo;
  }
  
  static dynamic reduceRight(List m,dynamic mod(m,i,j,k),[dynamic memo,Function complete]){
    return Enums.reduce(m,mod,memo,complete,true);
  }
  
  static dynamic indexesOf(List a,Function fn){
    return Enums.filterKeys(a,(e,i,o){ if(fn(e)) return true; return false; });
  }

  static dynamic yankValues(List a,dynamic m){
    return Enums.yankValuesOn(a,(r) => Valids.match(r,m));
  }

  static dynamic yankNth(List a,int i){
    if(a.length - 1 < i) return null;
    var tmp = a[i];
    a.removeAt(i);
    return tmp;
  }
  
  static dynamic yankFirst(List a) => Enums.yankNth(a,0);
  static dynamic yankSecond(List a) => Enums.yankNth(a,1);
  static dynamic yankThird(List a) => Enums.yankNth(a,2);
  static dynamic yankForth(List a) => Enums.yankNth(a,3);
  static dynamic yankFive(List a) => Enums.yankNth(a,4);
  static dynamic yankLast(List a) => Enums.yankNth(a,a.length - 1);

  static dynamic yankValuesOn(List a,Function m){
    var yanked = [], index = Enums.indexesOf(a,m);
    index.forEach((f){ yanked.add(a[f]); a.removeAt(f); });
    return yanked;
  }

  static dynamic yankOn(List a,Function m){
    Enums.indexesOf(a,m).forEach((f){ a.removeAt(f); });
    return a;
  }

  static dynamic yankBy(List a,dynamic n){
    return Enums.yankOn(a,(e) => Valids.match(e,n));
  }

  static dynamic yank(List a,dynamic m){
    return Enums.yankOn(new List.from(a),(e) => Valids.match(e,m));
  }

  static List filterItem(dynamic m,dynamic item){
    return Enums.filterValues(m,(e,i,k){
      return e == item;
    });
  }

  static List filterValues(dynamic m,bool mod(i,j,k),[Function complete]){
    var mapped = [];

    if(m is List){
      Enums.eachAsync(m,(e,i,o,fn){
         if(!!mod(e,i,o)) mapped.add(e);
         return fn(null);
      },complete);
    }

    if(m is Map){
      Enums.eachAsyncMap(m,(e,i,o,fn){
         if(!!mod(e,i,o)) mapped.add(e);
         return fn(null);
      },complete);
    }

    return mapped;
  }

  static List filterKeys(dynamic m,bool mod(i,j,k),[Function complete]){
    var mapped = [];

    if(m is List){
      Enums.eachAsync(m,(e,i,o,fn){
         if(!!mod(e,i,o)) mapped.add(i);
         return fn(null);
      },complete);
    }

    if(m is Map){
      Enums.eachAsyncMap(m,(e,i,o,fn){
         if(!!mod(e,i,o)) mapped.add(i);
         return fn(null);
      },complete);
    }

    return mapped;
  }  

  static List concat(List a,[dynamic m]){
    var sets = new List.from(a);
    if(m != null) 
      Valids.isList(m) ? sets.addAll(m) : sets.add(m);
    return sets;
  }
  
  static List mapcat(fn,List a,[Function complete]){
    return Enums.concat(Enums.map(a, fn,complete));
  }

}
