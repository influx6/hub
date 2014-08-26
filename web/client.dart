library hub.spec;

import 'dart:async';
import 'dart:html';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hubclient.dart';

void main(){

  var es = new Example('es');
  stripjs.fragment('console');
  stripjs.register('console','log'); 
  stripjs.runOn('console','log')('socker!'); 
  stripjs.apply('console@log','juggerboy!'); 
  assert(stripjs.set('root','choice','thunder'));
  assert(stripjs.jsFragment('root','choice') == 'thunder');

}
