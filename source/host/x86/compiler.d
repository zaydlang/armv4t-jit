module host.x86_64.compiler;

import pegged.grammar;

import std.algorithm.iteration;
import std.range;
import std.string;

private immutable static string[] integer_instructions = [
    "AAA", "AAD", "AAM", "AAS", "ADC", "ADD", "AND", "CALL", 
    "CBW", "CLC", "CLD", "CLI", "CMC", "CMP", "CMPSB", "CMPSW",
    "CWD", "DAA", "DAS", "DEC", "DIV", "ESC", "HLT", "IDIV", 
    "IMUL", "IN", "INC", "INT", "INTO", "IRET", "Jcc", "JCXZ", 
    "JMP", "LAHF", "LDS", "LEA", "LES", "LOCK", "LODSB", "LODSW", 
    "LOOP/LOOPx", "MOV", "MOVSB", "MOVSW", "MUL", "NEG", "NOP", 
    "NOT", "OR", "OUT", "POP", "POPF", "PUSH", "PUSHF", "RCL", 
    "RCR", "RET", "RETN", "RETF", "ROL", "ROR", "SAHF", 
    "SAL", "SAR", "SBB", "SCASB", "SCASW", "SHL", "SHR", "STC", 
    "STD", "STI", "STOSB", "STOSW", "SUB", "TEST", "WAIT", "XCHG", 
    "XLAT", "XOR"
];

private immutable static string[] general_purpose_registers = [
    "eax", "ecx", "edx", "ebx", "esp", "ebp", "esi", "edi", "r8d", 
    "r9d", "r10d", "r11d", "r12d", "r13d", "r14d", "r15d"
];

private immutable static string[] segment_registers = [
    "cs", "ds", "es", "ss", "fs", "gs"
];

private pure string ConvertStringArrayToPEG(immutable string[] array) {
    return array.map!(a => '"' ~ a ~ `"i`).fold!((a, b) => a ~ " / " ~ b);
}

mixin(grammar(`
ParseIntelx86:
    Code                  < Line+
    Line                  < Instruction (Operand? ("," Operand)*)

    Label                 < ~([a-zA-Z_]+)
    Instruction           < ` ~ ConvertStringArrayToPEG(integer_instructions) ~ `
    Operand               < Segment / BaseIndexScale / Number

    SegmentOffset         < Number
    Segment               < :"%"(SegmentRegister) : SegmentOffset
    SegmentRegister       < ` ~ ConvertStringArrayToPEG(segment_registers) ~ `

    BaseIndexScale        < ("("Base"," Index"," Scale")") / Base

    Base                  < :"%"(Register)
    Index                 < :"%"(Register)
    Scale                 < [1248]

    Register              < ` ~ ConvertStringArrayToPEG(general_purpose_registers) ~ `

    Number                <- Hex / Dec / Bin
    Hex                   <- ~("0x"([0-9a-fA-F]+))
    Dec                   <- ~([0-9]+)
    Bin                   <- ~("0b"([01]+))
`));

private string GenerateOpcodeEmittersFromParseTree(ParseTree p) {
    string RecurseSingle(ParseTree p) {
        return GenerateOpcodeEmittersFromParseTree(p);
    }

    string RecurseMultiple(ParseTree[] p) {
        return p.map!GenerateOpcodeEmittersFromParseTree.fold!((a, b) => a ~ b);
    }

    switch (p.name) {
        case "ParseIntelx86":
            return RecurseSingle(p.children[0]);

        case "ParseIntelx86.Code":
            return RecurseMultiple(p.children);

        case "ParseIntelx86.Line":
            auto instruction = RecurseSingle(p.children[0]);
            auto operands    = p.children[1 .. $].map!RecurseSingle;

            auto delimited_operands = join(operands, ", ");

            return "x86Emit" ~ instruction ~ "(" ~ delimited_operands ~ ");\n";

        case "ParseIntelx86.Instruction":
            return capitalize(p.matches[0]);
        
        case "ParseIntelx86.Operand":
            return RecurseSingle(p.children[0]);
        
        case "ParseIntelx86.Number":
            return p.matches[0];
        
        case "ParseIntelx86.BaseIndexScale":
            return RecurseMultiple(p.children);
        
        case "ParseIntelx86.Base":
            return RecurseSingle(p.children[0]);

        case "ParseIntelx86.Index":
            return RecurseSingle(p.children[0]);
        
        case "ParseIntelx86.Register":
            return p.matches[0];

        default:
            return "";
    }
}

import std.stdio;

string Emit(string code) {
    auto parsed_code = ParseIntelx86(code);

    writeln(parsed_code);
    writeln( GenerateOpcodeEmittersFromParseTree(parsed_code));

    return "";
}