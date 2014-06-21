library hub.spec;

import 'dart:async';
import 'dart:math' as math;
import 'package:hub/hub.dart';

void main(){
  
    var test = [4,20,10,3,1,100,'love'];
    var  mp = {
        'name': 'center',
        'id': 0,
        'date': new DateTime.now(),
        'list': [1,3],
        'dp': {
            'name':"deeper",
            'tag': 'will it work',
            'list': [1,3],
            'dp': {
                'name':"deeper",
                'tag': 'will it work',
                'dp': {
                    'name':"deeper",
                    'tag': 'will it work',
                    'dp': {
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
    Funcs.debug(Funcs.prettyPrint(mp));

}
