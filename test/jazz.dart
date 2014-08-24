library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){
  
  var jazz = Jazz.create();
  var view = ConsoleView.create();
  view.watch(jazz);

  jazz.group('testing basic runs',(g){
  
    g.test('can i run sync')
    .rack('can i pass',(d) => d == 1)
    .clock('can i fail',(d){ return d == 1;})
    .emit(1);

    g.test('can i run async')
    .rackAsync('can i pass async',(d,nxt){  
      Expects.asserts(d,1);
      nxt();  
    })
    .clockAsync('can i jug async',(d,nxt){  
      Expects.asserts(d,2);
      nxt(); 
    })
    .emit(1);

    g.test('can i use expects')
    .rack('check asserts',(d){
      Expects.asserts(d,3);
    }).emit(2);

  });

  jazz.init().then(Funcs.tag('wow'));

}
