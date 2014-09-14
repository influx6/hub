library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
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
      .rack('create two locks and check locks states',(r,g){
        var f = Locker.create();
        var m1 = f.createLock();
        var m2 = f.createLock();

        Expects.isFalse(m1.owns);
        Expects.isFalse(m2.owns);
        m1.lock();
        Expects.isTrue(m1.owns);
        Expects.isFalse(m2.owns);
        m2.lock();
        Expects.isFalse(m1.owns);
        Expects.isTrue(m2.owns);
      })
      .rack('create two locks and use singular locks',(r,g){
        var f = Locker.create();
        f.enableSingular();

        var m1 = f.createLock();
        var m2 = f.createLock();

        m1.lock();
        Expects.isTrue(m1.owns);
        Expects.isFalse(m2.owns);
        m2.lock();
        Expects.isTrue(m1.owns);
        Expects.isFalse(m2.owns);
        m1.unlock();
        m2.lock();
        Expects.isFalse(m1.owns);
        Expects.isTrue(m2.owns);
      })
      .emit(true);
    
    });

  });

}
