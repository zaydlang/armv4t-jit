module host.x86.types;

import std.sumtype;

alias u32 = uint;
alias s32 = int;
alias u16 = ushort;
alias s16 = short;
alias u8  = ubyte;
alias s8  = byte;

alias Immediate32 = u32;
alias Immediate16 = u16;
alias Immediate8  = u8;

enum Register32 {
    eax = 0, ecx, edx, ebx,
    esp, ebp, esi, edi
}

enum Register16 {
    ax = 0, cx, dx, bx,
    sp, bp, si, di
}

enum Register8 {
    al = 0, cl, dl, bl,
    spl, bpl, sil, dil
}

enum Size {
    BYTE       = 1,
    WORD       = 2,
    DOUBLEWORD = 4
}

alias Register    = SumType!(Register8, Register16, Register32);
alias Immediate   = SumType!(Immediate8, Immediate16, Immediate32);

struct RegisterIndirect {
    Register register;
    Size     size;
}

alias Operand     = SumType!(Register, RegisterIndirect, Immediate);

static pure bool Is8Bit (Operand o) { return GetNumBytes(o) == 1; }
static pure bool Is16Bit(Operand o) { return GetNumBytes(o) == 2; }
static pure bool Is32Bit(Operand o) { return GetNumBytes(o) == 4; }

static pure int GetNumBytes(Operand o) {
    return o.match!(
        (Register r) => (r.match!(
            (Register8  x) => 1,
            (Register16 x) => 2,
            (Register32 x) => 4
        )),
        (RegisterIndirect r) => r.size,
        (Immediate  m) => (m.match!(
            (Immediate8  x) => 1,
            (Immediate16 x) => 2,
            (Immediate32 x) => 4
        ))
    );
}

static pure u8 AsU8(Operand o) {
    return o.match!(
        (Register r) => (r.match!(
            (Register8  x) => cast(u8) x,
            (Register16 x) => cast(u8) x,
            (Register32 x) => cast(u8) x,
        )),
        (RegisterIndirect r) => (cast(Operand) r.register).AsU8(),
        (Immediate m) => (m.match!(
            (Immediate8  x) => x,
            (Immediate16 x) => cast(u8) 0x0, // throw an error?
            (Immediate32 x) => cast(u8) 0x0
        ))
    );
}

struct MODREGRM {
    enum MOD {
        REGISTER_ADDRESSING_MODE = 0b11
    }
}

struct Instruction {
    string name;

    u8 base_opcode;
    u8 opcode_extension;
    u8 num_operands;
}

Instruction neg = {
    name:             "NEG",
    base_opcode:      0xF6,
    opcode_extension: 3,
    num_operands:     1
};