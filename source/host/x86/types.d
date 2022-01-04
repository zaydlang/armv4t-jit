module host.x86.types;

alias u32 = uint;
alias s32 = int;
alias u16 = ushort;
alias s16 = short;
alias u8  = ubyte;
alias s8  = byte;

alias Immediate8  = u8;
alias Immediate16 = u16;
alias Immediate32 = u32;

enum Register32 {
    eax, ecx, edx, ebx,
    esp, ebp, esi, edi,
    r8d, r9d, r10d, r11d,
    r12d, r13d, r14d, r15d
}

enum Register16 {
    ax, cx, dx, bx,
    si, di, sp, bp,
    r8w, r9w, r10w, r11w,
    r12w, r13w, r14w, r15w
}

enum Register8 {
    al, cl, dl, bl,
    sil, dil, spl, bpl,
    r8b, r9b, r10b, r11b,
    r12b, r13b, r14b, r15b
}

alias Register    = SumType!(Register8, Register16, Register32);
alias Immediate   = SumType!(Immediate8, Immediate16, Immediate32);
alias Operand     = SumType!(Register, Immediate);