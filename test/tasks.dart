library atomic.spec;

import 'package:hub/hub.dart';

void main(){

	var count = 0;
	var z = TasksQueue.create();

	z.delay(300);
	z.queue(() => print('qe: ${count += 1}'));
	z.queue(() => print('qe: ${count += 1}'));
	z.queue((){
		z.immediate(() => print('qi: ${count += 3}'));
	});
	z.queue(() => print('qe: ${count += 1}'));
	z.queue((){
		z.immediate(() => print('qi: ${count += 3}'));
		z.decDelay(100);
		z.downgrade(0);
	});
	z.queue((){
		z.immediate(() => print('qi: ${count += 1}'));
		z.dequeueFirst();
	});
	z.queue((){
		z.immediate(() => print('qi: ${count += 2}'));
		z.decDelay(100);
	});
	z.queue(() => print('qe: ${count += 1}'));


}