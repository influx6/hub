part of hub;

Function _empty(t,s){}
var _smallA = ["a", "b", "c", "d", "e", "f", "g", "h", "i", "j", "k", "l", "m", "n", "o", "p", "q", "r", "s", "t", "u", "v", "w", "x", "y", "z"];
var _bigA = ["A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z"];

class Log{
  Function _flip,factori;
  String format;

  static create([n,p,f]) => new Log(n,p,f);

  Log([Function p,Function cs,String format]){
    this.format = format;
    this._flip = Funcs.futureBind();
    this.factori = Funcs.tagDeferable(this._flip,p,cs);
  }

  Function log(String t,dynamic v,[String f]){
    f = Funcs.switchUnless(f,this.format);
    return this.factori(t,v,f);
  }

  Function get flip => this._flip;

  void get enable => this._flip(true);
  void get disable => this._flip(false);
  bool get state => this._flip();

}

class WrapperLog{
  Function _flip,_factori;

  static create() => new WrapperLog();

  WrapperLog(){
    this._flip = Funcs.futureBind();
    this._factori = Funcs.defferedDebugLog(this._flip);
  }

  Function get make => this._factori;
  Function get flip => this._flip;

  void get enable => this._flip(true);
  void get disable => this._flip(false);
  bool get state => this._flip();

}

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
  final oncer = new List<Function>();
  final Switch _switch = Switch.create();
  String id;
  bool _locked = false;
  
  static create(id) => new Distributor(id);

  Distributor(this.id);
  
  void onOnce(Funcion n){
    if(this.oncer.contains(n)) return;
    this.oncer.add(n);     
  }
  
  void once(n) => this.onOnce(n);

  void on(Function n){
    if(this.listeners.contains(n)) return;
    this.listeners.add(n);
  }

  void whenDone(Function n){
    if(!this.done.contains(n)) this.done.add(n);
  }

  dynamic offWhenDone(Function n){
    return this.done.remove(n);
  }
  
  dynamic off(Function m){
    return this.listeners.remove(m);
  }

  dynamic offOnce(Function n){
    return this.oncer.remove(m);
  }
  
  void free(){
    this.freeListeners();
    this.done.clear();
    this.oncer.clear();
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
    
    Hub.eachAsync(this.listeners,(e,i,o,fn){
      e(n);
      return fn(null);
    },(o,err){
      this.fireDone(n);
    });   
  }
 
  void fireOncers(T n){
    if(this.oncer.length <= 0) return null;
    Hub.eachAsync(this.oncer,(e,i,o,fn){
      e(n);
      return fn(null);
    });
    this.oncer.clear();
  }
  
  void fireDone(T n){
    if(this.done.length <= 0) return;
    Hub.eachAsync(this.done,(e,i,o,fn){
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

class MapDecorator<T,K>{
    Map<T,K> storage;

    static MapDecorator create() => new MapDecorator();

    static MapDecorator useMap(Map<T,K> m) => new MapDecorator.use(m);

    static MapDecorator fromMap(Map<T,K> m) => new MapDecorator.from(m);
      
    MapDecorator(): storage = new Map<T,K>();

    MapDecorator.from(Map<T,K> a): storage = new Map<T,K>.from(a);

    MapDecorator.use(Map<T,K> a): storage = a;

    MapDecorator.unique(Map<T,K> a): storage = Enums.deepClone(a);
      
    dynamic get(String key){
      if(this.has(key)) return this.storage[key];
    }
    
    void addAll(MapDecorator m){
      m.onAll((n,k){
        this.add(n,k);
      });
    }

    void updateAllFrom(Map m){
      m.forEach((n,k){
        this.update(n,k);
      });
    }

    void updateAll(MapDecorator m){
      m.onAll((n,k){
        this.update(n,k);
      });
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

    bool get isEmpty => this.storage.isEmpty;

    Map get core => this.storage;

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

class DurationMixin {
  dynamic incMillisFn(Duration n,int m) => new Duration(milliseconds: n.inMilliseconds + m);
  dynamic incMacrosFn(Duration n,int m) => new Duration(microseconds: n.inMicroseconds + m);
  dynamic decMillisFn(Duration n,int m) => new Duration(milliseconds: n.inMilliseconds - m);
  dynamic decMacrosFn(Duration n,int m) => new Duration(microseconds: n.inMicroseconds - m);
}

abstract class Queueable<T>{
  void queue(T n);
  void dequeueAt(int i);
  void dequeueFirst();
  void dequeueLast();
  void exec();
  void halt();
  void immediate();
}

class TaskQueue extends Queueable with DurationMixin{
  bool _auto,_halt = false,_lock = false,_forceSingleRun = false;
  Timer _timer;
  List tasks;
  List microtasks;
  Duration _queueDelay;

  static create([n]) => new TaskQueue(n);

  TaskQueue([auto]){
    this._auto = Funcs.switchUnless(auto,true);
    this.tasks = new List<Function>();
    this.microtasks = new List<Function>();
    this._queueDelay = Duration.ZERO;
  }

  void queue(Function n(m)){
    if(this.locked) return null;
    this.tasks.add(n);
    return ((!this.singleRun && this.waiting && this.auto) ? this.exec() : null);
  }
  void queueAfter(int ms,Function n(m)){
    new Timer(new Duration(milliseconds:ms),(){ this.queue(n); });
  }
  
  Timer queueEvery(int ms,Function n(m)){
    return new Timer.periodic(new Duration(milliseconds:ms),(t){ this.queue(n); });
  }

  dynamic dequeueAt(int i) => !this.locked && this.tasks.removeAt(i);
  dynamic dequeueFirst() => this.dequeueAt(0);
  dynamic dequeueLast() => this.dequeueAt(this.tasks.length - 1);

  void delay(int ms) => this._queueDelay = new Duration(milliseconds: ms);
  void incDelay(int ms) => this.incMillisFn(this._queueDelay,ms);
  void decDelay(int ms) => this.decMillisFn(this._queueDelay,ms);
  void forceSingleRun() => this._forceSingleRun = true;
  void disableSingleRun() => this._forceSingleRun = false;

  bool get locked => !!this._lock;
  bool get empty => this.tasks.isEmpty && this.microtasks.isEmpty;
  bool get waiting => !this.empty;
  bool get auto => !!this._auto;
  bool get halted => !!this._halt;
  bool get singleRun => !!this._forceSingleRun;

  int get totalJobs => this.tasks.length + this.microtasks.length;
  int get totalTasks => this.tasks.length;
  int get totalMicrotasks => this.microtasks.length;

  void _handleTasks(List cur,int n,[dynamic val]){
    if(cur.length <= n) return null;
    return cur.removeAt(n)(val);
  }

  void immediate(Function n(m)){
    if(this.locked) return null;
    this.microtasks.add(n);
  }

  void immediateFor(int i){
    if(this.locked) return null;
    if(this.tasks.isEmpty || this.tasks.length <= i) return null;
    var cur = this.tasks.removeAt(i);
    this.microtasks.add(cur);
  }

  void downgrade(int n){
    if(this.locked) return null;
    if(this.microtasks.isEmpty || this.microtasks.length <= n) return null;
    this.tasks.add(this.microtasks.removeAt(n));
  }

  void repeat(int n){
    if(this.locked) return null;
    if(this.tasks.isEmpty || this.tasks.length <= n) return null;
    this.tasks.add(this.tasks.elementAt(n));
  }

  void repeatImmediate(int n){
    if(this.locked) return null;
    if(this.microtasks.isEmpty || this.microtasks.length <= n) return null;
    this.microtasks.add(this.microtasks.elementAt(n));
  }

  int taskIndex(Function n) => this.tasks.indexOf(n);
  int microtaskIndex(Function n) => this.microtasks.indexOf(n);

  void exec([dynamic v]){
    if(this.empty || this.locked || this.halted) return null;
    this._timer = new Timer(this._queueDelay,(){
      this._handler(v);
      if(!this.singleRun) this.exec(v);
    });
  }

  void _handler([v]){
      if((this.tasks.length <= 0 && this.microtasks.length <= 0)) return null;
      if(this.microtasks.length > 0) this._handleTasks(this.microtasks,0,v);
      else this._handleTasks(this.tasks,0,v);
      this.end();
  }

  void halt(){
    this._halt = true;
  }

  void unhalt(){
    this._halt = false;
  }

  void end(){
    this._timer.cancel();
    this._timer = null;
  }

  void clearMicrotasks(){
    this.halt();
    this.microtasks.clear();
    this.unhalt();
  }

  void clearTasks(){
    this.halt();
    this.tasks.clear();
    this.unhalt();
  }

  void clearJobs(){
    this.clearMicrotasks();
    this.clearTasks();
  }

  void destroy(){
    this.end();
    this._queueDelay = null;
  }

  void forceUnlock(){
    this._lock = false;
  }

  void reset(){
    this._halt = false;
    this.disableSingleRun();
    this.forceUnlock();
  }
}


class Pipe{
  String id;
  dynamic pin,pout;
  dynamic out = Hub.createDistributor('pipe-out');

  static create(String id) => new Pipe(id);

  Pipe(this.id){
    this.pout = Hub.createDistributor('pipe-out');
    this.pin = Hub.createDistributor('pipe-in');
  }

  bool get active => Valids.exist(this.pout) && Valids.exist(this.pin);

  void sendOut(dynamic n){
    if(!this.active) return null;
    this.pout.emit(n);
  }

  void sendIn(dynamic n){
    if(!this.active) return null;
    this.pin.emit(n);
  }

  void recieve(Function m){
    if(!this.active) return null;
    this.pin.on(m);
  }

  void recieveOnce(Function m){
    if(!this.active) return null;
    this.pin.once(m);
  }

  void unrecieve(Function m){
    if(!this.active) return null;
    this.pin.off(m);
  }

  void unrecieveOnce(Function m){
    if(!this.active) return null;
    this.pin.offOnce(m);
  }

  void destroy(){
    if(!this.active) return null;
    this.pin.free();
    this.pout.free();
    this.pin = this.pout = null;
  }
}


class FunctionFactory{
	MapDecorator _hidden,factories;

	static create() => new FunctionFactory();

	FunctionFactory(){
		this._hidden = MapDecorator.create();
		this.factories = MapDecorator.create();
	}

	void addFactory(String name,Function n(e)){
		this._hidden.add(name,n);
		this.factories.add(name,(n){
			return this._hidden.get(name)(n);
		});
	}

	Function updateFactory(String name,Function n(e)){
		this._hidden.update(name,n);
	}

	void removeFactory(String name){
		this._hidden.destroy(name);
		this.factories.destroy(name);
	}

	Function getFactory(String name) => this.factories.get(name);

	bool hasFactory(String name) => this.factories.has(name);

	void fireFactory(String name,[dynamic n]) => this.hasFactory(name) && this.getFactory(name)(n);
        
	void destroy(){
		this._hidden.clear();
		this.factories.clear();
		this._hidden = this.factories = null;
	}
}

class FunctionalAtomic{
    dynamic _handler;
    FunctionFactory atomics;
    MapDecorator atomicdist;
    MapDecorator _values;
    List _changed;
    
    static create(n) => new FunctionalAtomic(n);

    FunctionalAtomic(this._handler){
      this.atomics = FunctionFactory.create();
      this._values = MapDecorator.create();
      this.atomicdist = MapDecorator.create();
      this._changed = new List();
      this.checkAtomics();
    }

    void addAtomic(String id,Function n(e)){
      this.atomics.addFactory(id,n);
      this.atomicdist.add(id,Distributor.create(id));
      this.checkAtomics();
    }

    void removeAtomic(String id){
      this.atomics.removeFactory(id);
      this.atomicdist.destroy(id);
    }

    void updateAtomic(String id,Function n){
      this.atomics.updateFactory(id,n);
      this.checkAtomics();
    }
    
    void destroy(){
      this.atomics.destroy();
      this._values.clear();
      this.atomicdist.clear();
      this._changed.clear();
    }
  
    void changeHandler(handle){
      this._handler = handle;
    }

    void checkAtomics(){
      if(Valids.notExist(this._handler)) return null;
      Enums.eachAsync(this.atomics.factories.core,(e,i,o,fn){
        var val = e(this._handler);
        var old = this._values.get(i);
        
        if(Valids.notExist(old)){
            this._values.add(i,val);
            return fn(null);
        }
        
        if(Valids.match(val,old)) return fn(null);

        this._values.update(i,val);
        this._changed.add({'id':i,'new':val,'old':old});
        fn(null);
      },(_,i){
         this._changed.forEach((i){
            this.fireAtomic(i['id'],i);
         });
        this._changed.clear();
      });
    }

    void bind(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).on(n);
    }

    void bindWhenDone(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).whenDone(n);
    }

    void unbindWhenDone(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).offWhenDone(n);
    }

    void bindOnce(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).once(n);
    }

    void unbind(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).off(n);
    }

    void unbindOnce(String name,Function n){
            if(!this.atomicdist.has(name)) return null;
            return this.atomicdist.get(name).offOnce(n);
    }

    void fireAtomic(String n,Map m){
        if(!this.atomicdist.has(n)) return null;
        return this.atomicdist.get(n).emit(m);
    }
}

