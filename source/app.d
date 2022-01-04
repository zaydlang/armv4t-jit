import std.stdio;

import host.x86.allocator;
import host.x86.compiler;
import host.x86.emitter;
import host.x86.types;

void main() {
	SetupPage();
	Emit(`
		mov %eax, 0x0
		adc %eax, 0x1
	`);

	EmitArithmeticLogicSingleOperand(neg, cast(Operand) cast(Register) Register16.ax);
}
