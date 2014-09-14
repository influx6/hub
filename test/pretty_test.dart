library hub.spec;

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:hub/hub.dart';

class M{
    String id;
    M(this.id);

    String toString() => "M identity: ${this.id}";
}

class N{
    String id;
    N(this.id);

    String toJSON() => JSON.encode("{ N: ${this.id}}");

    String toString() => "N identity: ${this.id}";
}

void main(){
  
    var test = [4,20,10,3,1,100,'love'];
    var  mp = {
        // 'fn': Funcs.switchUnless,
        'name': 'center',
        'id': 0,
        'padding': '10px 10px 0px 10px',
        'date': new DateTime.now(),
        'list': [1,3],
        'm': new M('london'),
        'n': new N('southkorea'),
        'dp': {
            'name':"deeper",
            'tag': 'will it work',
            'list': [1,3],
            'wp': {
                'name':"deeper",
                'tag': 'will it work',
                'rp': {
                    'name':"deeper",
                    'tag': 'will it work',
                    'ep': {
                        'name':"deeper",
                        'tag': 'will it work',
                        'list': [1,3],
                    }
                }
            }
        }
    };

    Funcs.debug(Funcs.prettyPrint(1));
    Funcs.debug(Funcs.prettyPrint('socket'));
    Funcs.debug(Funcs.prettyPrint(test));
    Funcs.debug(Funcs.prettyPrint(mp,null,null,''));

}
