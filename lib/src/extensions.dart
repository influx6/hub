part of hub;

Function _empty(t,s){}
var _smallA = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
var _bigA = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];


abstract class Comparable{
  bool compare(dynamic d);
}

class Transformable{
  Function _transformer;
  dynamic _bind;

  static create(Function n) => new Transformable(n);

  Transformable(Function n){
    this._transformer = n;
  }

  void changeFn(Function n){
    this._transformer = n;
  }

  void change(dynamic n){
    this._bind = n;
  }

  dynamic out(dynamic j){
    if(this._bind == null) return null;
    return this._transformer(this._bind,j);
  }
}


abstract class Injector<T>{
  final consumer = Hub.createDistributor('Injector');
  Function condition,modifier;
  dynamic target;
  
  Injector(this.target,this.condition,this.modifier);
  
  void on(Function n){ this.consumer.on(n); }
  
  void inject(){}
  
  void push(T n){}
}

class ListInjector<T> extends Injector<T>{
  
  static create(n,[k,m]) => new ListInjector(n,k,m);

  ListInjector(bool c(m,n),h,[n]): super(h,(target,controller){ 
    if(!!c(target,controller)) return controller.inject(); 
  },(n == null ? (i){ return i; } : n));
  
  void inject(){
    this.consumer.emit(this.modifier(this.target));
  }
  
  void push(T n){
    this.target.add(n);
    this.condition(this.target,this);
  }
}

class LengthInjector<T> extends ListInjector<T>{
    int length;
    
    static create(n,[fn,fns]) => new LengthInjector(n,fn,fns);

    LengthInjector(this.length,[fn,fns]): super((fn != null ? fn : (tg,ct){
       if(tg.length >= ct.length) return true;return false;
    }),[],( fns != null ? fns : (list){
      var clone = new List.from(list);
      list.clear();
      return clone;
    }));
    
}

class PositionInjector<T> extends  ListInjector<T>{
  int length;
    
    static create(n,[fn,fns]) => new PositionInjector(n,fn,fns);
    
    PositionInjector(this.length,[fn,fns]): super((fn != null ? fn : (tg,ct){
      if(tg.length >= ct.length) return true; return false;
    }),Hub.createSparceList(),(fns != null ? fns : (target){
        var list =  target.sorted();
        target.clear();
        return list;
    }));
    
    @override
    void push(int pos,T n){
      this.target.add(pos,n);
      this.condition(this.target,this);
    }
}

class SparceList{
  final sparce = new Map<int,dynamic>();
  num max;
  
  static create([n]) => new SparceList(n);
  
  SparceList([m]){
    this.max = m;
  }
  
  void get(int k){
    return this.sparce[k];
  }
  
  bool hasKey(int k){
    return this.sparce.containsKey(k);
  }
  
  bool hasValue(t){
    return this.sparce.containsValue(t);  
  }
  
  void add(int k,t){
    if(this.isFull) return;
    this.sparce[k] = t;  
  }
  
  void remove(int k){
    this.sparce.remove(k);  
  }
  
  void propagate(Function n(k,t)){
    this.sparce.forEach(n);
  }
  
  num get length => this.sparce.length;
  
  bool get isFull{
    if(this.max == null || this.max < this.length) return false;
    return true;
  }
  
  List toList(){
    var keys = this.sparce.keys.toList();
    return Enums.heapSort(keys,(n,m) => n < m);
  }
  
  List sorted(){
    var sorted = new List(), 
        sort = this.toList();
        

    sort.forEach((k){ 
      sorted.add(this.sparce[k]); 
    });
    return sorted;
  }
  
  List unsorted(){
    return this.sparce.values.toList();   
  }
  
  toString(){
    return this.sparce.toString();
  }
  
  void clear(){
    this.sparce.clear();
  }
}

class Switch{
  int _state = -1;
  final onOff = new List<Function>();
  final onOn = new List<Function>();


  static create() => new Switch();

  Switch();

  void switchOff(){
    this._state = 0;
    this.onOff.forEach((f){ f(); });
  }

  void switchOn(){
    this._state = 1;
    this.onOn.forEach((f){ f(); });
  }

  bool on(){
    return this._state == 1;
  }

  void close(){
    this.onOff.clear();
    this.onOn.clear();
    this._state = -1;
  }

}

class Distributor<T>{
  List<Function> listeners = new List<Function>();
  final done = new List<Function>();
  final once = new List<Function>();
  final _removal = new List<Function>();
  final Switch _switch = Switch.create();
  String id;
  bool _locked = false;
  
  static create(id) => new Distributor(id);

  Distributor(this.id);
  
  void onOnce(Function n){
    if(this.once.contains(n)) return;
    this.once.add(n);     
  }
  
  void on(Function n){
    if(this.listeners.contains(n)) return;
    this.listeners.add(n);
  }

  void whenDone(Function n){
    if(!this.done.contains(n)) this.done.add(n);
  }
  
  dynamic off(Function m){
    if(!!this._switch.on()){
      return this._removal.add((j){
        return this.listeners.remove(m);
      });
    }
    return this.listeners.remove(m);
  }

  dynamic offOnce(Function n){
    if(!!this._switch.on()){
      return this._removal.add((j){
        return this.once.remove(m);
      });
    }
    return this.once.remove(m);
  }
  
  void free(){
    this.freeListeners();
    this.done.clear();
    this.once.clear();
  }

  void freeListeners(){
    this.listeners.clear();
  }
  
  void emit(T n){
    if(this.locked) return;
    this.fireOncers(n);
    this.fireListeners(n);
  }
  
  void fireListeners(T n){
    if(this.listeners.length <= 0) return;
    
    this._switch.switchOn();
    Hub.eachAsync(this.listeners,(e,i,o,fn){
      e(n);
      fn(null);
    },(o,err){
      this.fireDone(n);
      this._switch.switchOff();
      this._fireRemoval(n);
    });   
  }
 
  void fireOncers(T n){
    if(this.once.length <= 0) return null;
    Hub.eachAsync(this.once,(e,i,o,fn){
      e(n);
      fn(null);
    },(o,err){
    });
    this.once.clear();
  }
  
  void fireDone(T n){
    if(this.done.length <= 0) return;
    Hub.eachAsync(this.done,(e,i,o,fn){
      e(n);
      fn(null);
    });
  }
  
  void _fireRemoval([T n]){
    if(this._removal.length <= 0 || this._switch.on()) return;
    Hub.eachAsync(this._removal,(e,i,o,fn){
      e(n);
      fn(null);
    });
  }

  bool get hasListeners{
    return (this.listeners.length > 0);
  }
  
  void lock(){
    this._locked = true;
  }
  
  void unlock(){
    this._locked = false;
  }
  
  List cloneListeners(){
    return new List<Function>.from(this.listeners);
  }

  void clearDone(){
    this.done.clear();
  }

  bool get locked => !!this._locked;

  int get listenersLength => this.listeners.length; 
  int get doneLength => this.done.length; 

}

class Mutator<T> extends Distributor<T>{
    final List history = new List();
    
    Mutator(String id): super(id);
    
    void replaceTransformersListWith(List<Function> a){
      this.listeners = a;
    }

    void updateTransformerListFrom(Mutator m){
      this.replaceTransformersListWith(m.cloneListeners());
    }

    void emit(T n){
      this.fireListeners(n);
    }
    
    void fireListeners(T n){
      var history = new List();
      history.add(n);
      
      var done = (k,e){
        this.fireDone(history.last);
        this.fireOncers(history.last);
        history.clear();
      };
      
      Hub.eachAsync(this.listeners,(e,i,o,fn){
          var cur = history.last;
          var ret = e(cur);
          if(ret == null){
            (history.isEmpty ? history.add(cur) : 
              (!history.isEmpty && history.last != cur ? history.add(cur) : null));
          }else history.add(ret);
          fn(null);
      },done);
        
      
    }
    
}

class Condition<T>{
    final List history = new List();
    final List conditions = new List();
    final List done = new List();
    final List once = new List();
    
    static create(n) => new Condition(n);

    Condition(String id);

    void on(bool n(dynamic l)){
      if(this.conditions.contains(n)) return null;
      this.conditions.add(n);
    }

    void off(Function n){
      if(!this.conditions.contains(n)) return null;
      this.conditions.remove(n);
    }
    
    void whenDone(Function n){
      this.done.add(n);
    }

    void onOnce(Function n){
      this.once.add(n);
    }

    void emit(T n){
     this.fireConditions(n);
    }

    void fireConditions(n){
      Enums.eachSync(this.conditions,(e,i,o,fn){
        if(!!e(n)) return fn(null);
        return fn(new Exception('failed'));
      },(g,err){
        if(err is Exception) return null;
        this.fireOnce(n);
        this.fireDone(n);
      });
    }

    void fireDone(n){
      Enums.eachSync(this.done,(e,i,o,fn){
        e(n);
        fn(null);
      });
    }

    void fireOnce(n){
      Enums.eachSync(this.once,(e,i,o,fn){
        e(n);
        fn(null);
      },(r,o){
          this.once.clear();
      });
    }

    void clearDone() => this.once.clear();
    void clearConditions() => this.conditions.clear();
    void clearOnce() => this.once.clear();
    
    void clear(){
        this.clearOnce();
        this.clearConditions();
        this.clearOnce();
    }

}

class SymbolCache{
  var _cache = {};
  
  SymbolCache();
    
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

    MapDecorator.use(Map a): storage = a;
      
    dynamic get(String key){
      if(this.has(key)) return this.storage[key];
    }
              
    void add(String key,dynamic val){
      if(this.has(key)) return null;
      this.storage[key] = val;
    }

    void update(String key,dynamic val){
      if(this.has(key)){ this.storage[key] = val; return null; }
      else this.add(key,val);
      return null;
    }

    void updateKey(String key,String newKey){
      if(!this.has(key)) return null;
      var val = this.get(key);
      this.destroy(key);
      this.add(newKey,val);
    }

    dynamic destroy(String key){
      if(!this.has(key)) return null; 
      return this.storage.remove(key);    
    }
      
    bool has(String key){
      if(!this.storage.containsKey(key)) return false;
      return true;
    }

    bool hasValue(String v){
      if(!this.storage.containsValue(v)) return false;
      return true;
    }

    void onAll(Function n) => this.storage.forEach(n);

    void flush(){
      this.storage.clear();
    }

    void clear() => this.flush();

    String toString(){
      return this.storage.toString();
    }

    int get keyLength => this.storage.keys.toList().length;
    int get valuesLength => this.storage.values.toList().length;
    int get length => this.storage.length;

}

class SingleLibraryManager{
  Symbol tag;
  final ms = currentMirrorSystem();
  LibraryMirror library;
  
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

class Counter{
  int _count = 0;
  dynamic handler;
  
  static create(n) => new Counter(n);

  Counter(this.handler);
  
  int get counter => _count;
  
  void tick(){
    _count += 1;
  }
  
  void untick(){
    if(_count == 0) return null;
    _count -= 1;
  }
  
  void detonate(){
    _count = 0;
  }
  
  String toString(){
    return "Counter: "+this.counter.toString();
  }
}

class MassTree extends MapDecorator{
  final canDestroy = Switch.create();

  static create() => new MassTree();

  MassTree();

  dynamic destroy(String key){
    if(!this.canDestroy.on()) return null;
    return super.destroy(key);
  }

  void addAll(Map n){
    n.forEach((n,k){
      this.add(n,k);
    });
  }
}

//StateObject with map get and setters
class State{
  final MapDecorator states = new MapDecorator();
  dynamic target;
  String name;
  bool _active = false;
 
  static create(t,s,[n]) => new State(t,s,n);
  
  State(this.target,Map sets,[String name]){
    this.name = Hub.switchUnless(name, 'StateObject');
    //if init and dinit do not exist,provide empty shell,just in case we wish to do some work
    if(this.states.get('init') == null) this.states.add('init', _empty);
    if(this.states.get('dinit') == null) this.states.add('dinit',_empty);
    
    sets.forEach((n,k){
      this.add(n,(){
        if(this.deactivated) return null;
        var m = k(this.target,this);
        return m;
      }); 
    });
  }
  
  void add(String key,Function n){
    this.states.add(key,n);
  }

  void activate(){
    this.states.get('init')(this.target,this);
    this._active = true;
  }
  
  void deactivate(){
    this.states.get('dinit')(this.target,this);
    this._active = false;
  }
  
  Function get(String n){
    return this.states.get(n);
  }
  
  dynamic run(String n){
    if(!this.states.has(n)) return null;
    return this.get(n)();
  }
  
  Function destroy(String n){
    return this.states.destroy(n);
  }

  vid close(){
     this.states.flush();
  }
  
  bool get activated => !!this._active;
  bool get deactivated => !this._active;
  
}

//using function calls and not dynamic invocation
class StateManager{
    Object target;
    dynamic store,current;
    
    static create(t) => new StateManager(t);
    
    StateManager(this.target){
      this.store = Hub.createMapDecorator();
    }
    
    void close(){
     this.store.onAll((e,k){ k.close(); });
     this.store.flush();
    }
    
    void add(String name,dynamic m){
      if(m is State) return this._addState(name, m);
      return this._createState(name, m);
    }
    
    void _createState(String name,Map<String,Function> states){
      this.store.add(name,new State(this.target,states,name));
    }
    
    void _addState(String name,State state){
      this.store.add(name,state);  
    }
    
    void removeState(String name){
      this.store.destroy(name);
    }

    dynamic run(String name){
      if(!this.isReady) return null;
      return this.current.run(name);
    }
    
    void switchState(String name){
      if(!this.store.has(name)) return;
      if(this.current != null) this.current.deactivate();
      this.current = this.store.get(name);
      this.current.activate();
      return;
    }
    
    bool get isReady => this.current != null;
    
}
