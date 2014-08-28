library hub.spec;

import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hubclient.dart';

class Example{
  String name;
  Example(this.name);
  String shout() => 'Soutout ${this.name}!';
}

void main(){

  jazzUp((_){

    _.group('testing stripjs fragment',(g){

      g.test('can we use console')
      .clock('adding fragment',(f){
        f.fragment('console');
        Expects.asserts(f.hasFragment('console'),true);
      })
      .rack('removing fragment',(f){
        f.removeFragment('console');
        Expects.asserts(f.hasFragment('console'),false);
      })
      .emit(stripjs);

      g.test('can we use console.log')
      .rack('adding log function',(f){
        f.fragment('console');
        f.register('console','log');
        Expects.asserts(f.hasMethodFragment('console','log'),true);
      }).emit(stripjs);

    });

    _.group('testing stripjs setting ability',(g){

    });

  });

  var es = new Example('es');
  assert(stripjs.set('root','choice','thunder'));
  assert(stripjs.jsFragment('root','choice') == 'thunder');
  stripjs.set('root','esj',es);
  stripjs.set('root','esf',(s){ print(es.shout()); });


}
