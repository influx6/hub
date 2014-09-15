library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'package:hub/hub.dart';

void main(){

  jazzUp((_){

    _.group('can i create locks',(g){

      g.test('create a lock and mutex')
      .rack('is it a real lock',(f,g){
        Expects.exist(f);
        Expects.isTrue(f is Locker);
      })
      .rack('can locker create mutexs',(f,g){
        var mut = f.createLock();
        var mutsafe = mut.safe;
        Expects.exist(mut);
        Expects.isTrue(mut is MutexLock);
        Expects.isTrue(mut is MutexLockd);
        Expects.isTrue(mutsafe is MutexLock);
        Expects.isTrue(mutsafe is MutexSafeLock);
      })
      .emit(Locker.create());

      g.test('can i lock using a mutex')
      .tickAsync('create two locks and check locks states',2,(r,next,k){
        var f = Locker.create();
        var g1 = f.createLock();
        var g2 = f.createLock();

        g1.bind(k((j){
          Expects.truthy(j);
          next();
        }));
        g2.bind(k((j){
          Expects.truthy(j);
          next();
        }));

        Expects.isFalse(g1.owns);
        Expects.isFalse(g2.owns);
        f.sendBlock('block1');
        g1.lock();
        Expects.isTrue(g1.owns);
        Expects.isFalse(g2.owns);
        f.sendBlock('block2');
        g2.lock();
        f.sendBlock('block4');
        Expects.isFalse(g1.owns);
        Expects.isTrue(g2.owns);
        f.sendBlock('block3');
      })
      .tickAsync('create two locks and use singular locks',2,(r,next,k){
        var f = Locker.create();
        f.enableSingular();

        var m1 = f.createLock();
        var m2 = f.createLock();

        m1.bind(k((j){
          Expects.truthy(j);
          next();
        }));
        m2.bind(k((j){
          Expects.truthy(j);
          next();
        }));

        m1.lock();
        Expects.isTrue(m1.owns);
        Expects.isFalse(m2.owns);
        f.sendBlock('block1');
        m2.lock();
        Expects.isTrue(m1.owns);
        Expects.isFalse(m2.owns);
        f.sendBlock('block2');
        m1.unlock();
        f.sendBlock('block6');
        m2.lock();
        f.sendBlock('block3');
        Expects.isFalse(m1.owns);
        Expects.isTrue(m2.owns);
        f.sendBlock('block4');

      })
      .emit(true);
    
    });

  });

}
