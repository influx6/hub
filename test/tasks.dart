library hub.spec;

import 'package:hub/hub.dart';
import 'dart:async';

void main(){

	var count = 0;
	var z = TaskQueue.create(false);

	z.delay(300);
	z.queue((n) => print('qe: ${count += 1} $n'));
	z.queue((n) => print('qe: ${count += 1} $n'));
	z.queue((n){
		z.immediate((n) => print('first qi: ${count += 3} $n'));
	});
	z.queue((n) => print('qe: ${count += 1} $n'));
	z.queue((n){
		z.immediate((n) => print('will downgrade second: qi: ${count += 3} $n'));
		z.decDelay(100);
		z.downgrade(0);
	});
	z.queue((n){
		z.immediate((n) => print('third qi: ${count += 1} $n'));
		// z.dequeueFirst();
	});
	z.queue((n){
		z.immediate((n) => print('final qi: ${count += 2} $n'));
		z.decDelay(100);
	});
	z.queue((n) => print('final qe: ${count += 1} $n'));

	z.exec('burner!');
}