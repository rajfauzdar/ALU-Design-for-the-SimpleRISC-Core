#!/usr/bin/env python3
"""
asm2hex.py

Simple assembler for your special CPU focusing on ALU ops + load/store/mov immediate.

Usage:
    python asm2hex.py input.asm output.hex

Output file contains one 0xXXXXXXXX hex per line (32-bit).
"""

import sys
import re

# ----- opcode map (from your `define`s) -----
OPCODES = {
    "ADD": 0b00000,
    "SUB": 0b00001,
    "MUL": 0b00010,
    "DIV": 0b00011,
    "MOD": 0b00100,
    "CMP": 0b00101,
    "AND": 0b00110,
    "OR": 0b00111,
    "NOT": 0b01000,
    "MOV": 0b01001,
    "SLL": 0b01010,  # LSL in your earlier list -> SLL here
    "LSR": 0b01011,
    "ASR": 0b01100,
    "NOP": 0b01101,
    "LD": 0b01110,
    "ST": 0b01111,
    "BEQ": 0b10000,
    "BGT": 0b10001,
    "B": 0b10010,
    "CALL": 0b10011,
    "RET": 0b10100,
}

# register names -> numbers (4-bit)
REGS = {f"R{i}": i for i in range(16)}
# aliases
REGS.update({"SP": 14, "RA": 15})

# parsing helpers
comment_re = re.compile(r"(;|//).*")
token_re = re.compile(r"[,\s]+")


def parse_reg(tok):
    tok = tok.upper()
    if tok in REGS:
        return REGS[tok]
    # allow plain numeric register like 3 meaning R3
    m = re.fullmatch(r"R?([0-9]+)", tok)
    if m:
        v = int(m.group(1))
        if 0 <= v <= 15:
            return v
    raise ValueError(f"Invalid register '{tok}'")


def parse_imm(tok):
    """Parse immediate like #10, -5, 0xFF"""
    tok = tok.strip()
    if tok.startswith("#"):
        tok = tok[1:]
    # allow hex 0x, bin 0b, decimal (signed)
    if tok.startswith("0x") or tok.startswith("0X"):
        return int(tok, 16)
    if tok.startswith("0b") or tok.startswith("0B"):
        return int(tok, 2)
    return int(tok, 10)


def to_signed(val, bits):
    """Return signed representation in two's complement for negative numbers."""
    mask = (1 << bits) - 1
    return val & mask


def assemble_line(opname, operands):
    opname = opname.upper()
    if opname not in OPCODES:
        raise ValueError(f"Unknown opcode '{opname}'")
    op = OPCODES[opname] & 0x1F  # 5 bits

    # normalize operands: split by comma/space
    ops = [o for o in token_re.split(operands) if o != ""]
    # print(operands)
    # R-type ALU: e.g. ADD RD, RS1, RS2
    # I-type ALU: e.g. ADD RD, RS1, #IMM
    # MOV immediate: MOV RD, #IMM
    # LD/ST immediate: LD RD, #IMM  (we treat as I-type)
    I = 0
    rd = rs1 = rs2 = 0
    imm18 = 0

    if opname == "NOT":  # unary: NOT RD, RS1  (we'll set RS2=0)
        if len(ops) != 2:
            raise ValueError("NOT expects: NOT RD, RS1")
        rd = parse_reg(ops[0])
        rs1 = parse_reg(ops[1])
        rs2 = 0
        I = 0
    elif opname in ("MOV", "LD", "ST"):
        # treat MOV/LD/ST as I-type when immediate provided
        if len(ops) != 2:
            raise ValueError(
                f"{opname} expects: {opname} RD, #IMM  (or RD, RS1 for MOV reg->reg)"
            )
        rd_tok, src_tok = ops[0], ops[1]
        rd = parse_reg(rd_tok)
        if src_tok.startswith("#") or re.fullmatch(
            r"-?\d+|0x[0-9a-fA-F]+|0b[01]+", src_tok
        ):
            # immediate
            I = 1
            imm = parse_imm(src_tok)
            imm18 = to_signed(imm, 18)
        else:
            # MOV RD, RS1  (register copy)
            I = 0
            rs1 = parse_reg(src_tok)
            rs2 = 0
    else:
        # General ALU forms: expect 3 operands (RD, RS1, RS2/IMM)
        if len(ops) != 3:
            raise ValueError(f"{opname} expects: {opname} RD, RS1, RS2_or_#IMM")
        rd = parse_reg(ops[0])
        rs1 = parse_reg(ops[1])
        third = ops[2]
        if third.startswith("#") or re.fullmatch(
            r"-?\d+|0x[0-9a-fA-F]+|0b[01]+", third
        ):
            I = 1
            imm = parse_imm(third)
            imm18 = to_signed(imm, 18)
        else:
            I = 0
            rs2 = parse_reg(third)

    # Build 32-bit instruction
    instr = (op << 27) & 0xF8000000  # bits 31:27
    instr |= (I << 26) & 0x04000000  # bit 26
    instr |= (rd & 0xF) << 22  # bits 25:22
    instr |= (rs1 & 0xF) << 18  # bits 21:18

    if I:
        instr |= imm18 & 0x3FFFF  # bits 17:0 (18 bits)
    else:
        instr |= (rs2 & 0xF) << 14  # bits 17:14
        # lower 14 bits left as zero (reserved)

    return instr


def assemble_file(infile_path, outfile_path):
    lines_out = []
    human_map = []
    with open(infile_path, "r") as f:
        for lineno, line in enumerate(f, start=1):
            raw = line.rstrip("\n")
            # print(raw)
            # strip comments
            no_comment = comment_re.sub("", raw).strip()
            if not no_comment:
                continue
            # split into opcode and rest
            # print(no_comment)
            parts = no_comment.strip().split(None, 1)
            if not parts:
                continue
            opname = parts[0]
            operands = parts[1] if len(parts) > 1 else ""
            try:
                instr = assemble_line(opname, operands)
            except Exception as e:
                raise SyntaxError(
                    f"{infile_path}:{lineno}: error assembling '{raw}': {e}"
                )
            lines_out.append(instr)
            human_map.append((raw, instr))
    # write hex file
    with open(outfile_path, "w") as fout:
        for instr in lines_out:
            fout.write(f"0x{instr:08X}\n")
    # print friendly mapping
    print(f"Wrote {len(lines_out)} instructions to {outfile_path}\n")
    for asm, instr in human_map:
        print(f"{asm:40s} -> 0x{instr:08X}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python asm2hex.py input.asm output.hex")
        sys.exit(1)
    assemble_file(sys.argv[1], sys.argv[2])
