module host.x86.emitter;

import std.sumtype;

void EmitByte(ubyte emitted) {
    writefln("Emitting: %08x", emitted);
}

void EmitArithmeticLogicSingleOperand(Instruction instruction, Operand operand) {
    u8 opcode = instruction.base_opcode;
    opcode |= (operand1.sizeof > 8);
    EmitByte(opcode);

    u8 mod = 
}