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
    
    var canDebug = Funcs.futureBind();
    var deflog = Funcs.defferedDebugLog(canDebug);

    var can = deflog('can-log',(num n,num m) => n*m,2,"From:{tag} --> \tResult:{res} \tMessage:{message} <--");

    canDebug(); // will return false

    Funcs.debugOn('test',can('love focus')(2,2));

    canDebug(true); //changed state to true

    can('must be equal to {res}')(2,2); //will print out details,replace res with the res and also return value

    canDebug(false);

    Funcs.debugOn('heapSort',Enums.heapSort(set,(n,m) => n < m));
    Funcs.debugOn('heapSort',Enums.heapSort(test,(n,m) => n > m));


}
