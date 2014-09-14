library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){

  jazzUp((_){

    _.group('testing atomics',(g){

      var atomic = AtomicMap.create();

      g.test('testing atomics addition')
      .rackAsync('add 1',(f,nx,g){
        atomic.onAdd.on(g((i){
          Expects.isMap(i);
          Expects.asserts(i['value'],1);
          nx();
        }));
        atomic.add('items',1);
      })
      .rackAsync('update items value to 10',(f,nx,g){
        atomic.onUpdate.on(g((m){
          Expects.isMap(m);
          Expects.asserts(m['old'],1);
          Expects.asserts(m['new'],10);
          nx();
        }));
        atomic.update('items',10);
      })
      .rackAsync('remove items',(f,nx,g){
        atomic.onRemove.on(g((m){
          Expects.isMap(m);
          Expects.isFalse(atomic.has('items'));
          nx();
        }));
        atomic.destroy('items');
      })
      .emit(atomic);

    });

  });

}
