part of hubutils;

class BasicException extends Exception{
  static create(m) => new BasicException(m);
  BasicException(String message): super(message);
}

class ConnectionException extends Exception{
  static create(m) => new ConnectionException(m);
  ConnectionException(String message): super(messages);
}

class ConnectionNotOpened extends ConnectionException{
  static create() => new ConnectionNotOpened();
  ConnectionNotOpened(): super('Connection not opened!');
}

class ConnectionOpened extends ConnectionException{
  static create() => new ConnectionOpened();
  ConnectionOpened(): super('Connection already opened!');
}

class ConnectionClosed extends ConnectionException{
  static create() => new ConnectionClosed();
  ConnectionClosed(): super('Connection already closed!');
}

class ConnectionErrored extends ConnectionException{
  Exception extraError;
  static create([e]) => new ConnectionErrored(e);
  ConnectionErrored([this.extraError]): super('Connection errored out!');
  String toString(){
    var sx = super.toString();
    var se = this.extraError.toString();
    return (sx +"\n"+ se);
  }
}

class NullDataException extends Exception{
  NullDataException(message): super(message);
}

class DualBind{
  Function fn,gn,unbindfn;

  static create(ubn,[fn,gn]) => new DualBind(ubn,fn,gn);

  DualBind(this.unbindfn,[this.fn,this.gn]);

  Function first([m]){
    if(Valids.exist(this.fn)) return this.fn(m);
  }

  Function second([m]){
    if(Valids.exist(this.gn)) return this.gn(m);
  }

  Function unbind(){
    this.unbindfn(this);
    this.fn = this.gn = null;
  }
}

abstract class MutexLock{
  dynamic get locked;
  dynamic get unlocked;
  bool get owns;
  void lock();
  void unlock();
  void owned();
  void disowned();
}

class MutexSafeLock extends MutexLock{
  MutexLockd _lock;

  static create(n) => new MutexSafeLock(n);
  MutexSafeLock(this._lock);

  dynamic get locked => this._lock.locked;
  dynamic get unlocked => this._lock.unlocked;
  bool get owns => this._lock.owns;

  void lock(){}
  void unlock(){}
  void owned(){}
  void disowned(){}
}

class MutexLockd extends MutexLock{
  final Distributor locked = Distributor.create('mutex-locked-emit');
  final Distributor unlocked = Distributor.create('mutex-unlocked-emit');
  Locker _lock;
  bool _owns = false;

  static create(n) => new MutexLockd(n);

  MutexLockd(this._lock);

  MutexLock get safe => MutexSafeLock.create(this);

  bool get isActive => this._lock != null;
  bool get owns => !!this._owns;

  void lock(){
    if(!this.isActive) return null;
    this._lock.lock(this);
  }

  void unlock(){
    if(!this.isActive) return null;
    this._lock.unlock(this);
  }

  void owned(){
    if(!this.isActive) return null;
    this.locked.emit(true);
    this._owns = true;
  }

  void disowned(){
    if(!this.isActive) return null;
    this.unlocked.emit(true);
    this._owns = false;
  }
}

class Locker{
  bool _holdLock = false;
  List _locks = new List<MutexLock>();
  MutexLocks _cur;

  static create() => new Locker();

  Locker();

  void disableSingular(){
    this._holdLock = false;
  }

  void enableSingular(){
    this._holdLock = true;
  }

  bool get singularLock => !!this._holdLock;
  bool get unlockable => !!this.singularLock && this._cur != null;

  MutexLock createLock(){
    var lk = MutexLockd.create(this);
    this._locks.add(lk);
    return lk;
  }

  void lock(MutexLock lock){
    if(this.unlockable) return null;
    if(this._locks.indexOf(lock) == -1) return null;
    if(this._cur == lock) return null;
    this._cur = lock;
    lock.owned();
    this.unlockAll([lock]);
  }

  void unlock(MutexLock lock){
    if(this._locks.indexOf(lock) == -1) return null;
    if(this._cur != lock) return null;
    this._cur.disowned();
    this._cur = null;
  }

  void unlockAll([List exs]){
    if(!this.singularLock) this._cur = null;
    this._locks.forEach((f){
      if(Valids.exist(exs)){
        if(exs.indexOf(f) != -1) return null;
      }
      f.disowned();
    });
  }
}

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

  dynamic log(String t,dynamic v,[String f]){
    f = Funcs.switchUnless(f,this.format);
    return this.factori(t,v,f);
  }

  Function get flip => this._flip;

  dynamic get enable => this._flip(true);
  dynamic get disable => this._flip(false);
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

  dynamic get enable => this._flip(true);
  dynamic get disable => this._flip(false);
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
  
  void onOnce(Function n){
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

    Map get clone => new Map.from(this.core);
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

  void delay(int ms){ 
    this._queueDelay = new Duration(milliseconds: ms);
  }
  void incDelay(int ms){
    this.incMillisFn(this._queueDelay,ms);
  }
  
  void decDelay(int ms){
    this.decMillisFn(this._queueDelay,ms);
  }
  
  void forceSingleRun(){ 
    this._forceSingleRun = true; 
  }
  void disableSingleRun(){
    this._forceSingleRun = false;
  }

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


class Middleware{
  Function _middleMan;
  List _mwares,_reversed;
  bool _added = false;
  bool _reverse = false;

  static create([n]) => new Middleware(n);

  Middleware([Function midMan(n)]){
    this._middleMan = Valids.exist(midMan) ? midMan : (n){};
    this._mwares = new List();
    this.ware((d,next,end){ next(); });
  }

  void reverseStacking(){
    this._reverse = true;
  }

  bool get stackReversed => !!this._reverse;

  Future ware(Function nware(data,Function next,Function faction)){
    var n =0,comp = new Completer();
    var fnx = ((df,nx,ed){
        return new Future.sync((){
          return nware(df,nx,ed);
        })
        .then((f){
          if(!comp.isCompleted)
            return comp.complete(f);
        })
        .catchError((f){
          if(!comp.isCompleted)
            return comp.completeError(f);
        });
    });
    this._mwares.add(fnx);
    return comp.future;
  }

  dynamic _next(index,ndata,[bool kickout]){
    var core = !!this.stackReversed ? this._reversed : this._mwares;
    index += 1;
    kickout = Funcs.switchUnless(kickout,false);
    if(!!kickout || index >= this.size) return this._middleMan(ndata);
    var cur = core[index];
    return cur(ndata,([nd]){
      var fx = Valids.exist(nd) ? nd : ndata;
      return this._next(index,fx,kickout);
    },([nd]){
      var fx = Valids.exist(nd) ? nd : ndata;
      return this._next(index,fx,true);
    });
  }

  dynamic emit(dynamic data){
    if(this._mwares.isEmpty) return null;
    if(this.stackReversed){
      this._reversed = this._mwares.reversed.toList();
    }
    return this._next(-1,data);
  }

  void clear(){
    this._mwares.clear();
  }

  int get size => this._mwares.length;
}

class JazzAtomState{
  final String id;
  final dynamic error;
  final Map meta;
  final bool state;

  static JazzAtomState create(r,s,[m,e]) => new JazzAtomState(r,s,m,e);
  JazzAtomState(this.id,this.state,[this.meta,this.error]);
}

class JazzAtom{
  Function _emitter;
  final String description;
  Middleware _groupware;
  List _done;
  List _states;
  int _failCount;

  static create(d,[fn]) => new JazzAtom(d,fn);

  JazzAtom(this.description,[Function laterfn]){ 
    this._failCount = 0;
    this._groupware = Middleware.create();
    this._done = new List();
    this._states = new List();

    var finalizer = (n){
        var ls = [{
          'total': this._groupware.size - 1,
          'fail': this._failCount, 
          'passed': (this._groupware.size - 1) - this._failCount
        }]..addAll(this._states);
        this._states.clear();
        return ls;
    };

    this._emitter = Funcs.composeList((n){
      this._groupware.emit(n);
      var waits = Future.wait([]..addAll(this._done));
      if(Valids.exist(laterfn)) laterfn(waits.then(finalizer,onError:finalizer));
      this._done.clear();
      return waits;
    },Enums.addUntilNull,10);
  }

  Future _handleRack(String desc,Future t,[Function metaFus]){
    this._done.add(t);
    return t.then((n){
      var jst = JazzAtomState.create(desc,true,{},null);
      if(Valids.exist(metaFus)) metaFus(jst);
      this._states.add(jst);
    },onError: (e){
      this._failCount += 1;
      var jst = JazzAtomState.create(desc,false,{},e);
      if(Valids.exist(metaFus)) metaFus(jst);
      this._states.add(jst);
    });
  }

  JazzAtom rack(String desc,Function unit){
    this._handleRack(desc,this._groupware.ware((d,next,end){
      return new Future.sync((){
        var val = Funcs.dartApply(unit,d);
        next();
        return val;
      });
    }));
    return this;
  }

  JazzAtom rackAsync(String desc,Function unit){
    this._handleRack(desc,this._groupware.ware((d,next,end){
      return new Future.sync((){
        var m = []..addAll(d)..add(() => next());
        var val = Funcs.dartApply(unit,m);
        return val;
      });
    }));
    return this;
  }

  JazzAtom tickAsync(String desc,int bits,Function unit){
    this._handleRack(desc,this._groupware.ware((d,next,end){
      return new Future.sync((){
        var bit = 0;
        var comp = new Completer();
        var m = []..addAll(d)..add((){ bit += 1; if(bit >= bits) return next(); });
        var val = Funcs.dartApply(unit,m);
        return comp.future;
      });
    }));
    return this;
  }

  JazzAtom clock(String desc,Function unit){
    var now = new DateTime.now();
    this._handleRack(desc,this._groupware.ware((d,next,end){
      return new Future.sync((){
        var val = Funcs.dartApply(unit,d);
        next();
        return val;
      });
    }),(jst){
      jst.meta['startTime'] = now;
      jst.meta['endTime'] = new DateTime.now();
      jst.meta['delta'] = jst.meta['endTime'].difference(jst.meta['startTime']);
    });
    return this;
  }

  JazzAtom clockAsync(String desc,Function unit){
    var now = new DateTime.now();
    this._handleRack(desc,this._groupware.ware((d,next,end){
      return new Future.sync((){
        var m = []..addAll(d)..add(() => next());
        var val = Funcs.dartApply(unit,m);
        return val;
      });
    }),(jst){
      jst.meta['startTime'] = now;
      jst.meta['endTime'] = new DateTime.now();
      jst.meta['delta'] = jst.meta['endTime'].difference(jst.meta['startTime']);
    });
    return this;
  }

  Function<Future> get emit => this._emitter;
  
}

class JazzGroups{
  final String description;
  MapDecorator atoms;
  MapDecorator atomStates;
  List _doneAtoms;
  int failCount,passedCount,total;
  Completer _whenDone;

  static JazzGroups create(String d,[Function n]){
    var jz = new JazzGroups(d);
    if(Valids.exist(n)) n(jz);
    return jz;
  }

  JazzGroups(this.description){
    this._whenDone = new Completer();
    this.failCount = 0;
    this.passedCount = 0;
    this.total = 0;
    this.atoms = MapDecorator.useMap(new Map<String,JazzAtom>());
    this.atomStates = MapDecorator.create();
    this._doneAtoms = new List();
  }
  
  JazzAtom test(String desc){
    if(this.atoms.has(desc)) return this.atoms.get(desc);
    var stat,am = JazzAtom.create(desc,(f){
      f.then((_){
         stat = _[0];
         this.failCount +=  stat['fail'];
         this.passedCount +=  stat['passed'];
         this.total += stat['total'];
         this.atomStates.update(desc,_);
      });
      this._doneAtoms.add(f);
    });
    this.atoms.add(desc,am);
    return am;
  }

  Future init(){
    this._whenDone = new Completer();
    var wait = Future.wait(this._doneAtoms);
    wait.then((f) => this._whenDone.complete(null))
      .catchError((e) => this._whenDone.complete(null));
    return wait.then((f){
      return { 
        'id':this.description, 
        'testTotal': this.atoms.core.length,
        'total': this.total,
        'passed': this.passedCount,'failed':this.failCount,
        'states':this.atomStates.clone 
      };
    });
  }

  Future get done => this._whenDone.future;
}


class Jazz{
  MapDecorator units;
  Distributor watchers;

  static Jazz create([Function n]){
    var jz = new Jazz();
    if(Valids.exist(n)) n(jz);
    return jz;
  }

  Jazz(){
    this.units = MapDecorator.useMap(new Map<String,JazzGroup>());
    this.watchers = Distributor.create('jazz-watchers');
  }
  
  JazzGroups group(String desc,Function g){
    if(this.units.has(desc)) return this.units.get(desc);
    var jz = JazzGroups.create(desc,g);
    this.units.add(desc,jz);
    return jz;
  }

  int get size => this.units.core.length;

  Future init(){
    var list = [], funits = new Completer();
    Enums.eachAsync(this.units.core,(e,i,o,fn){
      list.add(e.init());
      return fn(null);
    },(_,err){
      Future.wait(list).then(funits.complete).catchError(funits.completeError);
    });
    funits.future.then((n){
      this.watchers.emit(n);
    });
    return funits.future;
  }
}

abstract class _JazzView{
  void process(List n);
  void watch(Jazz z);
  void unwatch(Jazz z);
  void unwatchAll();
}

class JazzView extends _JazzView{
  List _watches;

  static void jazzIterator(List data,Function gfn,Function afn,Function jsfn,Function donefn,[Function doneAtomFn,Function doneGroupFn]){
    Enums.eachAsync(data,(Map e,i,o,fn){
      gfn(e,e['id']);
      if(!e.containsKey('states')) return null;
      Enums.eachAsync(e['states'],(v,n,g,fx){
        afn(v[0],n);
        Enums.eachAsync(v,(k,h,r,gx){
          if(k is JazzAtomState) jsfn(k,h);
          return gx(null);
        },(_,vx){
          if(doneAtomFn != null){
            return doneAtomFn(fx);
          }
          return fx(null);
        });
      },(_,ex){
          if(doneGroupFn != null){
            return doneGroupFn(fn);
          }
        return fn(null);
      });
    },(_,err){
      return donefn();
    });

  }

  JazzView(){
    this._watches = new List<Jazz>();
  }

  void watch(Jazz z){
    if(this._watches.contains(z)) return null;
    this._watches.add(z);
    z.watchers.on(this.process);
  }

  void unwatch(Jazz z){
    if(this._watches.contains(z)){
      z.watchers.off(this.process);
    }
  }

  void unwatchAll(){
    this._watches.forEach((f){
      f.watchers.off(this.process);
    });
  }
}

class ConsoleView extends JazzView{
  String gtemp,atemp;
  Function gt,at;
  Function printer;

  static create([gs,ts,fn]) => new ConsoleView(gs,ts,fn);

  ConsoleView([String gs,String ts,Function pr]):super(){
    this.printer = Funcs.switchUnless(pr,print);
    this.gtemp = Funcs.switchUnless(gs,"{0}: #{1} -> {2}");
    this.atemp = Funcs.switchUnless(ts,this.gtemp);
    this.gt = Funcs.stamp(gtemp);
    this.at = Funcs.stamp(atemp);
  }

  void process(data){
    var buffer = new StringBuffer();
    buffer.write("---------------------------------------");
    buffer.write("\n");
    buffer.write("        Jazz Tests Results");
    buffer.write("\n");
    buffer.write("---------------------------------------");
    buffer.write("\n");
    var count = 0;
    
    JazzView.jazzIterator(data,(g,id){
      var tests = g['testTotal'],total = g['total'], passed = g['passed'],fail = g['failed'];
      buffer.write("\n");
      buffer.write(this.gt(['Group',id,'Total Tests: $tests, Total Atoms: $total, Passed Atoms: $passed, Failed Atoms: $fail ']));
      buffer.write("\n");
    },(meta,id){
      buffer.write("\n");
      count = 0;
      buffer.write(this.at(['-> Atom',id,'Total: ${meta['total']}, Failed: ${meta['fail']} Passed: ${meta['passed']}']));
      buffer.write('\n------------------------------------------------------------------\n');
    },(atom,id){
      count += 1;
      buffer.write("\n");
      var delta = atom.meta['delta'];
      var start = atom.meta['startTime'];
      var end = atom.meta['endTime'];
      buffer.write(this.at(['  Atom Unit',atom.id,'State: ${!!atom.state ?'Passed':'Failed'}']));
      /*buffer.write('\n------------------------------------------------------------------');*/
      if(Valids.exist(atom.error)){
        buffer.write('\n    Error: ${atom.error}');
      }
      if(delta != null){
        buffer.write('\n    StartTime: ${start == null ? null : start }');
        buffer.write('\n    EndTime: ${end == null ? null : end }');
        buffer.write('\n    RunTime: ${delta == null ? null : delta.inMilliseconds }ms');
      }
      buffer.write("\n");
    },(){
      this.printer(buffer.toString());
    });
  }

}

final ConsoleView jazzConsole = ConsoleView.create();
Future jazzUp(Function init){
 var jz = Jazz.create();
 jazzConsole.watch(jz);
 init(jz);
 return jz.init();
}
