library hub.spec;

import 'package:hub/hub.dart';

void main(){
  
  jazzUp((_){

    _.group('testing basic runs',(g){
    
      g.test('can i run sync')
      .rack('can i pass',(d,g) => d == 1)
      .clock('can i fail',(d,g){ return d == 1;})
      .emit(1);

      g.test('can i run async')
      .rackAsync('can i pass async',(d,nxt,g){  
        Expects.asserts(d,1);
        nxt(2);  
      })
      .clockAsync('can i jug async',(d,nxt,g){  
        Expects.asserts(d,2);
        nxt(); 
      })
      .emit(1);

      g.test('can i use expects')
      .rack('check asserts',(d,g){
        Expects.asserts(d,2);
      }).emit(2);

    });

    _.group('testing truthy value',(g){
    
      g.test('can i use expects')
      .rack('check asserts',(d,g){
        Expects.truthy(d);
      }).emit(2);

    });
  });

}
