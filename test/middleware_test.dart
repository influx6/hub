library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){

  var ware = Middleware.create((nd){
    Funcs.tagLog('Kicking out middleware with',nd);
  });

  ware.ware((d,next,end){
    Funcs.tagLog('i love you ',d);
    next();
  }).then(Funcs.tag('1st run with'));

  ware.ware((d,next,end){
    Funcs.tagLog('i hate you ',d);
    next('john');
  }).then(Funcs.tag('2nd run with'));

  ware.ware((d,next,end){
    Funcs.tagLog('i hate you ',d);
    new Timer(new Duration(milliseconds: 6000),(){ next('flix');});
    return 'socks';
  }).then(Funcs.tag('6th run with'));

  ware.ware((d,next,end){
    Funcs.tagLog("i didn't really mean it ",d);
    next('please!');
    return 'socker'; // middleware can return a value to the future to complete with
  }).then(Funcs.tag('3rd run with'));

  ware.ware((d,next,end){
    Funcs.tagLog("love me again",d);
    end('sorry!'); //-> will stop middleware from running other functions in the stack and end this call
  }).then(Funcs.tag('4th run with'));

  //these won't be executed as the next() call is stop at the previous middleware
  ware.ware((d,next,end){
    Funcs.tagLog("no body will run me",d);
    assert(false);
  }).then(Funcs.tag('final run with'));

  ware.emit('alex');

  //stack can be reversed in the list
  ware.reverseStacking();

  ware.emit('john');

}
