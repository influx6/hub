library specs;

import 'package:hub/hub.dart';

main(){
  
  var play = State.create({ 'name':'alex','paused': false},{
    'play': (target,controller){ print('${target['name']} playing song? isPaused: ${target['paused']}'); },
    'pause': (target,controller){ target['paused'] = true; controller.run('play'); }
  },'player');
  
  var man = StateManager.create(play);
  man.add('play',{
    'play':(target,control){ target.activate(); target.run('play'); },
    'pause':(target,control){ }
  });
  man.add('pause',{
    'play':(target,control){ },
    'pause':(target,control){ target.run('pause'); target.deactivate(); }
  });
  
  play.run('play');
//  man.switchState('play');
//  no reaction since state is null
  man.run('play'); 
  man.run('pause');
  //switching to play state
  man.switchState('play');
 //should get response with play but not pause
  man.run('play'); 
  man.run('pause');
  //switching to pause state
  man.switchState('pause');
  //pause should respond not play
  man.run('play'); man.run('pause');


}