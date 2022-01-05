module host.x86.emitter;

import host.x86.types;

import std.sumtype;

enum PREFIX {
    OPERAND_SIZE_OVERRIDE = 0x66
}

struct SIB {
    enum SCALE {
        FACTOR1 = 0b00,
        FACTOR2 = 0b01,
        FACTOR4 = 0b10,
        FACTOR8 = 0b11
    }

    enum INDEX {
        NONE    = 0b100
    }
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
        _ => 0 // not implemented
    ) << 6);
    modregrm |= (instruction.opcode_extension << 3);
    modregrm |= operand.AsU8();
    EmitByte(modregrm);

    // do we need a SIB byte
   if (NeedsSIB(operand)) {
       u8 sib = 0;
       sib |= (SIB.SCALE.FACTOR1) << 6;
       sib |= (SIB.INDEX.NONE)    << 3;
       sib |= operand.AsU8();
       EmitByte(sib);
   }
}

pure bool NeedsSIB(Operand operand) {
    // probably incomplete, but it works for now
    return operand.match!(
        (RegisterIndirect r) => r.register.match!(
            (Register32 r32) => r32 == Register32.esp,
            (Register16 r16) => r16 == Register16.sp,
            (Register8  r8)  => r8  == Register8.spl
        ),
        _ => false // or do i throw an error???? TODO
    );
}