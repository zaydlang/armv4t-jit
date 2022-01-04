import std.stdio;

import host.x86.emitter;
import host.x86.compiler;

void main() {
	SetupPage();
	Emit(`
		mov %eax, 0x0
		adc %eax, 0x1
	`);
}
