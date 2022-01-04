module host.x86.emitter;

import host.x86.types;

import std.sumtype;

enum PREFIX {
    OPERAND_SIZE_OVERRIDE = 0x66
}

void EmitByte(ubyte emitted) {
    import std.stdio;
    writefln("Emitting: %02x", emitted);
}

void EmitArithmeticLogicSingleOperand(Instruction instruction, Operand operand) {
    // do we need a prefix
    if (operand.Is16Bit()) {
        EmitByte(PREFIX.OPERAND_SIZE_OVERRIDE);
    }

    u8 opcode = instruction.base_opcode;
    opcode |= (operand.Is8Bit() ? 0 : 1);
    EmitByte(opcode);

    u8 modregrm = 0;
    modregrm |= (operand.match!(
        (Register r) => MODREGRM.MOD.REGISTER_ADDRESSING_MODE,
        (Immediate m) => 0 // not implemented
    ) << 6);
    modregrm |= (instruction.opcode_extension << 3);
    modregrm |= operand.AsU8();
    EmitByte(modregrm);
}