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
    this.insertPoint.children.clear();
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
      var atoms = ubuff.join('\n');
      var sets = sbuff[cset];
      sets = sets.replaceAll("{{atomunit_buffer}}",atoms);
      sbuff[cset] = sets;
      cset += 1;
      ubuff.clear();
      fx(null);
    },(ex){
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

final HtmlView webConsole = HtmlView.create(window.document.body);
final JStripe stripjs = JStripe.create(window);
final blinker = new Element.html('<div class="blinker"><span>Generating Tests...</span></div>');

Function jazzUp(Function init){
 window.document.body.append(blinker);
 var jz = Jazz.create();
 init(jz);
 webConsole.watch(jz);
 webConsole.buttonClick.onClick.listen((e){
   blinker.classes.remove('hidden');
   new Timer(new Duration(milliseconds:1000),(){
     return jz.init().then((j){
        blinker.classes.add('hidden');
     });
   });
 });
 webConsole.buttonClick.dispatchEvent(new Event('click'));
}
