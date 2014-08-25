library hub.spec;

import 'package:hub/hub.dart';

void main(){
  
  jazzUp((_){

    _.group('testing basic runs',(g){
    
      g.test('can i run sync')
      .rack('can i pass',(d) => d == 1)
      .clock('can i fail',(d){ return d == 1;})
      .emit(1);

      g.test('can i run async')
      .rackAsync('can i pass async',(d,nxt){  
        Expects.asserts(d,1);
        nxt();  
      })
      .clockAsync('can i jug async',(d,nxt){  
        Expects.asserts(d,2);
        nxt(); 
      })
      .emit(1);

      g.test('can i use expects')
      .rack('check asserts',(d){
        Expects.asserts(d,3);
      }).emit(2);

    });

  });


}
