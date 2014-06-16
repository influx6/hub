library hub.spec;

import 'dart:async';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){
  
    var test = [4,20,10,40,5,30,3,1,100];
    var set = [5,32,1,22,2,43,4,6,30,20,100,7,8,9,54];

    Funcs.debug(set);
    Funcs.debugOn('min',Enums.minFor(set));
    Funcs.debugOn('max',Enums.maxFor(set));
    
    var deflog = Log.create();

    var can = deflog.make('can-log',(num n,num m) => n*m,2,"From:{tag} --> \tResult:{res} \tMessage:{message} <--");

    deflog.state; // will return false

    Funcs.debugOn('test',can('love focus')(2,2));

    deflog.enable; //changed state to true

    can('must be equal to {res}')(2,2); //will print out details,replace res with the res and also return value

    deflog.disable;

    Funcs.debugOn('heapSort',Enums.heapSort(set,(n,m) => n < m));
    Funcs.debugOn('heapSort',Enums.heapSort(test,(n,m) => n > m));

    var vdiff = Funcs.tagDefer(Enums.valueDiff,2);
    var kdiff = Funcs.tagDefer(Enums.keyDiff,2);

    vdiff('valuelistdiff')([1,2,4],[1,4,2]);
    kdiff('keylistdiff')([1,2,4],[1,4,2]);
    vdiff('valuemapdiff')({'n':1,'m':2,'g':4},{'n':1,'v':2,'g':4});
    kdiff('keymapdiff')({'n':1,'m':2,'g':4},{'n':10,'v':2,'g':4});

}
