library hubclient;

import 'dart:async';
import 'dart:js';
import 'dart:html';
import 'package:hub/hub.dart';

export 'package:hub/hub.dart';

final String groupFragment = (""" 
      <article class="groupcase">
        <div class="meta_headline" id="group_meta">
          <div class="meta">
            <label class="metaHead">{{grouptitle}}</label>:<label class="metaTail">{{grouptitleVal}}</label>
          </div>
          <div class="meta">
            <label class="metaHead">{{grouptotal}}</label>:<label class="metaTail">{{grouptotalVal}}</label>
          </div>
          <div class="meta">
            <label class="metaHead">{{groupatoms}}</label>:<label class="metaTail">{{groupatomsVal}}</label>
          </div>
          <div class="meta">
            <label class="metaHead">{{grouppassed}}</label>:<label class="metaTail">{{grouppassedVal}}</label>
          </div>
          <div class="meta">
            <label class="metaHead">{{groupfailed}}</label>:<label class="metaTail">{{groupfailedVal}}</label>
          </div>
        </div>
        <section class="atomsets">
          <div class="atoms">
          {{atomsets_buffer}}
          </div>
        </section>
      </article>
""");

final String setFragment = (""" 
<div class="setGroup">
  <div class="meta_headline" id="atomset_meta">
    <div class="meta">
      <label class="metaHead">{{settitle}}</label>:<label class="metaTail">{{settitleVal}}</label>
    </div>
    <div class="meta">
      <label class="metaHead">{{settotal}}</label>:<label class="metaTail">{{settotalVal}}</label>
    </div>
    <div class="meta">
      <label class="metaHead">{{setpassed}}</label>:<label class="metaTail">{{setpassedVal}}</label>
    </div>
    <div class="meta">
      <label class="metaHead">{{setfailed}}</label>:<label class="metaTail">{{setfailedVal}}</label>
    </div>
  </div>
  <article class="atomunit">
    {{atomunit_buffer}}
  </article>
</div>
""");

final String unitFragment = (""" 
    <div class="meta_headline" id="atomunit_meta">
      <div class="meta">
        <label class="metaHead">{{unittitle}}</label>:<label class="metaTail">{{unittitleVal}}</label>
      </div>
      <div class="meta">
        <label class="metaHead">{{unitstate}}</label>:<label class="metaTail">{{unitstateVal}}</label>
      </div>
      <div class="meta">
        <label class="metaHead">{{unittime}}</label>:<label class="metaTail">{{unittimeVal}}</label>
      </div>
      <div class="meta" id="errorMeta">
        <label class="metaHead">{{uniterror}}</label>:<label class="metaTail">{{uniterrorVal}}</label>
      </div>
    </div>
""");

final String styleTemplate =("""
     *{
       padding: 0px;
       margin: 0px;
       box-sizing: border-box;
       -moz-box-sizing: border-box;
       -webkit-box-sizing: border-box;
     }

     html{
      width:100%;
      height: 100%;
     }

     @keyframes blinkerAnimate{
       0% { opacity: 0.2; }
       100% { opacity: 1; }
     }

     .hidden{
       display: none !important;
     }

    .show{
       display: block;
    }

    .bootError{
        background: rgba(247, 250, 255, 1);
        position: absolute;
        top: 0px;
        left: 0px;
        z-index: 4000;
        width: 100%;
        height: 100%;
        display: block;
        font-size: 5em;
        font-weight: bold;
     }

    .bootError *{
       padding: 20%;
       display:block;
       font-family: Helvetica,sans,sans-serif;
       animation: blinkerAnimate 0.75s steps(20) infinite;
     }

     .blinker{
        background: rgba(247, 250, 255, 1);
        position: absolute;
        top: 0px;
        left: 0px;
        z-index: 3000;
        width: 100%;
        height: 100%;
        display: block;
        font-size: 5em;
        font-weight: bold;
     }
  
     .blinker span{
       padding: 20%;
       display:block;
       font-family: Helvetica,sans,sans-serif;
       animation: blinkerAnimate 0.75s steps(20) infinite;
     }

     body{
       min-width: 320px;
       width:100%;
       height: 100%;
       font-size: 100%;
     }

     .tests{
        font-size: 100%;
        font-family: Helvetica,sans-serif,serif;
        position: relative;
     }

     .tests .header{
       position: relative;
       width: 100%;
       height: 100px;
     }

     .tests .header .headline{
       position: relative;
       width: 100%;
       height: 100%;
       background: rgba(33,106,199,1);
       color: rgba(255,255,255,1);
     }

     .tests .header .headline h1{
       font-size: 3.0em;
       padding: .5em .3em;
     }

     .button{
       border: 2px solid rgba(255,255,255,0.6);
       border-radius: .2em;
       font-size: 1.0em;
       cursor: pointer;
     }

     .button:hover{
       background: rgba(255,255,255,1);
       border-radius: .2em;
       font-size: 1.0em;
       color: rgba(0,0,0,1);
     }

     .tests .header .headline #runbutton{
       position: absolute;
       top: 0em;
       right: 4em;
       padding: 1em;
       margin: 1.5em 0em;
     }

     .tests .testcases{
       width: 100%;
       font-size: 100%;
       height: auto;
       background: rgba(247, 250, 255, 1);
     }

     .tests .testcases .groupcase{
       background: rgba(247, 250, 255, 1);
       width: 100%;
       height: auto;
     }

     .meta_headline{
       width: 100%;
       height: auto;
       position: relative;
     }

     .meta_headline .meta{
       display: inline-block;
       padding: 1em 1.5em;
     }

     .meta_headline #errorMeta{
       display: block;
     }

     .meta_headline .meta label{
       display: inline;
     }

     .meta_headline .meta label.metaHead{
        font-weight: bold;
     }

     .meta_headline .meta label.metaTail{
        font-weight: normal;
        padding: 0px 1em;
     }

     .groupcase,.atomsets,.atomunit{
       width:100%;
       height: auto;
     }

     .setGroup{
       padding:0em 0em 0em 0em;
     }

     .atomunit{
       padding:0em 0em 0em .3em;
     }

     .groupcase #group_meta{
       background: rgba(19,202,208,1);
     }

     .groupcase #atomset_meta{
       background: rgba(233, 52, 139, 1);
       color: rgba(255,255,255,1);
     }

     .groupcase #atomunit_meta{
       /* background: rgba(249, 250, 255, 1); */
       border-bottom: 1px solid rgba(0,0,0,0.132);
     }

     @media  screen and (max-width: 120em) and (min-width:84em){
       .tests{
          font-size: 100%;
       }

       .tests .testcases{
         font-size: 120%;
       }
     }

     @media  screen and (max-width: 64em) and (min-width:48em){
       .tests{
          font-size: 80%;
       }

       .tests .testcases{
         font-size: 110%;
       }
     }

     @media  screen and (max-width: 48em) and (min-width:32em){
       .tests{
          font-size: 70%;
       }

       .tests .testcases{
         font-size: 120%;
       }

       /*.meta_headline .meta{*/
       /*  display: block;*/
       /*  margin: 1em 0m;*/
       /*}*/

     }

     @media  screen and (max-width: 32em){

       .tests{
          font-size: 95%;

       }

       .tests .testcases{
         font-size: 120%;
       }

       .tests .header .headline h1{
         font-size: 1.8em;
         padding: 1.2em .5em;
       }

       .tests .header .headline #runbutton{
         right: 2em;
       }

       .meta_headline .meta{
         display: block;
         margin: 1em 0m;
       }

       .blinker{
          padding: 2em .5em;
          font-size: 2.4em;
       }
     }

""");

final String pageTemplate = ("""
   <section class="tests">
     <section class="header">
       <section class="headline">
        <h1>Jazz Test Suite</h1>
        <div class="button" id="runbutton">
          <a id="#">Run</a>
        </div>
       </section>
     </section>
     <section class="testcases">

     </section>
   </section>
""");

class HtmlView extends JazzView{
  Document rootDoc;
  BodyElement root;
  Element template,style;
  Element insertPoint;
  Element buttonClick;

  static create(n) => new HtmlView(n);
  HtmlView(this.root):super(){
    this.rootDoc = this.root.ownerDocument;
    this.template = new Element.html(pageTemplate);
    this.style = new StyleElement();
    this.insertPoint = this.template.querySelector('.testcases');
    this.buttonClick = this.template.querySelector('#runbutton');

    this.style.attributes['id'] = 'HtmlViewStyle';
    this.style.text = styleTemplate;

    var head = this.rootDoc.querySelector('head');
    head.append(this.style);
    this.root.append(this.template);
  }

  void process(data){
    /*this.insertPoint.children.clear();*/
    var gset = 0,cset = 0,gbuff = [], sbuff = [],ubuff = [];
    JazzView.jazzIterator(data,(g,id){
      var gbuf = groupFragment;
      var tests = g['testTotal'],
          total = g['total'],
          passed = g['passed'],
          failed = g['failed'];

       gbuf = gbuf.replaceAll('{{grouptitle}}','Group')
       .replaceAll('{{grouptitleVal}}',id)
       .replaceAll('{{grouptotal}}','Total Tests')
       .replaceAll('{{grouptotalVal}}',tests.toString())
       .replaceAll('{{groupatoms}}','Total Atoms')
       .replaceAll('{{groupatomsVal}}',total.toString())
       .replaceAll('{{grouppassed}}','Passed Atoms')
       .replaceAll('{{grouppassedVal}}',passed.toString())
       .replaceAll('{{groupfailed}}','Failed Atoms')
       .replaceAll('{{groupfailedVal}}',failed.toString());

    gbuff.add(gbuf);
    },(meta,id){
      var total = meta['total'],
          passed = meta['passed'],
          failed = meta['fail'];

      var buffer = setFragment;
      buffer = buffer.replaceAll('{{settitle}}','Atom')
       .replaceAll('{{settitleVal}}',id)
       .replaceAll('{{settotal}}','Total')
       .replaceAll('{{settotalVal}}',total.toString())
       .replaceAll('{{setpassed}}','Passed Atoms')
       .replaceAll('{{setpassedVal}}',passed.toString())
       .replaceAll('{{setfailed}}','Failed Atoms')
       .replaceAll('{{setfailedVal}}',failed.toString());

      sbuff.add(buffer);
    },(atom,id){
      var buffer = unitFragment;
      var delta = atom.meta['delta'],
          err = atom.error,
          id = atom.id,
          state = (atom.state ? 'Passed' : 'Failed'),
          st = atom.meta['startTime'],
          et = atom.meta['endTime'];

       buffer = buffer.replaceAll('{{unittitle}}','Atom Unit')
       .replaceAll('{{unittitleVal}}',id)
       .replaceAll('{{unitstate}}','Unit State')
       .replaceAll('{{unitstateVal}}',state)
       .replaceAll('{{uniterror}}','Unit Error')
       .replaceAll('{{uniterrorVal}}',err == null ? 'No Errors' : err.toString())
       .replaceAll('{{unittime}}','Total Run Time')
       .replaceAll('{{unittimeVal}}',delta == null ? 'Not Timed' : "${delta.inMilliseconds}ms");

       ubuff.add(buffer);
    },(){
       gbuff.forEach((f){
         this.insertPoint.append(new Element.html(f.toString()));
       });
       gbuff.clear();
       cset = gset = 0;
    },(fx){
      if(cset > sbuff.length) cset = sbuff.length - 1;
      var atoms = ubuff.join('\n');
      var sets = sbuff[cset];
      sets = sets.replaceAll("{{atomunit_buffer}}",atoms);
      sbuff[cset] = sets;
      cset += 1;
      ubuff.clear();
      fx(null);
    },(ex){
      if(gset > gbuff.length) gset = gbuff.length - 1;
      var asets = sbuff.join('\n');
      var gs = gbuff[gset];
      gs = gs.replaceAll("{{atomsets_buffer}}",asets);
      gbuff[gset] = gs;
      gset += 1;
      cset -= 1;
      sbuff.clear();
      ex(null);
    });

  }

}

class JStripe{
  final fragments = Hub.createMapDecorator();
  final methodfragments = Hub.createMapDecorator();
  final JsObject defaultContext = context;
  Funcstion _apply;
  JsObject root;
  dynamic core;

  static create(s) => new JStripe(s);

  JStripe(t){
    this.core = t;
    this.root = new JsObject.fromBrowserObject(t);
    this.fragments.add('root',this.root);
    this._apply = Funcs.composeList((n){
      var clean = Enums.addUntilNull(n),
          path = Enums.yankFirst(clean);
     var fn = this.at(path);
     if(Valids.notExist(fn)) return null;
     return Funcs.dartApply(fn,clean);
    },Funcs.identity,10);
  }

  //converts a native dart object into a js object
  /*dynamic convert(Object d){*/
  /*  if(d is String || d is num || d == null || d is bool) */
  /*    throw "Cant convert String,num and bool or null objects";*/
  /*  return new JsObject.fromBrowserObject(d);*/
  /*}*/

  //converts a native dart object into jsobject and adds it into the fragment list for use
  /*dynamic addNative(String tag,Object d){*/
  /*  var frag = this.convert(d);*/
  /*  this.fragments.add(tag,frag);*/
  /*  return frag;*/
  /*}*/

  Function get apply => this._apply;

  dynamic jsFragment(String tag,[String prop]){
    var fragment = this.fragments.get(tag);
    if(fragment == null) return null;
    if(prop == null) return fragment;
    return this.grabProperty(fragment,prop);
  }

  bool set(String tag,String prop,dynamic val,[String inprop]){
    var fragment = this.jsFragment(tag,inprop);
    if(fragment == null) return false;
    fragment[prop] = val;
    return true;
  }

  void unset(String tag,String prop,[String inprop]){
    var fragment = this.jsFragment(tag,inprop);
    if(fragment == null) return false;
    fragment.deleteProperty(prop);
    return true;
  }

  Function at(String path){
    var pieces = path.split('@');
    if(pieces.length <= 0 || pieces.length > 3) return null;
    return Funcs.dartApply(this.runOn,pieces);
  }

  void register(String tag,[String method,String prop]){
    this.fragment(tag);
    if(Valids.exist(method))
      return this.methodFragment(tag,method,prop);
    return null;
  }

  void fragment(String tag){
    this.fragments.add(tag,this.root[tag]);
  }

  void removeFragment(String tag){
    var mfrag = this.methodfragments.destroy(tag);
    if(mfrag != null) mfrag.flush();
    this.fragments.destroy(tag);
  }

  bool hasFragment(String tag) => this.fragments.has(tag);

  bool hasMethodFragment(String tag,String method){
    if(!this.hasFragment(tag) || !this.methodfragments.has(tag)) return false;
    var mf = this.methodfragments.get(tag);
    if(!mf.has(method)) return false;
    return true;
  }

  dynamic grabProperty(JsObject fragment,String props){
    var sets = props.split('.'), ind = 0, cur = fragment;

    while(ind < sets.length){
      if(cur == null || ind >= sets.length) return cur;
      cur = cur[sets[ind]];
      ind += 1;
    }

    return cur;
  }

  void methodFragment(String tag,String method,[String prop]){
    if(!this.fragments.has(tag)) return;

    var fragment = this.fragments.get(tag);
    var methods = (this.methodfragments.has(tag) ? this.methodfragments.get(tag) : Hub.createMapDecorator());
    
    var inProp = (prop != null ? prop : method).toString();

    var mf = this.grabProperty(fragment,inProp);
    if(mf == null) return;

    methods.add(method,(List ops){
      if(mf is JsFunction) 
        return mf.apply(ops,thisArg: fragment);
      return mf;
    });

    this.methodfragments.add(tag,methods);
  }

  dynamic runOn(String tag,String fragment,[String method]){
    if(!this.fragments.has(tag) || !this.methodfragments.has(tag)) return null;
    var methods = this.methodfragments.get(tag);
    var frag = methods.get(fragment);
    return ([dynamic extra]){
      var args = new List();
      if(method != null) args.add(method);
      if(extra is List) args.addAll(extra);
      else args.add(extra);
      return frag(args);
    };
  }

  dynamic toDartJSON(JsObject m){
    return context['JSON'].callMethod('stringify',[m]);  
  }
  
  dynamic toJS(dynamic m){
          return new JsObject.jsify(m);
  }

  String toString(){
          return "${this.fragments} \n ${this.methodfragments}";
  }
}

class DisplayHook{
	TaskQueue tasks;
	Window w;
	Switch alive;
	List<Timers> _repeaters;
	int _frameid;

	static create(w) => new DisplayHook(w);

	DisplayHook(this.w){
          this._repeaters = new List<Timers>();
          this.tasks = TaskQueue.create(false);
          this.alive = Switch.create();
          this.tasks.immediate(this._scheduleDistributors);
	}

	int get id => this._frameid;
	
	void schedule(Function m(int ms)) => this.tasks.queue(m);
	void scheduleDelay(int msq,Function m(int ms)) => this.tasks.queueAfter(msq,m);
	void scheduleImmediate(Function m(int ms)) => this.tasks.immediate(m);
	Timer scheduleEvery(int msq,Function m){
		var t = this.tasks.queueEvery(msq,m);
		this._repeaters.add(t);
		return t;
	}

	void _scheduleDistributors([n]){
		this.tasks.queue(this._scheduleDistributors);
	}

	void emit([int n]){
		this.tasks.exec(n);
		this.run();
	}

	void run(){
          if(this.alive.on()) return null;
          this._frameid = this.w.requestAnimationFrame((i) => this.emit(i));
          this.alive.switchOn();
	}

	void stop(){
          if(!this.alive.on()) return null;
          this.alive.switchOff();
          this.w.cancelAnimationFrame(this._frameid);
          this._repeaters.forEach((f) => f.cancel());
          this.tasks.clearJobs();
	}

	String toString() => "DisplayHook with ${this._frameid}";

        void destroy(){
          this.repeaters.clear();
          this.tasks.destroy();
          this.alive.close();
          this.w = null;
        }

}

abstract class EventContract{
  void bind(String name,Function n);
  void bindOnce(String name,Function n);
  void unbind(String name,Function n);
  void unbindOnce(String name,Function n);
}

class QueryShell{
    Element root;
    QueryShell _ps;
    
    static create(d) => new QueryShell(d);
    QueryShell(this.root);

    Element get parent => this.root.parentNode;

    QueryShell get p{
      if(Valids.exist(this._ps)) return this._ps;
      if(Valids.notExist(this.parent)) return null;
      this._ps = QueryShell.create(this.parent);
      return this._ps;
    }

    bool matchSelector(String selector) => this.root.matches(selector);

    dynamic css(dynamic a){
      if(Valids.isList(a)) return QueryUtil.getCSS(this.root,a);
      if(Valids.isMap(a)) return QueryUtil.cssElem(this.root,a);
      return null;
    }
    
    bool matchAttr(String n,dyanmic v){
      if(!this.hasAttr(n)) return false;
      return Valids.match(this.attr(n),v);
    }

    bool matchData(String n,dyanmic v){
      if(!this.hasData(n)) return false;
      return Valids.match(this.data(n),v);
    }

    bool hasAttr(String n) => this.root.attributes.containsKey(n);
    bool hasData(String n) => this.root.dataset.containsKey(n);
    
    dynamic attr(String n,[dynamic val,Function fn]){
      var dv = this.root.getAttribute(n);
      if(Valids.exist(fn)) fn(dv);
      if(Valids.notExist(val)) return dv;
      return this.root.attributes[n] = val.toString();
    }

    dynamic data(String n,[dynamic val,Function fn]){
      var dv = this.root.dataset[n];
      if(Valids.exist(fn)) fn(dv);
      if(Valids.notExist(val)) return dv;
      return this.root.dataset[n] = val.toString();
    }

    dynamic query(n,[v]) => QueryUtil.queryElem(this.root,n,v);
    dynamic queryAll(n,[v]) => QueryUtil.queryAllElem(this.root,n,v);

    dynamic get style => this.root.getComputedStyle();

    dynamic createElement(String n,[String content]){
        var elem = QueryUtil.createElement(n);
        if(Valids.exist(content)) elem.setInnerHtml(content);
        QueryUtil.defaultValidator.addTag(elem.tagName);
        this.root.append(elem);
        return elem;
    }

    dynamic createHtml(String markup){
        var elem = QueryUtil.createHtml(markup);
        QueryUtil.defaultValidator.addTag(elem.tagName);
        this.root.append(elem);
        return elem;
    }

    dynamic toHtml() => QueryUtil.liquify(this.root);
    void useHtml(html.Element l) => QueryUtil.deliquify(l,this.root);

    void dispatchEvent(String d,[v]) => QueryUtil.dispatch(this.root,d,v);

    void queryMessage(String sel,String type,d) => this.deliverMessage(sel,type,d,this.root);
    void queryMassMessage(String sel,String type,d) => this.deliverMassMessage(sel,type,d,this.root);

}

class CustomValidator{
  NodeValidatorBuilder _validator;

  CustomValidator(){
    this._validator = new NodeValidatorBuilder();
    this.rules.allowSvg();
    this.rules.allowHtml5();
    this.rules.allowInlineStyles();
    this.rules.allowTextElements();
    this.rules.allowTemplating();
    this.rules.allowElement('script',attributes:['id','data','rel']);
    this.rules.allowElement('link',attributes:['id','data','rel']);
    this.rules.allowElement('script',attributes:['id','data','rel']);
  }

  void addTag(String n){
          this.rules.allowElement(n.toLowerCase());
  }

  dynamic get rules => this._validator;
}

class QueryUtil{

    static RegExp digitReg = new RegExp(r'\d');
    static RegExp wordReg = new RegExp(r'\w');
    static CustomValidator defaultValidator = new CustomValidator();
    static num fromPx(String px){
      return num.parse(px
          .replaceAll('px','')
          .replaceAll('%','')
          .replaceAll('em','')
          .replaceAll('vrem','')
          .replaceAll('rem',''));
    }
    static String toPx(num px) => "${px}px";
    static String toPercent(num px) => "${px}%";
    static String toRem(num px) => "${px}rem";
    static String toEm(num px) => "${px}em";

    static void deliverMessage(String sel,String type,dynamic r,[Document n]){
      n = Funcs.switchUnless(n,window.document);
      QueryUtil.queryElem(n,sel,(d){
        QueryUtil.dispatchEvent(type,d,r);
      });
    }

    static void deliverMassMessage(String sel,String type,dynamic r,[Document n]){
      n = Funcs.switchUnless(n,window.document);
      QueryUtil.queryAllElem(n,sel,(d){
        d.forEach((v){
          QueryUtil.dispatchEvent(type,v,r);
        });
      });
    }

    static void dispatchEvent(Element t,String n,[dynamic d]){
      return t.dispatchEvent(new CustomEvent(n,detail:d));
    }

    static dynamic getCSS(Element n,List a){
      var res = {};
      attr.forEach((f){
         res[f] = n.style.getProperty(f);
      });
      return MapDecorator.create(res);
    }
    
    static dynamic queryElem(Element d,String query,[Function v]){
      var q = d.querySelector(query);
      if(Valids.exist(q) && Valids.exist(v)) v(q);
      return q;
    }

    static dynamic queryAllElem(Element d,String query,[Function v]){
      var q = d.querySelectorAll(query);
      if(Valids.exist(q) && Valids.exist(v)) v(q);
      return q;
    }

    static void cssElem(Element n,Map m){
      m.forEach((k,v){
          var val = v;
          if(Valids.isNumber(v)) val = QueryUtil.toPx(v);
          n.style.setProperty(k,val);
      });
    }

    static Element createElement(String n){
      QueryUtil.defaultValidator.addTag(n);
      return window.document.createElement(n);
    }

    static Element createString n){
      return new Element.n,validator: QueryUtil.defaultValidator.rules);
    }

    static Element liquify(Element n){
      var b = QueryUtil.createElement(n.tagName.toLowerCase());
      b.setInnern.innervalidator: QueryUtil.defaultValidator.rules);
      return b;
    }

    static void deliquify(Element l,Element hold){
      hold.setInnerl.innervalidator: QueryUtil.defaultValidator.rules);
    }

}

class EventsFactory{
	MapDecorator _hidden,factories;
	MapDecorator bindings;
	EventContract handler;

	static create(n) => new EventsFactory(n);

	EventsFactory(this.handler){
		this._hidden = MapDecorator.create();
		this.factories = MapDecorator.create();
		this.bindings = MapDecorator.create();
	}

	void addFactory(String name,Function n(e)){
		this._hidden.add(name,n);
		this.factories.add(name,(n){
			this._hidden.get(name)(n);
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

	void bindFactory(String name,String ft){
		if(!this.factories.has(ft)) return null;
                /*if(this.bindings.has(name) && this.bindings.get(name).contains(ft)) return null;*/
		(this.bindings.has(name) ? this.bindings.get(name).add(ft) : this.bindings.add(name,[ft]));
		this.handler.bind(name,this.factories.get(ft));
	}

	void bindFactoryOnce(String name,String ft){
		if(!this.factories.has(ft)) return null;
		// (this.bindings.has(name) ? this.bindings.get(name).add(ft) : this.bindings.add(name,[ft]));
		this.handler.bindOnce(name,this.factories.get(ft));
	}

	void unbindFactory(String name,String ft){
		if(!this.factories.has(ft)) return null;
		(this.bindings.has(name) ? this.bindings.get(name).removeElement(this.factories.get(ft)) : null);
		this.handler.unbind(name,this.factories.get(ft));
	}

	void unbindFactoryOnce(String name,String ft){
		if(!this.factories.has(ft)) return null;
		this.handler.unbindOnce(name,this.factories.get(ft));
	}

	void unbindAllFactories(){
		this.bindings.onAll((name,list){
			list.forEach((f) => this.unbindFactory(name,f));
		});
	}

	void destroy(){
		this.unbindAllFactories();
		this._hidden.clear();
		this.factories.clear();
		this.handler = this._hidden = this.factories = null;
	}
}

class ElementBindings{
	final hooks = MapDecorator.create();
	final List<html.Element> _hiddenElements;
	bool _supportHiddenElement = false;
	html.Element element;

	static create() => new ElementBindings();

	ElementBinding();

	void enableMutipleElements() => this._supportHiddenElement = true;
	void disabeMultipleElements() => this._supportHiddenElement = false;
	bool get supportMultiple => !!this._supportHiddenElement;

	void destroy(){
		this.unHookAll();
		this.hooks.onAll((n,k) => k.free());
		this.hooks.clear();
		this.element = null;
	}

	void _bindHidden(html.Element e){
		if(this._hiddenElements.contains(e)) return null;
		this._hiddenElements.add(e);
		this.hooks.onAll((k,v){
			this.addHook(k,null,e);
		});
	}

	void _unbindAllHidden(){
		this._hiddenElements.forEach((f){
			this.hooks.onAll((k,v){
				this.removeHook(k,f);
			});
		});
	}

	void _rebindAllHidden(){
		this._hiddenElements.forEach((f){
			this.hooks.onAll((k,v){
				this.addHook(k,null,f);
			});
		});
	}

	void bindTo(html.Element e){
		if(this.supportMultiple) return this._bindHidden(e);
		this.unHookAll();
		this.element = e;
		this.rebindAll();
	}

	void rebindAll(){
		if(this.supportMultiple) return this._rebindAllHidden();
		this.hooks.onAll((k,v){
			this.addHook(k);
		});
	}

	void unHookAll(){
		if(this.supportMultiple) return this._unbindAllHidden();
		this.hooks.onAll((k,v){
			this.removeHook(k);
		});
	}

	dynamic getHooks(String name) => this.hooks.get(name);

	void addHook(String name,[Function n,html.Element hidden]){
		var ds, elem = Valids.exist(hidden) ? hidden : this.element;
		if(this.hooks.has(name)){
			ds = this.getHooks(name);
		}else{
			ds = Hub.createDistributor('$name-hook');
			this.hooks.add(name,ds);
		}

		if(Valids.exist(n)) ds.on(n);
		if(Valids.exist(elem)) 
			elem.addEventListener(name,ds.emit,false);
	}

	void removeHook(String name,[html.Element e]){
		if(!this.hooks.has(name)) return null;

		var ds = this.hooks.get(name), elem = Valids.exist(e) ? e : this.element;

		if(Valids.exist(elem)) 
			elem.removeEventListener(name,ds.emit,false);
	}

	void fireHook(String name,dynamic n){
		if(!this.hooks.has(name)) return null;

		var e = (n is html.CustomEvent ? (n.eventPhase < 2 ? n : 
			new html.CustomEvent(name,detail: n.detail)) 
			: new html.CustomEvent(name,detail: n));

		if(Valids.notExist(this.element)) return this.hooks.get(name).emit(e);
		return this.element.dispatchEvent(e);
	}

	void bind(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).on(n);
	}

	void bindWhenDone(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).whenDone(n);
	}

	void unbindWhenDone(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).offWhenDone(n);
	}

	void bindOnce(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).once(n);
	}

	void unbind(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).off(n);
	}

	void unbindOnce(String name,Function n){
		if(!this.hooks.has(name)) return null;
		return this.hooks.get(name).offOnce(n);
	}

	String toString() => this.hooks.toString();
}

final HtmlView webConsole = HtmlView.create(window.document.body);
final JStripe stripjs = JStripe.create(window);
final blinker = new Element.html('<div class="blinker"><span>Generating Tests...</span></div>');
final error = new Element.html('<div class="bootError hidden"></div>');

Function jazzUp(Function init){
 window.document.body.append(blinker);
 window.document.body.append(error);
 var jz = Jazz.create();
 init(jz);
 webConsole.watch(jz);
 webConsole.buttonClick.onClick.listen((e){
   webConsole.insertPoint.children.clear();
   blinker.classes.remove('hidden');
   new Timer(new Duration(milliseconds:1000),(){
     return jz.init().then((j){
        blinker.classes.add('hidden');
        error.classes.add('hidden');
     }).catchError((e){
        error.setInnerText(e.toString());
        error.classes.remove('hidden');
        throw e;
     });
   });
 });
 webConsole.buttonClick.dispatchEvent(new Event('click'));
}
