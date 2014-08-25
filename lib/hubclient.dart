library hubclient;

import 'dart:js';
import 'dart:html';
import 'package:hub/hub.dart';

export 'package:hub/hub.dart';

final HtmlView webConsole = webConsole.create();
final JStripe stripjs = JStripe.create(window);

Function jazzWeb(Function init){
 var jz = Jazz.create();
 webConsole.watch(jz);
 init(jz);
 return jz.init();
}

class HtmlView extends JazzView{
  Element root;

  static create([n]) => new HtmlView([n]);
  HtmlView([Element rt]):super(){
    this.root = Funcs.switchUnless(rt,new Element.tag('div'));
  }

  void process(data){

    JazzView.jazzIterator(data,(g,id){

    },(meta,id){

    },(atom,id){

    },(){
       window.document.body.append(this.root);
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
