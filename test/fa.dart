library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){
  
    var test = [4,20,10,3,1,100,'love'];
    var fa = FunctionalAtomic.create(test);
  
    fa.addAtomic('first',(n) => Enums.first(n));
    fa.addAtomic('second',(n) => Enums.second(n));

    fa.bind('first',(map){
        print('first change map#$map');
    });

    fa.bind('second',(map){
        print('second change map#$map');
    });

    fa.checkAtomics();

    test[0] = 100;

    fa.checkAtomics();

    test[1] = 0;

    fa.checkAtomics();
}
