library hub.spec;

import 'dart:async';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){

    var dist = Hub.createDistributor('test-case');

    Funcs.debug(dist);
    // Funcs.debugOn('min',Enums.minFor(set));
    // Funcs.debugOn('max',Enums.maxFor(set));
    
    var disLog = Funcs.debugFor('distributed');
    var disLogOnce = Funcs.debugFor('distributed-once');

    dist.on(disLog(Funcs.identity));
    dist.onOnce(disLogOnce(Funcs.identity));

    var fns = disLog(Funcs.identity);

    dist.emit(4);
    dist.emit(5);

    dist.on(fns);

    dist.emit(9);

    dist.off(fns);
    
    dist.emit(6);
}
